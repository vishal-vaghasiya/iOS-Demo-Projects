//
//  PDFSplitViewModel.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
import PDFKit
internal import Combine

@MainActor
class PDFSplitViewModel: ObservableObject {
    @Published var selectedUrl: URL? = nil
    @Published var pageCount = 0
    @Published var selectedPages = IndexSet()
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
        selectedPages.removeAll()
        successFile = nil
        errorMessage = nil
        
        if let doc = PDFDocument(url: url) {
            pageCount = doc.pageCount
        } else {
            pageCount = 0
            errorMessage = "Failed to load the selected PDF."
        }
    }
    
    func togglePageSelection(index: Int) {
        if selectedPages.contains(index) {
            selectedPages.remove(index)
        } else {
            selectedPages.insert(index)
        }
    }
    
    func selectAllPages() {
        selectedPages = IndexSet(integersIn: 0..<pageCount)
    }
    
    func deselectAllPages() {
        selectedPages.removeAll()
    }
    
    func splitPDF() async {
        guard let url = selectedUrl else {
            errorMessage = "No PDF file selected."
            return
        }
        
        guard !selectedPages.isEmpty else {
            errorMessage = "Please select at least one page to extract."
            return
        }
        
        isProcessing = true
        errorMessage = nil
        successFile = nil
        
        let preferredName = fileName.trimmingCharacters(in: .whitespaces).isEmpty ? "extracted_pages" : fileName
        
        do {
            let savedFile = try await pdfUseCase.splitPDF(url: url, pageIndices: selectedPages, preferredName: preferredName)
            successFile = savedFile
            selectedPages.removeAll()
            fileName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
}
