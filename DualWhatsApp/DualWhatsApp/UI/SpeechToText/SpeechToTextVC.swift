//
//  SpeechToTextVC.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 10/10/25.
//

import UIKit

class SpeechToTextVC: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var btnStartStop: UIButton!
    @IBOutlet weak var txtMessage: UITextView!
    
    // MARK: - PROPERTY
    var isStart: Bool = false
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Speech To Text"
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UI SETUP
    
    func setup() {
        SpeechManager.shared.requestPermission { granted in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
        SpeechManager.shared.onTranscription = { [weak self] text in
            self?.txtMessage.text = text
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickStartStop(_ sender: UIButton) {
        self.isStart = !self.isStart
        if self.isStart {
            self.btnStartStop.setTitle("Stop", for: .normal)
            do {
                try SpeechManager.shared.startRecording()
            } catch {
                print("Failed to start recording: \(error.localizedDescription)")
            }
        } else {
            self.btnStartStop.setTitle("Start", for: .normal)
            SpeechManager.shared.stopRecording()
        }
    }
    
    @IBAction func clickCopy(_ sender: UIButton) {
        let txt = self.txtMessage.text ?? ""
        if txt != "" {
            copyText(txt, vc: self)
        }
    }
    
    @IBAction func clickShare(_ sender: UIButton) {
        let txt = self.txtMessage.text ?? ""
        if txt != "" {
            shareText(txt, from: self)
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
