//
//  CustomActivityController.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit

class CustomActivityViewController: UIActivityViewController {
    
    private let controller: UIViewController!
    
    required init(controller: UIViewController) {
        self.controller = controller
        super.init(activityItems: [], applicationActivities: nil)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let subViews = self.view.subviews
        for view in subViews {
            view.removeFromSuperview()
        }
        
        self.addChild(controller)
        self.view.addSubview(controller.view)
    }
    
}

extension UIViewController {
    enum Detent: CaseIterable {
        case medium
        case large
    }
    
    /// Presents a view modally (As sheet) with optional detent size.
    ///
    /// - Parameters:
    ///   - viewControllerToPresent: The view controller to be presented.
    ///   - detents: An array of Detent options. Default is [.medium, .large].
    func presentViewModally(_ viewControllerToPresent: UIViewController,
                            detents: [Detent] = [.medium, .large]) {
        if #available(iOS 15.0, *) {
            let sheet = viewControllerToPresent.sheetPresentationController
            
            // Convert Detents to UISheetPresentationController.Detent
            let sheetDetents: [UISheetPresentationController.Detent] = detents.map { detent in
                switch detent {
                case .medium:
                    return .medium()
                case .large:
                    return .large()
                }
            }
            
            sheet?.detents = sheetDetents
            sheet?.prefersGrabberVisible = true
            sheet?.preferredCornerRadius = 24
            present(viewControllerToPresent, animated: true)
        } else {
            let activityViewController = CustomActivityViewController(controller: viewControllerToPresent)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
}
