//
//  ImageAnnotation.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit
import PDFKit

public class ImageAnnotation: PDFAnnotation {
    
    private var image: UIImage?
    
    public init(bounds: CGRect, image: UIImage?) {
        self.image = image
        super.init(bounds: bounds, forType: .stamp, withProperties: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(with box: PDFDisplayBox, in context: CGContext) {
        guard let cgImage = self.image?.cgImage else {
            return
        }
        let drawingBox = self.page?.bounds(for: box)
        context.draw(cgImage, in: self.bounds.applying(CGAffineTransform(
            translationX: (drawingBox?.origin.x) ?? 0 * -1.0,
            y: (drawingBox?.origin.y)! * -1.0)))
    }
    
}
