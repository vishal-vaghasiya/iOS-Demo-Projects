//
//  SignatureViewModel.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 05/11/25.
//

import SwiftUI
import PencilKit

// MARK: - ViewModel
class SignatureViewModel: ObservableObject {
    @Published var canvasView = PKCanvasView()
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    // MARK: - Clear Canvas
    func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }

    // MARK: - Save Signature as Transparent PNG
    func saveSignature() {
        let drawing = canvasView.drawing
        var bounds = drawing.bounds
        bounds.origin.x = max(bounds.origin.x - 2, 0)
        bounds.origin.y = max(bounds.origin.y - 2, 0)
        bounds.size.width += 4
        bounds.size.height += 4
        guard !bounds.isEmpty else {
            showMessage(title: "Error", message: "No signature detected.")
            return
        }
        let croppedImage = drawing.image(from: bounds, scale: UIScreen.main.scale)
        let image = croppedImage
        guard let pngData = image.pngData() else {
            showMessage(title: "Error", message: "Failed to create PNG data.")
            return
        }

        let filename = "Signature_\(Int(Date().timeIntervalSince1970)).png"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            try pngData.write(to: fileURL)
            showMessage(title: "Success", message: "Signature saved to Documents/\(filename)")
            print("✅ Saved Signature at:", fileURL.path)
        } catch {
            showMessage(title: "Error", message: error.localizedDescription)
        }
    }

    // MARK: - Alert Helper
    private func showMessage(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }

    // MARK: - Document Directory Path
    private func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let signaturesFolder = documentsURL.appendingPathComponent("Signatures")
        
        if !fileManager.fileExists(atPath: signaturesFolder.path) {
            do {
                try fileManager.createDirectory(at: signaturesFolder, withIntermediateDirectories: true, attributes: nil)
                print("✅ Created Signatures directory at: \(signaturesFolder.path)")
            } catch {
                print("❌ Failed to create Signatures directory: \(error.localizedDescription)")
                // Return Documents directory if creation fails
                return documentsURL
            }
        }
        
        return signaturesFolder
    }

}
