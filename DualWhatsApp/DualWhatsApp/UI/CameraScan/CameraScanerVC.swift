//
//  CameraScanerVC.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 15/10/25.
//

import UIKit
import AVFoundation
import Vision
import PhotosUI

class CameraScanerVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var scannerContainerView: UIView!
    
    // MARK: - PROPERTY
    var isOnTorch: Bool = false
    var scannerView: CameraScannerView!
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Cam Scanner"
        self.setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UI SETUP
    func setUp() {
        self.scannerView = CameraScannerView(frame: self.scannerContainerView.bounds)
        self.scannerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.scannerView.onCodeScanned = { code in
            print("✅ Scanned Code: \(code)")
            self.showBarCodeScreen(urlStr: code)
        }
        
        self.scannerContainerView.addSubview(self.scannerView)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickTorch(_ sender: UIBarItem) {
        self.isOnTorch = !self.isOnTorch
        self.toggleTorch(on: self.isOnTorch)
    }
    
    @IBAction func clickPhotos(_ sender: UIBarItem) {
        self.presentPhotoPicker()
    }
    
    // MARK: - OTHER
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            print("Torch not available")
            return
        }
        
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: 1.0) // 1.0 = full brightness
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error.localizedDescription)")
        }
    }
    
    @available(iOS 14, *)
    func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func detectQRCode(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNDetectBarcodesRequest { request, error in
            if let results = request.results as? [VNBarcodeObservation], !results.isEmpty {
                for barcode in results {
                    if let payload = barcode.payloadStringValue {
                        print("✅ QR Code Detected: \(payload)")
                        self.showBarCodeScreen(urlStr: payload)
                    }
                }
            } else {
                print("No QR code found")
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    func showBarCodeScreen(urlStr: String) {
        let vc = StoryboardScene.CameraScan.barCodeVC.instantiate()
        vc.urlStr = urlStr
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
}

extension CameraScanerVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.detectQRCode(in: image)
                }
            }
        }
    }
}
