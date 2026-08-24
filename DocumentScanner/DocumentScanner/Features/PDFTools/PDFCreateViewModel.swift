//
//  PDFCreateViewModel.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
internal import Combine

@MainActor
class PDFCreateViewModel: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    @Published var textInput: String = ""
    @Published var fileName: String = ""
    @Published var docTitle: String = ""
    @Published var isProcessing = false
    @Published var successFile: SavedFile? = nil
    @Published var errorMessage: String? = nil
    
    private let pdfUseCase: ProcessPDFUseCase
    
    init(pdfUseCase: ProcessPDFUseCase = ProcessPDFUseCase()) {
        self.pdfUseCase = pdfUseCase
    }
    
    func generatePDFFromImages() async {
        guard !selectedImages.isEmpty else {
            errorMessage = "Please select at least one image."
            return
        }
        
        isProcessing = true
        errorMessage = nil
        successFile = nil
        
        let preferredName = fileName.trimmingCharacters(in: .whitespaces).isEmpty ? "pdf_from_images" : fileName
        
        do {
            let savedFile = try await pdfUseCase.createPDFFromImages(images: selectedImages, preferredName: preferredName)
            successFile = savedFile
            selectedImages.removeAll()
            fileName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    func generatePDFFromText() async {
        guard !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text."
            return
        }
        
        isProcessing = true
        errorMessage = nil
        successFile = nil
        
        let preferredName = fileName.trimmingCharacters(in: .whitespaces).isEmpty ? "pdf_from_text" : fileName
        let title = docTitle.trimmingCharacters(in: .whitespaces).isEmpty ? "Untitled Document" : docTitle
        
        do {
            let savedFile = try await pdfUseCase.createPDFFromText(text: textInput, title: title, preferredName: preferredName)
            successFile = savedFile
            textInput = ""
            fileName = ""
            docTitle = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }
}
