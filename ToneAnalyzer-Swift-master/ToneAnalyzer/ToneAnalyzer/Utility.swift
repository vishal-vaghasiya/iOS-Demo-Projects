//  Utility.swift
//  Nest
//
//  Created by Kamini Jaiswal on 8/17/17.
//  Copyright © 2017 Hitesh Prajapati. All rights reserved.

import UIKit
import Foundation

class Utility {
    var window: UIWindow?
    
    class func showAlert(_ title: String?, message: String?, viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction) in
        }))
        viewController.present(alertController, animated: true, completion: nil)
    }
}
