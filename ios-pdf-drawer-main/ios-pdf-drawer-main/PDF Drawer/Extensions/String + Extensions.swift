//
//  String + Extensions.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit
import PDFKit

extension String {
    
    func localize() -> String {
        return Bundle.main.localizedString(forKey: self, value: "", table: nil)
    }
    
    func convertBase64ToPDF() -> PDFDocument? {
        guard let pdfData = Data(base64Encoded: self), let pdfDocument = PDFDocument(data: pdfData) else {
            return nil
        }
        
        return pdfDocument
    }
    
    
    func convertBase64ToImage() -> UIImage? {
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
}
