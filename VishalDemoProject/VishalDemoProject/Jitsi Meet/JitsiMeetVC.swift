//
//  JitsiMeetVC.swift
//  VishalDemoProject
//
//  Created by Nexios02 on 07/06/24.
//

import UIKit

class JitsiMeetVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func startMeetingClick(_ sender: UIButton) {
        JitsiMeetManager.shared.meetingID = "Vishal_Vaghasiya"
        JitsiMeetManager.shared.startMeeting()
    }
}
