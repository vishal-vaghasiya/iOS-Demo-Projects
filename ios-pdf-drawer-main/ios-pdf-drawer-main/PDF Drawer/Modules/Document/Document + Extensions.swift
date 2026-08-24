//
//  Document + Extensions.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit

extension DocumentController {
    
    func setupPencilColor() {
        pdfDrawer.drawingTool = .pen
        setActiveButton(pencilButton, color: pdfDrawer.color)
        setActiveZoomButton(checkLastAnnotation: false)
        
        let image = UIImage(systemName: "circlebadge.fill")
        
        var elements: [UIAction] = []
        let colors: [UIColor] = [.appBlue, .black, .appGreen, .red, .orange, .purple]
        let names: [String?] = ["Blue", "Black", "Green", "Red", "Orange", "Purple"]
        
        for (index, color) in colors.enumerated() {
            
            let action = UIAction(title: names[index] ?? color.accessibilityName.capitalized,
                                  image: image?.withTintColor(color, renderingMode: .alwaysOriginal),
                                  attributes: [], state: pdfDrawer.color == color ? .on : .off) { _ in
                self.pdfDrawer.color = color
                self.setupPencilColor()
            }
            elements.append(action)
        }
        let menu = UIMenu(title: "", children: elements)
        
        pencilButton.showsMenuAsPrimaryAction = true
        pencilButton.menu = menu
    }
    
    // MARK: - Active Buttons
    func setActiveButton(_ button: UIButton, color: UIColor = .appBlue) {
        handButton.layer.borderWidth = 0
        pencilButton.layer.borderWidth = 0
        
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 30
        button.layer.borderColor = color.cgColor
        
    }
    
    func setActiveZoomButton(checkLastAnnotation: Bool = true) {
        
        sizeSlider.isHidden = true
        var isActive = false
        if checkLastAnnotation {
            if let lastAnnotation = thumbnailView.pdfView?.currentPage?.annotations.last {
                let type = lastAnnotation.type
                isActive = type == "Stamp"
            }
        }
        
        let alpha = isActive ? 1 : 0.2
        for button in zoomButtons {
            button.isUserInteractionEnabled = isActive
            button.alpha = alpha
        }
    }
}
