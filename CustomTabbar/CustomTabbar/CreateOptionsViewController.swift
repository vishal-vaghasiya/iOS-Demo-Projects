//
//  CreateOptionsViewController.swift
//  CustomTabbar
//
//  Created by Nexios Technologies on 16/06/25.
//

import UIKit

class CreateOptionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        view.backgroundColor = .clear // or .white with alpha for transparency
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Let the view layout finish before calculating
        let targetHeight = view.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        ).height
        print(targetHeight)
        preferredContentSize = CGSize(width: view.bounds.width, height: targetHeight)
    }
    
    @IBAction func tapToCloseClick(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

}
