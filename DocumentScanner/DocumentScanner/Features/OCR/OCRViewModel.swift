//
//  OCRViewModel.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
internal import Combine

@MainActor
class OCRViewModel: ObservableObject {
    @Published var selectedImage: UIImage? = nil
    @Published var recognizedText: String = ""
    @Published var isProcessing = false
    @Published var successFile: SavedFile? = nil
    @Published var errorMessage: String? = nil
    
    private let ocrUseCase: PerformOCRUseCase
    
    init(ocrUseCase: PerformOCRUseCase = PerformOCRUseCase()) {
        self.ocrUseCase = ocrUseCase
    }
    
    func runOCR() async {
        guard let image = selectedImage else {
            errorMessage = "Please select or capture an image first."
            return
        }
        
        isProcessing = true
        errorMessage = nil
        successFile = nil
        recognizedText = ""
        
        do {
            let text = try await ocrUseCase.performOCR(on: image)
            if text.isEmpty {
                errorMessage = Strings.OCR.noTextFound
            } else {
                recognizedText = text
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    func copyToClipboard() {
        UIPasteboard.general.string = recognizedText
    }
    
    func saveOCRResult(preferredName: String) {
        guard !recognizedText.isEmpty else { return }
        
        errorMessage = nil
        successFile = nil
        
        do {
            let file = try ocrUseCase.saveOCRResult(text: recognizedText, preferredName: preferredName)
            successFile = file
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
