//
//  DetactVisitingCardVC.swift
//  VishalDemoProject
//
//  Created by Nexios Technologies on 30/12/25.
//

import UIKit

class DetactVisitingCardVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    
    // MARK: - PROPERTY
    let moderator = ImageContentModerator()
    private var selectedImage: UIImage? = nil
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func selectImageClick(_ sender: UIButton) {
        chooseImage()
    }
    
    @IBAction func startAnalyzeClick(_ sender: UIButton) {
        detactVisitingCard()
    }
    
    // MARK: - OTHER
    func detactVisitingCard() {
        if let image = selectedImage {
            moderator.analyze(
                image: image,
                watchBrand: "Audemars Piguet"
            ) { decision in
                DispatchQueue.main.async {
                    switch decision {
                    case .allow:
                        print("allow")
                        self.lblMessage.text = "Allow"
                    case .warn(let message):
                        print("Warn: \(message)")
                        self.lblMessage.text = "Warn: \(message)"
                    case .block(let message):
                        print("Block: \(message)")
                        self.lblMessage.text = "Block: \(message)"
                    }
                }
            }
        }
    }
    
    // MARK: - API CALLING
    func chooseImage() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)

        // Option 1: Select from Photo Library
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))

        // Option 2: Capture with Camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.presentImagePicker(sourceType: .camera)
            }))
        }

        // Cancel Option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
    
    // Helper function to present image picker
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - DELEGATE

}
extension DetactVisitingCardVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.selectedImage = info[.editedImage] as? UIImage
        self.selectedImageView.image = self.selectedImage
        self.lblMessage.text = ""
        picker.dismiss(animated: true)
    }
}
