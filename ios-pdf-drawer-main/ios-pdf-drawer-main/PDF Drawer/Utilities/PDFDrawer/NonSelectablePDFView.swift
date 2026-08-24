//
//  NonSelectablePDFView.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit
import PDFKit

class NonSelectablePDFView: PDFView {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        
        super.addGestureRecognizer(gestureRecognizer)
    }
}
