//
//  PDFMergeViewModel.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
internal import Combine

@MainActor
class PDFMergeViewModel: ObservableObject {
    @Published var selectedUrls: [URL] = []
    @Published var fileName: String = ""
    @Published var isProcessing = false
    @Published var successFile: SavedFile? = nil
    @Published var errorMessage: String? = nil
    
    private let pdfUseCase: ProcessPDFUseCase
    
    init(pdfUseCase: ProcessPDFUseCase = ProcessPDFUseCase()) {
        self.pdfUseCase = pdfUseCase
    }
    
    func mergePDFs() async {
        guard selectedUrls.count >= 2 else {
            errorMessage = Strings.PDFTools.selectPdfFiles
            return
        }
        
        isProcessing = true
        errorMessage = nil
        successFile = nil
        
        let preferredName = fileName.trimmingCharacters(in: .whitespaces).isEmpty ? "merged_document" : fileName
        
        do {
            let savedFile = try await pdfUseCase.mergePDFs(urls: selectedUrls, preferredName: preferredName)
            successFile = savedFile
            selectedUrls.removeAll()
            fileName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    func remove(at index: Int) {
        selectedUrls.remove(at: index)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        selectedUrls.move(fromOffsets: source, toOffset: destination)
    }
}
