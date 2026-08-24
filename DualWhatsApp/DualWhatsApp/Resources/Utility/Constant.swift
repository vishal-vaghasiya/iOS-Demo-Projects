//
//  Constant.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import UIKit
import Foundation

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

internal enum AppInfo { }
internal extension AppInfo {
    static var versionStore = Float()
    static var versionLocal = Float()
    
    static let appName = ""
    static let appID = ""
    static let appleStoreURL = "https://itunes.apple.com/app/id\(appID)?mt=8"
    static let rateLink = "https://itunes.apple.com/app/id\(appID)?mt=8&action=write-review"
    static let privacyPolicyLink = "https://gdmarthome.com/ExpenseMoneyTracker/PrivacyPolicy.html"
}

internal enum VariableInfo { }
internal extension VariableInfo {
    static let userDefault = UserDefaults.standard
    static let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    static var window: UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first
        } else if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
                ?? UIApplication.shared.windows.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    static var rootController: UIViewController? {
        return UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }

    static let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    static let fileManager = FileManager.default
    
    var rootController: UIViewController? {
        return UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
