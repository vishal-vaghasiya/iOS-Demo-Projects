//
//  Helper+UIViewController.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation
import UIKit

extension UIViewController{
    func goBack(animated: Bool = true){
        self.navigationController?.popViewController(animated: animated)
    }
}
