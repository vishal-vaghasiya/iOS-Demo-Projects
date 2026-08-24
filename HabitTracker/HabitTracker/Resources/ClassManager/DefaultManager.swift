//
//  DefaultManager.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 18/08/25.
//

import Foundation

class DefaultManager {
    static var IS_LOGIN: Bool {
        get {
            return (UserDefaults.standard.bool(forKey: #function))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
            UserDefaults.standard.synchronize()
        }
    }
}
