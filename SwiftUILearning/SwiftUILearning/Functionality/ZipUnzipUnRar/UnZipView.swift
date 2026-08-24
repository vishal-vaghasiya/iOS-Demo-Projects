import SwiftUI
import UniformTypeIdentifiers
import ZipArchive

struct UnZipView: View {
    @State private var selectedZip: URL?
    @State private var isPickerPresented = false
    @State private var unzipPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isPasswordProtected = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let selectedZip = selectedZip {
                    Text("Selected File: \(selectedZip.lastPathComponent)")
                        .font(.subheadline)
                        .lineLimit(1)
                        .padding(.horizontal)
                } else {
                    Text("No ZIP file selected")
                        .foregroundColor(.gray)
                }

                Button(action: { isPickerPresented = true }) {
                    Label("Select ZIP File", systemImage: "doc.badge.plus")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                if selectedZip != nil {
                    if isPasswordProtected {
                        SecureField("Enter Password", text: $unzipPassword)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }

                    Button(action: unzipFile) {
                        Label("Unzip Here", systemImage: "arrow.down.doc")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .navigationTitle("Unzip File")
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.zip],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedZip = url
                        isPasswordProtected = SSZipArchive.isFilePasswordProtected(atPath: url.path)
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
        }
    }

    private func unzipFile() {
        guard let zipURL = selectedZip else {
            alertMessage = "Please select a ZIP file first."
            showAlert = true
            return
        }

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent(zipURL.deletingPathExtension().lastPathComponent)

        do {
            // Remove existing directory if exists
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            // Check if ZIP is password protected
            let isProtected = SSZipArchive.isFilePasswordProtected(atPath: zipURL.path)

            // If password-protected and user hasn’t entered a password, ask for it first
            if isProtected && unzipPassword.isEmpty {
                alertMessage = "This ZIP file is password-protected. Please enter the password and try again."
                showAlert = true
                return
            }

            // Proceed with unzip (if not protected or password already provided)
            var success = false
            success = SSZipArchive.unzipFile(
                atPath: zipURL.path,
                toDestination: destinationURL.path,
                preserveAttributes: true,
                overwrite: true,
                password: unzipPassword.isEmpty ? nil : unzipPassword,
                error: nil,
                delegate: nil
            )

            if success {
                alertMessage = "File unzipped successfully to: \(destinationURL.lastPathComponent)"
            } else if isProtected {
                alertMessage = "Incorrect password. Please try again."
            } else {
                alertMessage = "Failed to unzip. The file may be corrupted."
            }
        } catch {
            alertMessage = "Error during unzip: \(error.localizedDescription)"
        }

        showAlert = true
    }
}

#Preview {
    UnZipView()
}
