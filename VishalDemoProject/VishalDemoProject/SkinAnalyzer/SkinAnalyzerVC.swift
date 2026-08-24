//
//  SkinAnalyzerVC.swift
//  VishalDemoProject
//
//  Created by Nexios Technologies on 14/07/25.
//

import UIKit

class SkinAnalyzerVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var selectedImageView: UIImageView!
    
    // MARK: - PROPERTY
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
        analyzeTapped()
    }
    
    // MARK: - OTHER
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
    
    func analyzeTapped() {
        if let image = selectedImage {
            do {
                try SkinAnalyzer().classify(image: image) { [weak self] results in
                    DispatchQueue.main.async {
                        print(results)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "ResultVC") as! ResultVC
                        vc.results = results
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension SkinAnalyzerVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.selectedImage = info[.editedImage] as? UIImage
        self.selectedImageView.image = self.selectedImage
        picker.dismiss(animated: true)
    }
}
