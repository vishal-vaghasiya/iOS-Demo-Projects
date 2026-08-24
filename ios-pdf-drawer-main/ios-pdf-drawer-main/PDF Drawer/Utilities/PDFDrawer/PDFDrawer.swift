//
//  PDFDrawer.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import Foundation
import PDFKit

enum DrawingTool: Int {
    case eraser = 0
    case pencil = 1
    case pen = 2
    case highlighter = 3
    case hand = 4
    
    var width: CGFloat {
        switch self {
        case .pencil:
            return 1
        case .pen:
            return 5
        case .highlighter:
            return 10
        default:
            return 0
        }
    }
    
    var alpha: CGFloat {
        switch self {
        case .highlighter:
            return 0.3
        default:
            return 1
        }
    }
}

class PDFDrawer {
    weak var pdfView: PDFView!
    private var path: UIBezierPath?
    private var currentAnnotation : DrawingAnnotation?
    var currentPage: PDFPage?
    var color: UIColor = .appBlue
    var drawingTool = DrawingTool.pen
}

extension PDFDrawer: DrawingGestureRecognizerDelegate {
    func gestureRecognizerBegan(_ location: CGPoint) {
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        currentPage = page
        let convertedPoint = pdfView.convert(location, to: currentPage!)
        path = UIBezierPath()
        path?.move(to: convertedPoint)
    }
    
    func gestureRecognizerMoved(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        
        /// Eraser
        if drawingTool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        
        /// Hand
        if drawingTool == .hand {
            moveAnnotation(to: convertedPoint, page: page)
            return
        }
        
        path?.addLine(to: convertedPoint)
        path?.move(to: convertedPoint)
        drawAnnotation(onPage: page)
    }
    
    func gestureRecognizerEnded(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        
        /// Erasing
        if drawingTool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        
        /// Drawing
        guard let _ = currentAnnotation else { return }
        
        path?.addLine(to: convertedPoint)
        path?.move(to: convertedPoint)
        
        // Final annotation
        page.removeAnnotation(currentAnnotation!)
        let _ = createFinalAnnotation(path: path!, page: page)
        currentAnnotation = nil
    }
    
    private func createAnnotation(path: UIBezierPath, page: PDFPage) -> DrawingAnnotation {
        let border = PDFBorder()
        border.lineWidth = drawingTool.width
        
        let annotation = DrawingAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
        annotation.color = color.withAlphaComponent(drawingTool.alpha)
        annotation.border = border
        return annotation
    }
    
    private func drawAnnotation(onPage: PDFPage) {
        guard let path = path else { return }
        
        if currentAnnotation == nil {
            currentAnnotation = createAnnotation(path: path, page: onPage)
        }
        
        currentAnnotation?.path = path
        forceRedraw(annotation: currentAnnotation!, onPage: onPage)
    }
    
    private func createFinalAnnotation(path: UIBezierPath, page: PDFPage) -> PDFAnnotation {
        let border = PDFBorder()
        border.lineWidth = drawingTool.width
        
        let bounds = CGRect(x: path.bounds.origin.x - 5,
                            y: path.bounds.origin.y - 5,
                            width: path.bounds.size.width + 10,
                            height: path.bounds.size.height + 10)
        let signingPathCentered = UIBezierPath()
        signingPathCentered.cgPath = path.cgPath
        _ = signingPathCentered.moveCenter(to: bounds.center)
        
        let annotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: nil)
        annotation.color = color.withAlphaComponent(drawingTool.alpha)
        annotation.border = border
        annotation.add(signingPathCentered)
        page.addAnnotation(annotation)
        
        return annotation
    }
    
    private func removeAnnotationAtPoint(point: CGPoint, page: PDFPage) {
        if let selectedAnnotation = page.annotationWithHitTest(at: point) {
            selectedAnnotation.page?.removeAnnotation(selectedAnnotation)
        }
    }
    
    private func forceRedraw(annotation: PDFAnnotation, onPage: PDFPage) {
        onPage.removeAnnotation(annotation)
        onPage.addAnnotation(annotation)
    }
}

extension PDFDrawer {
    func removeLastAnnotation(page: PDFPage) {
        currentPage = page
        guard let pageToEdit = currentPage else { return }
        
        if let lastAnnotation = pageToEdit.annotations.last {
            page.removeAnnotation(lastAnnotation)
        }
    }
    
    func moveAnnotation(to point: CGPoint, page: PDFPage) {
        guard let pageToEdit = currentPage else { return }
        
        if let lastAnnotation = pageToEdit.annotations.last {
            lastAnnotation.bounds.origin.x = point.x - lastAnnotation.bounds.size.width / 2
            lastAnnotation.bounds.origin.y = point.y - lastAnnotation.bounds.size.height / 2
            forceRedraw(annotation: lastAnnotation, onPage: pageToEdit)
        }
    }
    
    func resizeLastAnnotation(byPercentage percentage: CGFloat, on page: PDFPage) {
        
        guard let currentPage = currentPage, let lastAnnotation = currentPage.annotations.last else {
            return
        }
        
        let originalBounds = lastAnnotation.bounds
        
        let newWidth = originalBounds.width + (originalBounds.width * percentage)
        let newHeight = originalBounds.height + (originalBounds.height * percentage)
        let newBounds = CGRect(x: originalBounds.origin.x,
                               y: originalBounds.origin.y,
                               width: newWidth,
                               height: newHeight)
        
        if percentage == 0.1 && newWidth < 600 { // Zoom in (+)
            lastAnnotation.bounds = newBounds
            forceRedraw(annotation: lastAnnotation, onPage: currentPage)
            
        } else if percentage == -0.1 && newWidth > 150 { // Zoom out (-)
            
            lastAnnotation.bounds = newBounds
            forceRedraw(annotation: lastAnnotation, onPage: currentPage)
        }
    }
    
    func resizeLastAnnotation(bySize size: CGFloat, on page: PDFPage) {
        
        guard let currentPage = currentPage, let lastAnnotation = currentPage.annotations.last else {
            return
        }
        
        let originalBounds = lastAnnotation.bounds
        let newBounds = CGRect(x: originalBounds.origin.x,
                               y: originalBounds.origin.y,
                               width: size,
                               height: size)
        
        lastAnnotation.bounds = newBounds
        forceRedraw(annotation: lastAnnotation, onPage: currentPage)
    }
}
