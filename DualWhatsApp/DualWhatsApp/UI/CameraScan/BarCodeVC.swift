//
//  BarCodeVC.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 15/10/25.
//

import UIKit

class BarCodeVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var lblUrl: UILabel!
    
    // MARK: - PROPERTY
    var urlStr: String = ""
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblUrl.text = self.urlStr
        self.title = "Barcode Scanner"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickOpenURL(_ sender: UIButton) {
        if let url = URL(string: self.urlStr) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func clickCopy(_ sender: UIButton) {
        copyText(self.urlStr, vc: self)
    }
    
    @IBAction func clickShare(_ sender: UIButton) {
        shareText(self.urlStr, from: self)
    }
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
