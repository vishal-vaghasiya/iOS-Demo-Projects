//
//  ViewController.swift
//  VideoDemo
//
//  Created by Nexios02 on 02/05/23.
//

import UIKit
import AVKit
class ViewController: UIViewController {

    @IBOutlet weak var firstNameField: OutlinedFloatingTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameField.placeholder = "First Name"
    }
    
    @IBAction func playClick(_ sender: UIButton) {
        let urlString = "https://myhealth4u.s3.us-east-2.amazonaws.com/video/aed15c8d-d864-4da7-adbb-2f65d67d37cf-202304271343.txt.mp4?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAT3RPWIN3IT46FV7V%2F20230427%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20230427T184354Z&X-Amz-SignedHeaders=host&X-Amz-Expires=604800&X-Amz-Signature=2150a0ae65e955d54292866e3c5920f051c283bacdd692b743088263c128dff6"
        
        let videoURL = NSURL(string: urlString)
        let player = AVPlayer(url: videoURL! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
}

