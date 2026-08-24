//
//  DefaultManager.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 19/06/25.
//

import Foundation

class DefaultManager {
    static var TOKEN: String {
        get {
            return (UserDefaults.standard.string(forKey: "token") ?? "")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
            UserDefaults.standard.synchronize()
        }
    }
}
