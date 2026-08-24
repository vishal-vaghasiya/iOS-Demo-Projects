import SwiftUI
import UniformTypeIdentifiers
import Unrar
struct UnRarView: View {
    // MARK: - Properties
    @State private var selectedRar: URL?
    @State private var isPickerPresented = false
    @State private var rarPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isPasswordProtected = false
    @State private var extractionProgress: Double = 0.0
    @State private var totalEntries: Int = 0
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let selectedRar = selectedRar {
                    Text("Selected File: \(selectedRar.lastPathComponent)")
                        .font(.subheadline)
                        .lineLimit(1)
                        .padding(.horizontal)
                } else {
                    Text("No RAR file selected")
                        .foregroundColor(.gray)
                }
                
                // Button to present file picker for selecting a RAR file
                Button(action: { isPickerPresented = true }) {
                    Label("Select RAR File", systemImage: "doc.badge.plus")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                if selectedRar != nil {
                    if isPasswordProtected {
                        // SecureField to enter password if the RAR file is password protected
                        SecureField("Enter Password", text: $rarPassword)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    // Button to trigger extraction of the selected RAR file
                    Button(action: unrarFile) {
                        Label("Extract Here", systemImage: "arrow.down.doc")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                
                if extractionProgress > 0 && extractionProgress < 1 {
                    ProgressView(value: extractionProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                }
                Spacer()
            }
            .navigationTitle("UnRar File")
            // File importer to select a single RAR file
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.init(filenameExtension: "rar")!],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedRar = url
                        detectPasswordProtection(for: url)
                    }
                case .failure(let error):
                    alertMessage = "Error selecting file: \(error.localizedDescription)"
                    showAlert = true
                }
            }
            // Alert to display messages to the user
            .alert("Message", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func detectPasswordProtection(for url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            alertMessage = "Cannot access file. Please try selecting it again."
            showAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        // Copy file to a local temporary directory to ensure accessibility
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            let localRAR = tmpDir.appendingPathComponent(url.lastPathComponent)
            try FileManager.default.copyItem(at: url, to: localRAR)
            
            do {
                // Open archive using path-based initializer
                let archive = try Archive(path: localRAR.path)
                // Attempt to list entries
                let entries = try archive.entries()
                guard let firstEntry = entries.first else {
                    isPasswordProtected = false
                    return
                }

                // Create temporary extraction folder
                let tmpDirExtract = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                try FileManager.default.createDirectory(at: tmpDirExtract, withIntermediateDirectories: true)

                defer {
                    // Clean up temporary folder
                    try? FileManager.default.removeItem(at: tmpDirExtract)
                }

                do {
                    // Try extracting the first entry to memory. If it fails due to password, we'll catch below.
                    _ = try archive.extract(firstEntry)
                    // Extraction succeeded without password
                    isPasswordProtected = false
                } catch {
                    // Inspect error message for password/encrypted clues
                    let msg = (error as NSError).localizedDescription.lowercased()
                    if msg.contains("password") || msg.contains("encrypted") {
                        isPasswordProtected = true
                    } else {
                        // Not clearly password-related — assume not protected but report error
                        isPasswordProtected = false
                    }
                }
            } catch {
                // If we cannot open or list entries, inspect the error text for password hints
                let nsError = error as NSError
                let msg = nsError.localizedDescription.lowercased()
                if nsError.domain.contains("Unrar.UnrarError") && nsError.code == 5 {
                    // Attempt to reopen the archive with a dummy password to distinguish protection vs corruption
                    do {
                        let archive = try Archive(path: localRAR.path, password: "")
                        let entries = try archive.entries()

                        if let first = entries.first {
                            do {
                                _ = try archive.extract(first)
                                // Extraction succeeded without password
                                alertMessage = "Valid RAR file (no password needed)."
                                isPasswordProtected = false
                            } catch {
                                // Extraction failed — likely due to encryption
                                alertMessage = "This RAR file is password protected."
                                isPasswordProtected = true
                            }
                        } else {
                            alertMessage = "Empty archive."
                            isPasswordProtected = false
                        }
                        showAlert = true
                    } catch {
                        // If the dummy password fails, it’s password protected, not corrupted
                        alertMessage = "This RAR file is password protected."
                        isPasswordProtected = true
                    }
                } else if msg.contains("password") || msg.contains("encrypted") {
                    alertMessage = "This RAR file is password protected."
                    isPasswordProtected = true
                } else {
                    alertMessage = "Error reading RAR file: \(error.localizedDescription)"
                    showAlert = true
                }
                print(alertMessage)
            }
        } catch {
            alertMessage = "Error accessing file: \(error.localizedDescription)"
            print(alertMessage)
            showAlert = true
        }
    }
    
    /// Extracts the selected RAR file to the app's document directory.
    private func unrarFile() {
        guard let rarURL = selectedRar else {
            alertMessage = "Please select a RAR file first."
            showAlert = true
            print(alertMessage)
            return
        }
        
        guard rarURL.startAccessingSecurityScopedResource() else {
            alertMessage = "Cannot access the selected RAR file."
            showAlert = true
            print(alertMessage)
            return
        }
        defer { rarURL.stopAccessingSecurityScopedResource() }

        // Copy file locally before unarchiving
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            let localRAR = tmpDir.appendingPathComponent(rarURL.lastPathComponent)
            try FileManager.default.copyItem(at: rarURL, to: localRAR)
            
            // Initialize the archive with password if provided
            let archive = try Archive(path: localRAR.path,
                                      password: rarPassword.isEmpty ? nil : rarPassword)
            // Determine the extraction destination path
            let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let extractPath = destination.appendingPathComponent(rarURL.deletingPathExtension().lastPathComponent)
            
            // Remove existing extracted folder if it exists
            if FileManager.default.fileExists(atPath: extractPath.path) {
                try FileManager.default.removeItem(at: extractPath)
            }
            
            // If the archive is password protected but no password entered, prompt user
            if isPasswordProtected && rarPassword.isEmpty {
                alertMessage = "This RAR file is password protected. Please enter the password."
                showAlert = true
                print(alertMessage)
                return
            }
            
            // Create extraction folder
            try FileManager.default.createDirectory(at: extractPath, withIntermediateDirectories: true)

            let entries = try archive.entries()
            totalEntries = entries.count
            extractionProgress = 0.0

            for (index, entry) in entries.enumerated() {
                // Determine a safe filename for the entry without relying on a specific property
                let entryNameRaw: String
                // Try to find a sensible string property on `Entry` via reflection
                let mirror = Mirror(reflecting: entry)
                if let found = mirror.children.compactMap({ $0.value as? String }).first(where: { $0.contains(".") || !$0.contains(" ") }) {
                    entryNameRaw = found
                } else {
                    // Fallback: try to extract filename from the debug description (quoted part), otherwise generate a random name
                    let desc = String(describing: entry)
                    if let firstQuote = desc.firstIndex(of: "\""), let secondQuote = desc[firstQuote...].dropFirst().firstIndex(of: "\"") {
                        let range = desc.index(after: firstQuote)..<secondQuote
                        entryNameRaw = String(desc[range])
                    } else {
                        entryNameRaw = "file-\(UUID().uuidString.prefix(8))"
                    }
                }
                
                let entryName = entryNameRaw
                    .replacingOccurrences(of: ":", with: "-")
                    .replacingOccurrences(of: "/", with: "_")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let entryDestination = extractPath.appendingPathComponent(entryName)
                
                // Ensure parent directory exists
                let parentDir = entryDestination.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
                
                // Extract entry to memory and write to disk
                let data = try archive.extract(entry)
                try data.write(to: entryDestination)
                
                extractionProgress = Double(index + 1) / Double(max(totalEntries, 1))
            }
            alertMessage = "File extracted successfully!"
            showAlert = true
            print(alertMessage)
        } catch {
            // Handle errors during extraction
            alertMessage = "Failed to extract file: \(error.localizedDescription)"
            showAlert = true
            print(alertMessage)
        }
    }
}

#Preview {
    UnRarView()
}
