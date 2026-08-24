//
//  Document + PDF.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import Foundation
import PDFKit

extension DocumentController {
    
    func loadPDF() {
        guard let path = Bundle.main.url(forResource: "example", withExtension: "pdf") else {
            showAlert(message: "Can't locate file path to load pdf")
            return
        }
        pdfView.document = PDFDocument(url: path)
    }
    
    // MARK: - Saving
    func exportDocumentAsFile() {
        guard let path = Bundle.main.url(forResource: "example", withExtension: "pdf") else {
            showAlert(message: "Can't locate file path to save pdf")
            return
        }
        
        
        if let data = thumbnailView.pdfView?.document?.dataRepresentation() {
            do {
                try data.write(to: path)
                print("PDF exported successfully. Path: \(path)")
                showAlert(title: "PDF Saved!", message: "\nPDF successfully saved at path: \n\(path)")
            } catch {
                print("Error exporting PDF: \(error.localizedDescription)")
            }
        }
    }
    
    // for further use
    func exportDocumentAsBase64() {
        guard let path = Bundle.main.url(forResource: "example", withExtension: "pdf") else {
            showAlert(message: "Can't locate file path to save pdf")
            return
        }
        
        if let data = pdfDrawer.pdfView.document?.dataRepresentation() {
            do {
                try data.write(to: path)
                print("PDF exported successfully. Path: \(path)")
            } catch {
                print("Error exporting PDF: \(error.localizedDescription)")
            }
        }
    }
    
}
