//
//  PDFCompressViewModel.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
internal import Combine

@MainActor
class PDFCompressViewModel: ObservableObject {
    @Published var selectedUrl: URL? = nil
    @Published var compressionQuality: CGFloat = 0.5 // Default to medium
    @Published var fileName: String = ""
    @Published var isProcessing = false
    @Published var successFile: SavedFile? = nil
    @Published var errorMessage: String? = nil
    
    private let pdfUseCase: ProcessPDFUseCase
    
    init(pdfUseCase: ProcessPDFUseCase = ProcessPDFUseCase()) {
        self.pdfUseCase = pdfUseCase
    }
    
    func selectPDF(url: URL) {
        selectedUrl = url
        successFile = nil
        errorMessage = nil
    }
    
    func compressPDF() async {
        guard let url = selectedUrl else {
            errorMessage = "No PDF file selected."
            return
        }
        
        isProcessing = true
        errorMessage = nil
        successFile = nil
        
        let preferredName = fileName.trimmingCharacters(in: .whitespaces).isEmpty ? "compressed_document" : fileName
        
        do {
            let savedFile = try await pdfUseCase.compressPDF(url: url, quality: compressionQuality, preferredName: preferredName)
            successFile = savedFile
            fileName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
}
