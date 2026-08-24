//
//  Utility.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation
import UIKit

public func print(_ object: Any...) {
    #if DEBUG
    for item in object {
        if JSONSerialization.isValidJSONObject(item) {
            do {
                // Convert valid JSON objects to pretty-printed JSON
                let jsonData = try JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    Swift.print(jsonString) // Print JSON in readable format
                } else {
                    Swift.print(item)
                }
            } catch {
                Swift.print(item)
            }
        } else {
            Swift.print(item)
        }
    }
    #endif
}

func main(completion: @escaping () -> Void) {
    DispatchQueue.main.async {
        completion()
    }
}

func after(_ delay: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: completion)
}

import Toast_Swift
import Photos
func showToast(_ message: String,
               in viewController: UIViewController,
               position: ToastPosition = .bottom,
               completion: (() -> Void)? = nil) {
    viewController.view.makeToast(
        message,
        duration: 2.0,
        position: position,
        completion: { _ in
            completion?()
        }
    )
}

func sendWhatsAppMessage(to phoneNumber: String, message: String) {
    // Make sure the phone number includes country code, e.g., "919876543210"
    let urlString = "whatsapp://send?phone=\(phoneNumber)&text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    
    if let whatsappURL = URL(string: urlString) {
        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
        } else {
            print("WhatsApp is not installed on this device.")
            redirectToWhatsAppInAppStore()
        }
    }
}

func redirectToWhatsAppInAppStore() {
    // WhatsApp App Store URL
    if let appStoreURL = URL(string: "https://apps.apple.com/app/whatsapp-messenger/id310633997") {
        if UIApplication.shared.canOpenURL(appStoreURL) {
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        } else {
            print("Cannot open App Store URL.")
        }
    }
}

func copyText(_ text: String, vc: UIViewController) {
    UIPasteboard.general.string = text
    showToast("Copied", in: vc)
}

func shareText(_ text: String, from viewController: UIViewController) {
    let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    
    // For iPad support (avoids crash)
    if let popoverController = activityVC.popoverPresentationController {
        popoverController.sourceView = viewController.view
        popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                              y: viewController.view.bounds.midY,
                                              width: 0,
                                              height: 0)
        popoverController.permittedArrowDirections = []
    }
    
    viewController.present(activityVC, animated: true)
}

func saveImageToAlbum(_ image: UIImage, vc: UIViewController) {
    PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        print("Image saved to Photos library")
                        showToast("Saved", in: vc)
                    } else {
                        print("Error saving image: \(error?.localizedDescription ?? "")")
                    }
                }
            }
        } else {
            print("Permission denied to access Photos")
        }
    }
}
