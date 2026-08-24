//
//  VideoRecordingVC.swift
//  VishalDemoProject
//
//  Created by Nexios02 on 06/06/24.
//

import UIKit

class VideoRecordingVC: UIViewController {

    var imagePicker:ImagePicker?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    @IBAction func startRecordingClick(_ sender: UIButton) {
        self.imagePicker?.present(from: self.view)
    }
}
extension VideoRecordingVC: ImagePickerDelegate {
    func didSelectVideo(url: URL?) {
        print("VIDEO URL:: \(url)")
    }
    
    func didCancel() {
        print("Cancel")
    }
}
