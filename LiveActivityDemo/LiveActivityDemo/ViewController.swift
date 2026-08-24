//
//  ViewController.swift
//  LiveActivityDemo
//
//  Created by Nexios02 on 31/05/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var txtPushToken: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    
    let deviceToken = "4093dd43f7e97b952d11a5bb9ca75d234e51fa0fe9509f612d07bbe90fe1b2bb"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func startActivityClick(_ sender: UIButton) {
        LiveActivityManager.shared.pushToStartLiveActicity(deviceToken: deviceToken) { status in
            DispatchQueue.main.async {
                self.lblStatus.text = status + ":: \(Date())"
            }
        }
    }
    
    @IBAction func updateActivityClick(_ sender: UIButton) {
        let pushToken = txtPushToken.text ?? ""
        LiveActivityManager.shared.updateLiveActicity(pushToken: pushToken) { status in
            DispatchQueue.main.async {
                self.lblStatus.text = status + ":: \(Date())"
            }
        }
    }
    
    @IBAction func endActivityClick(_ sender: UIButton) {
        let pushToken = txtPushToken.text ?? ""
        LiveActivityManager.shared.endLiveActicity(pushToken: pushToken) { status in
            DispatchQueue.main.async {
                self.lblStatus.text = status + ":: \(Date())"
            }
        }
    }
}
