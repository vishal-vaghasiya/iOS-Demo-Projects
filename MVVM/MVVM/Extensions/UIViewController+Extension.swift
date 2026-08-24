//
//  UIViewController+Extension.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import UIKit

extension UIViewController {
    func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
