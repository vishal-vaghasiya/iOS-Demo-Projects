//
//  UIViewController + Extensions.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String = "", message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Alright", style: .cancel))
        self.present(alert, animated: true)
    }
}
