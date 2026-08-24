//
//  Helper+String.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

extension String {
    
    var toDouble: Double {
        return (self as NSString).doubleValue
    }
    
    var toFloat: Float {
        return (self as NSString).floatValue
    }
    
    var toBool: Bool {
        let lower = self.lowercased()
        if lower == "true" { return true }
        if lower == "false" { return false }
        return (self as NSString).boolValue
    }
    
    var toInt: Int {
        return NumberFormatter().number(from: self)?.intValue ?? 0
    }
    
    /*var localized: String {
        
        // Find the path for the language bundle
        if let path = Bundle.main.path(forResource: DefaultManager.selectedLanguage.langCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        }
        
        // Fallback to base localization
        return NSLocalizedString(self, comment: "")
    }*/
    
    var isOnlyEmojis: Bool {
        guard !isEmpty else { return false }
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                0x1F680...0x1F6FF, // Transport & Map
                0x1F1E6...0x1F1FF, // Flags
                0x2600...0x26FF,   // Misc symbols
                0x2700...0x27BF,   // Dingbats
                0xFE00...0xFE0F,   // Variation Selectors
                0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                0x1FA70...0x1FAFF: // Extended symbols
                continue
            default:
                return false
            }
        }
        return true
    }
}
