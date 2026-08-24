//
//  WhatsCroppingVC.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 13/10/25.
//

import UIKit
import CropViewController

class WhatsCroppingVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {

    // MARK: - OUTLET
    @IBOutlet weak var imgPreview: UIImageView!
    
    // MARK: - PROPERTY
    private var croppingStyle = CropViewCroppingStyle.default
    var cropImage: UIImage?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WhatsApp Cropping"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = false // ❌ Important: remove crop screen
            present(picker, animated: true)
        } else {
            print("Camera not available")
        }
    }
    
    @IBAction func clickPhotos(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false // ❌ Important: remove crop screen
            present(picker, animated: true)
        }
    }
    
    @IBAction func saveButtonClick(_ sender: UIBarButtonItem) {
        if let image = self.cropImage {
            saveImageToAlbum(image, vc: self)
        }
    }
    
    // MARK: - OTHER
    func openCropView(img: UIImage) {
        let cropVC = CropViewController(image: img)
        cropVC.delegate = self
//        cropVC.aspectRatioPreset = .presetSquare // Optional: force square
        cropVC.aspectRatioLockEnabled = false // Optional: allow free cropping
        present(cropVC, animated: true)
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
    // MARK:- UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let originalImage = info[.originalImage] as? UIImage {
            self.openCropView(img: originalImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK:- CropViewControllerDelegate
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // Cropped image
        self.cropImage = image
        self.imgPreview.image = image
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController) {
        cropViewController.dismiss(animated: true)
    }
    
}
