import SwiftUI
import UniformTypeIdentifiers
import Foundation
import PhotosUI
import ZipArchive

struct ZipView: View {
    @State private var selectedFiles: [URL] = []
    @State private var isPickerPresented = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var zipPassword: String = ""
    @State private var photoSelection: [PhotosPickerItem] = []

    var body: some View {
        NavigationView {
            VStack {
                if selectedFiles.isEmpty {
                    Text("No files selected")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(selectedFiles, id: \.self) { file in
                            HStack {
                                Text(file.lastPathComponent)
                                    .lineLimit(1)
                                Spacer()
                                Button(action: {
                                    removeFile(file)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }

                if !selectedFiles.isEmpty {
                    SecureField("Enter Zip Password (optional)", text: $zipPassword)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                VStack {
                    HStack {
                        Button(action: { isPickerPresented = true }) {
                            Label("Add File", systemImage: "doc.badge.plus")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        PhotosPicker(
                            selection: $photoSelection,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Label("Add Photo", systemImage: "photo.on.rectangle")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: createZip) {
                        Label("Create Zip", systemImage: "doc.zipper")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Zip Creator")
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.item, .image, .content, .data],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    for url in urls {
                        // Request temporary access
                        guard url.startAccessingSecurityScopedResource() else {
                            alertMessage = "No permission to access file: \(url.lastPathComponent)"
                            showAlert = true
                            continue
                        }

                        // Copy to app's temporary directory for safe access
                        let destination = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                        do {
                            if FileManager.default.fileExists(atPath: destination.path) {
                                try FileManager.default.removeItem(at: destination)
                            }
                            try FileManager.default.copyItem(at: url, to: destination)
                            selectedFiles.append(destination)
                        } catch {
                            alertMessage = "Failed to copy: \(error.localizedDescription)"
                            showAlert = true
                        }

                        // End access to prevent leaks
                        url.stopAccessingSecurityScopedResource()
                    }
                case .failure(let error):
                    alertMessage = "Error selecting file: \(error.localizedDescription)"
                    showAlert = true
                }
            }
            .alert("Message", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .onChange(of: photoSelection) { newValues in
                Task {
                    for newValue in newValues {
                        if let data = try? await newValue.loadTransferable(type: Data.self) {
                            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                            try? data.write(to: tempURL)
                            selectedFiles.append(tempURL)
                        }
                    }
                }
            }
        }
    }

    private func removeFile(_ file: URL) {
        selectedFiles.removeAll { $0 == file }
    }

    private func createZip() {
        guard !selectedFiles.isEmpty else {
            alertMessage = "Please select at least one file."
            showAlert = true
            return
        }

        let fileManager = FileManager.default
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let zipFileName = "MyFiles_\(formatter.string(from: Date())).zip"

        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let zipFileURL = documentsURL.appendingPathComponent(zipFileName)

        // Remove old zip if it exists
        if fileManager.fileExists(atPath: zipFileURL.path) {
            try? fileManager.removeItem(at: zipFileURL)
        }

        // Get file paths as strings
        let filePaths = selectedFiles.map { $0.path }

        // Create ZIP using SSZipArchive
        let success = SSZipArchive.createZipFile(
            atPath: zipFileURL.path,
            withFilesAtPaths: filePaths,
            withPassword: zipPassword.isEmpty ? nil : zipPassword
        )

        if success {
            alertMessage = "ZIP saved to Files app: \(zipFileURL.lastPathComponent)"
        } else {
            alertMessage = "Failed to create ZIP file."
        }

        showAlert = true
    }
}

#Preview {
    ZipView()
}
