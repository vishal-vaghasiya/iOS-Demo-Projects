//
//  DefaultManager.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation
final class DefaultManager {
    private static let defaults = UserDefaults.standard

    private enum Keys {
        static let isSubscription = "isSubscription"
        static let stickerPackJson = "stickerPackJson"
    }
    
    static var IS_SUBSCRIPTION: Bool {
        get { defaults.bool(forKey: Keys.isSubscription) }
        set {
            defaults.set(newValue, forKey: Keys.isSubscription)
            defaults.synchronize()
        }
    }
    
    static var STICKER_PACK_JSON: [String: Any] {
        get {
            if let dict = defaults.dictionary(forKey: Keys.stickerPackJson) {
                return dict
            }
            return [:]
        }
        set {
            defaults.set(newValue, forKey: Keys.stickerPackJson)
            defaults.synchronize()
        }
    }
}
