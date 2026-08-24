//
//  CategoryVC.swift
//  VishalDemoProject
//
//  Created by Nexios02 on 06/06/24.
//

import UIKit
import CoreML
import Vision
import SwiftUI
class CategoryVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func openOtherAppCLick(_ sender: UIButton) {
        if let appURL = URL(string: "carecoordinations://open_app"), UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else if let storeURL = URL(string: "https://apps.apple.com/app/id1596737137") {
            UIApplication.shared.open(storeURL, options: [:], completionHandler: nil)
        } else {
            print("app is not available")
        }
    }
    
    @IBAction func createGhibliStyleClick(_ sender: UIButton) {
        
    }
    
    @IBAction func swiftUiAdsClick(_ sender: UIButton) {
        // Create the SwiftUI view
        let adsContentView = AdsContentView()
        
        // Present the SwiftUI view modally
        let hostingController = UIHostingController(rootView: adsContentView)
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
}
