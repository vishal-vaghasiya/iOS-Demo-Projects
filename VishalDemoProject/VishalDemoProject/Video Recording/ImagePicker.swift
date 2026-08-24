//
//  ImagePicker.swift
//  HomeCare
//
//  Created by VISHAL VAGHASIYA on 31/07/21.
//  Copyright © 2021 VISHAL VAGHASIYA. All rights reserved.
//

/*
 let imagePicker:ImagePicker?
 
 // Did Load
 self.imagePicker = ImagePicker(presentationController: self, delegate: self)
 
 self.imagePicker?.present(from: self.view, isOnlyPhoto: true)
 
 extension ProfileCaseManager: ImagePickerDelegate {
 func didSelect(image: UIImage?) {
 
 }
 }
 */

import UIKit
import Photos
import MobileCoreServices
public protocol ImagePickerDelegate: class {
    func didSelectVideo(url: URL?)
    func didCancel()
}

open class ImagePicker: NSObject {
    
    private var pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    var timeLabel: UILabel!
    var timer: Timer!
    var timeLimit: TimeInterval = 10.0 // set the time limit to 10 seconds
    var remainingTime: TimeInterval = 0.0
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.videoMaximumDuration = 10 // In second
        self.pickerController.allowsEditing = true

        timeLabel = UILabel(frame: CGRect(x: 10, y: 20, width: 100, height: 20))
        timeLabel.text = "10.0"
        timeLabel.backgroundColor = .red
        pickerController.view.addSubview(timeLabel)

    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            if type == .camera {
                checkCameraPermission { }
            }
            return nil
        }
        return UIAlertAction(title: title, style: .default) { [self] _ in
            if type == .camera {
                checkCameraPermission {
                    DispatchQueue.main.async {
                        self.pickerController.sourceType = type
                        self.pickerController.mediaTypes = [kUTTypeMovie as String]
                        self.pickerController.cameraCaptureMode = .video // Default media type .photo vs .video
                        self.pickerController.cameraDevice = .rear // rear Vs front
                        self.pickerController.cameraFlashMode = .auto // on, off Vs auto
                        
                        //self.pickerController.modalPresentationStyle = .fullScreen
                        self.presentationController?.present(self.pickerController, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func updateTimer() {
        remainingTime -= 1.0
        let remainingSeconds = Int(remainingTime)
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        if remainingTime <= 0.0 {
            timer.invalidate()
            pickerController.stopVideoCapture()
        }
    }
    
    public func present(from sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let action = self.action(for: .camera, title: "Video Recording") {
            alertController.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = []
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, videoURL:URL) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true, completion: {
                self.delegate?.didSelectVideo(url: videoURL)
            })
        }
    }
    
    private func checkCameraPermission(completion:@escaping()->()){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            self.alertPromptToAllowCameraAccessViaSettings()
        case .restricted:
            print("device owner must approve")
        case .authorized:
            completion()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    completion()
                } else {
                    DispatchQueue.main.async {
                        print("Permission denied")
                    }
                }
            }
        @unknown default:
            fatalError()
        }
    }
    
    private func alertPromptToAllowCameraAccessViaSettings() {
        let alert = UIAlertController(title: "Would Like To Access the Camera", message: "Please grant permission to use the Camera so that you can customer benefit.", preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .cancel) { alert in
            if let appSettingsURL = NSURL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettingsURL as URL, options: [:], completionHandler: nil)
            }
        })
        DispatchQueue.main.async {
            self.presentationController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            self.delegate?.didCancel()
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didStartCapturingVideo camera: UIImagePickerController) {
        // Start the timer when video recording starts
        self.remainingTime = self.timeLimit
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        switch mediaType {
        case kUTTypeMovie:
            let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            DispatchQueue.main.async {
                encodeVideo(at: videoURL) { url, error in
                    if error == nil {
                        if let videoURL = url {
                            self.pickerController(picker, videoURL: videoURL)
                        }
                    }
                }
            }
        default:
            print("Mismatched type: \(mediaType)")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

func encodeVideo(at videoURL: URL, compressionType : String = AVAssetExportPresetPassthrough ,completionHandler: ((URL?, Error?) -> Void)?)  {
    let avAsset = AVURLAsset(url: videoURL, options: nil)

    let startDate = Date()

    //Create Export session
    guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: compressionType) else {
        completionHandler?(nil, nil)
        return
    }

    //Creating temp path to save the converted video
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
    let newFileName = (videoURL.deletingPathExtension().lastPathComponent) + ".mp4"
    //print(newFileName)
    let filePath = documentsDirectory.appendingPathComponent(newFileName)

    //Check if the file already exists then remove the previous file
    if FileManager.default.fileExists(atPath: filePath.path) {
        do {
            try FileManager.default.removeItem(at: filePath)
        } catch {
            completionHandler?(nil, error)
        }
    }

    exportSession.outputURL = filePath
    exportSession.outputFileType = AVFileType.mp4
    exportSession.shouldOptimizeForNetworkUse = true
      let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
    let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
    exportSession.timeRange = range

    exportSession.exportAsynchronously(completionHandler: {() -> Void in
        switch exportSession.status {
        case .failed:
            print(exportSession.error ?? "NO ERROR")
            completionHandler?(nil, exportSession.error)
        case .cancelled:
            print("Export canceled")
            completionHandler?(nil, nil)
        case .completed:
            //Video conversion finished
            let endDate = Date()

            let time = endDate.timeIntervalSince(startDate)
            //print(time)
            //print("Successful!")
            //print(exportSession.outputURL ?? "NO OUTPUT URL")
            completionHandler?(exportSession.outputURL, nil)

            default: break
        }

    })
}
