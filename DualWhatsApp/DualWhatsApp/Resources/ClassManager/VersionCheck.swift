//
//  VersionCheck.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation
import Alamofire
class VersionCheck {
    
    public static let shared = VersionCheck()
    
    func isUpdateAvailable(callback: @escaping (Bool)->Void) {
        let url = "https://itunes.apple.com/lookup?id=\(AppInfo.appID)&timestamp=\(Date().timeIntervalSince1970)"
        AF.request(url).responseJSON { response in
            if let json = response.value as? NSDictionary, let results = json["results"] as? NSArray, let entry = results.firstObject as? NSDictionary, let versionStore = entry["version"] as? String, let versionLocal = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                
                AppInfo.versionStore = versionStore.toFloat
                AppInfo.versionLocal = versionLocal.toFloat
                
                var appStoreV:Int = versionStore.replacingOccurrences(of: ".", with: "").toInt
                var localV:Int = versionLocal.replacingOccurrences(of: ".", with: "").toInt
                
                if appStoreV.toString.count != localV.toString.count {
                    if appStoreV.toString.count < localV.toString.count {
                        let int = localV.toString.count - appStoreV.toString.count
                        appStoreV = String(format: "%.\(int)f", Float(appStoreV)).replacingOccurrences(of: ".", with: "").toInt
                    } else {
                        let int = appStoreV.toString.count - localV.toString.count
                        localV = String(format: "%.\(int)f", Float(localV)).replacingOccurrences(of: ".", with: "").toInt
                    }
                }
                
                if appStoreV > localV {
                    callback(true)
                } else {
                    callback(false)
                }
            } else {
                callback(false)
            }
        }
    }
}
