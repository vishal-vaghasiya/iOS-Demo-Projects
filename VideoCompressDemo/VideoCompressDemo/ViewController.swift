//
//  ViewController.swift
//  VideoCompressDemo
//
//  Created by Nexios Mac 4 on 21/05/24.
//

import UIKit
import UniformTypeIdentifiers
import AVFoundation
import AVKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picker = UIImagePickerController()
        picker.mediaTypes = [UTType.movie.identifier]
        picker.delegate = self
        
        let alert = UIAlertController(title: "Selecte Option", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { action in
            picker.sourceType = .camera
            self.present(picker, animated: true)
        }
        let photos = UIAlertAction(title: "Photos", style: .default) { action in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(camera)
        alert.addAction(photos)
        alert.addAction(cancel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.present(alert, animated: true)
        }
    }
    
    func compressVideo(videoURL: URL) {
        let data = NSData(contentsOf: videoURL as URL)!
        print("File size before compression: \(Double(data.length / 1048576)) mb")
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mov")
        compressVideoHelperMethod(inputURL: videoURL , outputURL: compressedURL) { (exportSession) in
            switch exportSession?.status {
            case .completed:
                guard let compressedData = try? Data(contentsOf: compressedURL) else { return }
                print("File size after compression: \(Double(compressedData.count / 1048576)) mb")
                DispatchQueue.main.async {
                    let player = AVPlayer(url: compressedURL)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            default: break
            }
        }
    }
    
    func compressVideoHelperMethod(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset640x480) else {
            handler(nil)
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            picker.dismiss(animated: true) {
                /*
                let config = VideoKit.Config(.preset640x480, limitFPS: 30)
                VideoKit.mutate(videoUrl: videoURL, config: config) { result in
                    switch result {
                    case .success(let url):
                        DispatchQueue.main.async {
                            let player = AVPlayer(url: url)
                            let playerViewController = AVPlayerViewController()
                            playerViewController.player = player
                            self.present(playerViewController, animated: true) {
                                playerViewController.player!.play()
                            }
                        }
                    case .error(let error):
                        print(error)
                    }
                }
                 */
                
                self.compressVideo(videoURL: videoURL)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

