//
//  Interoperability.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 09/10/25.
//

import UIKit

struct Interoperability {
    private static let DefaultBundleIdentifier: String = "com.dualwhatsapp"
    private static let PasteboardExpirationSeconds: TimeInterval = 60
    private static let PasteboardStickerPackDataType: String = "net.whatsapp.third-party.sticker-pack"
    private static let WhatsAppURL: URL = URL(string: "whatsapp://stickerPack")!

    static var iOSAppStoreLink: String?
    static var AndroidStoreLink: String?

    static func canSend() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "whatsapp://")!)
    }
    
    static func send(json: [String: Any]) -> Bool {
        if Bundle.main.bundleIdentifier?.contains(DefaultBundleIdentifier) == true {
          fatalError("Your bundle identifier must not include the default one.")
        }

        let pasteboard = UIPasteboard.general

        var jsonWithAppStoreLink: [String: Any] = json
        jsonWithAppStoreLink["ios_app_store_link"] = iOSAppStoreLink
        jsonWithAppStoreLink["android_play_store_link"] = AndroidStoreLink

        guard let dataToSend = try? JSONSerialization.data(withJSONObject: jsonWithAppStoreLink, options: []) else {
            return false
        }

        if #available(iOS 10.0, *) {
            pasteboard.setItems([[PasteboardStickerPackDataType: dataToSend]], options: [UIPasteboard.OptionsKey.localOnly: true, UIPasteboard.OptionsKey.expirationDate: NSDate(timeIntervalSinceNow: PasteboardExpirationSeconds)])
        } else {
            pasteboard.setData(dataToSend, forPasteboardType: PasteboardStickerPackDataType)
        }

        DispatchQueue.main.async {
            if canSend() {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(WhatsAppURL)
                } else {
                    UIApplication.shared.openURL(WhatsAppURL)
                }
            }
        }
        return true
    }

    static func copyImageToPasteboard(image: UIImage) {
        UIPasteboard.general.image = image
    }
}
