//
//  Document + Drawer.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit
import PDFKit

extension DocumentController {
    
    func drawSignature(base64String: String) {
        let currentPage = thumbnailView.pdfView?.currentPage
        
        guard let data = Data(base64Encoded: base64String) else {
            self.showAlert(message: "Can't draw signature")
            return
        }
        
        let bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 150))
        let image = UIImage(data: data)
        
        let imageAnnotation = ImageAnnotation(bounds: bounds, image: image)
        currentPage?.addAnnotation(imageAnnotation)
        sizeSlider.value = 0
        
        pdfDrawer.currentPage = currentPage
        handButtonClicked(nil)
    }
    
}
