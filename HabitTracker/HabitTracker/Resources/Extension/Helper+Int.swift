//
//  Helper+Int.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 18/08/25.
//

import Foundation
extension Int {
    func toString() -> String {
        let myString = String(self)
        return myString
    }
    
    var boolValue: Bool {
        return self != 0
    }
    
    var toTimeString: String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = self % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
