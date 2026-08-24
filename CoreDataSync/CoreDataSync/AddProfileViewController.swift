//
//  AddProfileViewController.swift
//  CoreDataSync
//
//  Created by Nexios Technologies on 23/09/25.
//

import UIKit

class AddProfileViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make profile image tappable
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickImage)))
        
        // Optional: Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func pickImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @IBAction func saveProfile(_ sender: Any) {
        dismissKeyboard()
        
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty else {
            showAlert(title: "Validation Error", message: "Name and Email cannot be empty")
            return
        }
        
        guard isValidEmail(email) else {
            showAlert(title: "Validation Error", message: "Please enter a valid email address")
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let profile = Profile(context: context)
        profile.fullName = name
        profile.email = email
        
        if let image = profileImageView.image {
            let resizedImage = resizeImage(image, to: CGSize(width: 200, height: 200))
            if let data = resizedImage.jpegData(compressionQuality: 0.8) {
                profile.profilePicture = data
            }
        }
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            showAlert(title: "Save Error", message: "Failed to save profile. Please try again.")
            print("Error saving profile: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
    
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? image
    }
}
extension AddProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
        }
        dismiss(animated: true)
    }
}
