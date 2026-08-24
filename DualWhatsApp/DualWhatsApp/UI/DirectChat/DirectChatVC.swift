//
//  DirectChatVC.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 09/10/25.
//

import UIKit

class DirectChatVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblPrefix: UILabel!
    @IBOutlet weak var txtNumber: UITextField!
    @IBOutlet weak var txtMessage: UITextView!
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Direct Chat"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickSend(_ sender: UIButton) {
        let number = self.txtNumber.text ?? ""
        if number.count != 0 {
            sendWhatsAppMessage(to: (self.lblPrefix.text ?? "") + number, message: self.txtMessage.text)
        }
    }
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
