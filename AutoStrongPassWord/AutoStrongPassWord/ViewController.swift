//
//  ViewController.swift
//  AutoStrongPassWord
//
//  Created by Nexios Mac 4 on 23/04/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtPassword.passwordRules = UITextInputPasswordRules(descriptor: "minlength: 8; maxlength: 30; required: lower; required: upper; required: digit; required: special;")
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            print(self.txtPassword.text ?? "")
        }
    }

    @IBAction func btnEye(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        txtPassword.isSecureTextEntry = sender.isSelected
    }
    
    @IBAction func didTapButtonCopy(_ sender: Any) {
        lblText.text = txtPassword.text
    }
    
}

