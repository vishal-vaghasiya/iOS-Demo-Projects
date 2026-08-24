//
//  WebWhatsappVC.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 09/10/25.
//

import UIKit
import WebKit

class WebWhatsappVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Daul WhatsApp"
        WebManager.shared.loadWhatsAppWeb(in: self.webView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}
