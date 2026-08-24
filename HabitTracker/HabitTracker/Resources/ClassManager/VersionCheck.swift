//
//  VersionCheck.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 18/08/25.
//

import Foundation
import Alamofire
class VersionCheck {
    
    public static let shared = VersionCheck()
    
    func isUpdateAvailable(callback: @escaping (Bool)->Void) {
        //let bundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        //let url = "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
        let url = "https://itunes.apple.com/lookup?id=\(APPID)&timestamp=\(Date().timeIntervalSince1970)"
        AF.request(url).responseJSON { response in
            if let json = response.value as? NSDictionary, let results = json["results"] as? NSArray, let entry = results.firstObject as? NSDictionary, let versionStore = entry["version"] as? String, let versionLocal = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                
                AppInfo.versionStore = versionStore.toFloat() ?? 0.0
                AppInfo.versionLocal = versionLocal.toFloat() ?? 0.0
                
                var appStoreV:Int = versionStore.replacingOccurrences(of: ".", with: "").toInt() ?? 0
                var localV:Int = versionLocal.replacingOccurrences(of: ".", with: "").toInt() ?? 0
                
                if appStoreV.toString().count != localV.toString().count {
                    if appStoreV.toString().count < localV.toString().count {
                        let int = localV.toString().count - appStoreV.toString().count
                        appStoreV = String(format: "%.\(int)f", Float(appStoreV)).replacingOccurrences(of: ".", with: "").toInt() ?? 0
                    } else {
                        let int = appStoreV.toString().count - localV.toString().count
                        localV = String(format: "%.\(int)f", Float(localV)).replacingOccurrences(of: ".", with: "").toInt() ?? 0
                    }
                }
                
                if appStoreV > localV {
                    callback(true)
                }
            }
            callback(false)
            return
        }
    }
}
