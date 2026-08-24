//
//  RepeatTextVC.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 09/10/25.
//

import UIKit

class RepeatTextVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var txtCount: UITextField!
    @IBOutlet weak var txtCopyView: UITextView!
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Repeat Text"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickGenerate(_ sender: UIButton) {
        let repeateCount = self.txtCount.text?.toInt ?? 0
        let txt = self.txtMessage.text ?? ""
        
        if repeateCount != 0 && txt.count != 0 {
            self.txtCopyView.text = self.repeateText(txt: txt, repeateCount: repeateCount)
        }
    }
    
    @IBAction func clickCopy(_ sender: UIButton) {
        let txt = self.txtCopyView.text ?? ""
        if txt != "" {
            copyText(txt, vc: self)
        }
    }
    
    @IBAction func clickShare(_ sender: UIButton) {
        let txt = self.txtCopyView.text ?? ""
        if txt != "" {
            shareText(txt, from: self)
        }
    }
    
    // MARK: - OTHER
    func repeateText(txt: String, repeateCount: Int) -> String {
        guard repeateCount > 0 else { return "" }
        return Array(repeating: txt, count: repeateCount).joined(separator: " ")
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
