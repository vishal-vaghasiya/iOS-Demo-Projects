//
//  LiveActivityVC.swift
//  LiveActivityDemo
//
//  Created by Nexios02 on 31/05/24.
//

import UIKit

class LiveActivityVC: UIViewController {
    @IBOutlet weak var txtPushToken: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    
    let deviceToken = "4b792652174db2b306f92ab00a17d5bb76978914fba27743fbb23f051f614099"
    var distance = 5000
    var timer = Timer()
    var token = ["80edd3b388539827fdd1934f7ca2a897e22e42c66e62a2b59d12a81d892e166938385adb9c97a5f356bde8baff82ceba70127bb740bfe8ab67d1325107df476d4a26c0582d7ece59588375df9dd614fc", "8075321e07317167ae807a5a58c9906752f5322d3dfb6e9f7faeca9c06701abb7f58e19c061256a55ba8fba7ccefdfebf7b082b1ed83afd7098fc6bef5aa986e144037d6be0824849911967e5744a04b", "808f9c75089ea25235d5b5ed632a6174ac7487d392d7bf10e3c25caf55b2c702ee6d958045e112bc95d3a37682dc800c7e56ec8477da39d3184574125e07d1b1bdb7a30903288a4f5f5f14b147ebf018"]
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
        self.token.append(pushToken)
        self.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        distance -= 500
        if distance < 0 {
            self.timer.invalidate()
            let pushToken = txtPushToken.text ?? ""
            LiveActivityManager.shared.endLiveActicity(pushToken: pushToken) { status in
                DispatchQueue.main.async {
                    self.lblStatus.text = status + ":: \(Date())"
                }
            }
        }
//        let pushToken = txtPushToken.text ?? ""
        
        for tk in token {
            LiveActivityManager.shared.updateLiveActicity(pushToken: tk, distance: distance) { status in
                DispatchQueue.main.async {
                    self.lblStatus.text = status + ":: \(Date())"
                }
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
