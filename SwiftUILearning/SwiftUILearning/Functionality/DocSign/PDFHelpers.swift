//
//  PDFHelpers.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 05/11/25.
//

import UIKit
import PDFKit

enum PDFHelpers {
    static func mergeSignatureIntoPDF(originalPDF: PDFDocument, signatureImage: UIImage, on pageIndex: Int = 0) -> PDFDocument? {
        guard let page = originalPDF.page(at: pageIndex) else { return nil }
        let bounds = page.bounds(for: .mediaBox)
        
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let newPageImage = renderer.image { ctx in
            page.draw(with: .mediaBox, to: ctx.cgContext)
            signatureImage.draw(in: CGRect(x: 100, y: 100, width: 150, height: 75)) // Position of signature
        }
        
        let newDoc = PDFDocument()
        if let newPage = PDFPage(image: newPageImage) {
            newDoc.insert(newPage, at: 0)
        }
        return newDoc
    }
}
