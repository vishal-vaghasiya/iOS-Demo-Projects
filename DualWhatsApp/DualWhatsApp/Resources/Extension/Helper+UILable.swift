//
//  Helper+UILable.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 10/10/25.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

extension UILabel {
    func copyStyledText(vc: UIViewController) {
        // Prefer an existing attributedText, otherwise build one from text+font
        let attributed: NSAttributedString
        if let attr = self.attributedText {
            attributed = attr
        } else if let txt = self.text, let f = self.font {
            attributed = NSAttributedString(string: txt, attributes: [.font: f])
        } else {
            return
        }

        let plainText = attributed.string
        let fullRange = NSRange(location: 0, length: attributed.length)

        // Create RTF and HTML representations (if possible)
        var rtfData: Data? = nil
        var htmlData: Data? = nil
        if let rtf = try? attributed.data(from: fullRange, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
            rtfData = rtf
        }
        if let html = try? attributed.data(from: fullRange, documentAttributes: [.documentType: NSAttributedString.DocumentType.html]) {
            htmlData = html
        }

        // Try the modern NSItemProvider + UIPasteboard API first (more reliable for rich representations)
        if #available(iOS 11.0, *) {
            // If we have at least one rich representation, register it with an NSItemProvider
            if rtfData != nil || htmlData != nil {
                let provider = NSItemProvider()

                // Register highest-fidelity representation first (RTF), then HTML
                if let rtf = rtfData {
                    provider.registerDataRepresentation(forTypeIdentifier: UTType.rtf.identifier, visibility: .all) { completion in
                        completion(rtf, nil)
                        return nil
                    }
                }
                if let html = htmlData {
                    provider.registerDataRepresentation(forTypeIdentifier: UTType.html.identifier, visibility: .all) { completion in
                        completion(html, nil)
                        return nil
                    }
                }

                // Put the provider on the system pasteboard. We intentionally DO NOT add a plain-text flavor
                // here so that receivers that understand rich formats will prefer them (some receivers choose
                // plain text if it's available).
                UIPasteboard.general.setItemProviders([provider], localOnly: false, expirationDate: nil)

                DualWhatsApp.showToast("Copied", in: vc)
                return
            }
        }

        // Fallback for older iOS or when no rich representation exists: use setItems with explicit UTIs
        var item: [String: Any] = [:]
        if #available(iOS 14.0, *) {
            if let rtf = rtfData { item[UTType.rtf.identifier] = rtf }
            if let html = htmlData { item[UTType.html.identifier] = html }
            // we omit plain text here to avoid receivers picking plain text over rich text
        } else {
            if let rtf = rtfData { item["public.rtf"] = rtf }
            if let html = htmlData { item["public.html"] = html }
        }

        if !item.isEmpty {
            UIPasteboard.general.setItems([item], options: [:])
            DualWhatsApp.showToast("Copied", in: vc)
            return
        }

        // Last-resort fallback: plain string only
        UIPasteboard.general.string = plainText
        DualWhatsApp.showToast("Copied (plain)", in: vc)
    }
    
    func shareStyledText(in viewController: UIViewController) {
        // Convert label to image
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        
        // Share image
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
}
