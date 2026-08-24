//
//  PDFPage + Extensions.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit
import PDFKit

extension PDFPage {
    func annotationWithHitTest(at: CGPoint) -> PDFAnnotation? {
        for annotation in annotations {
            if annotation.contains(point: at) {
                return annotation
            }
        }
        return nil
    }
}
