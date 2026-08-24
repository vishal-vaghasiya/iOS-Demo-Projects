//
//  PDFAnnotationWithPath.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit
import PDFKit

extension PDFAnnotation {
    
    func contains(point: CGPoint) -> Bool {
        var hitPath: CGPath?
        
        if let path = paths?.first {
            hitPath = path.cgPath.copy(strokingWithWidth: 10.0, lineCap: .round, lineJoin: .round, miterLimit: 1)
        }
        
        return hitPath?.contains(point) ?? false
    }
}
