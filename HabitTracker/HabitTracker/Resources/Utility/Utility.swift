//
//  Utility.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 18/08/25.
//

import Foundation
import Reachability
import ProgressHUD

public func print(_ object: Any...) {
    #if DEBUG
    for item in object {
        if JSONSerialization.isValidJSONObject(item) {
            do {
                // Convert valid JSON objects to pretty-printed JSON
                let jsonData = try JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    Swift.print(jsonString) // Print JSON in readable format
                } else {
                    Swift.print(item)
                }
            } catch {
                Swift.print(item)
            }
        } else {
            Swift.print(item)
        }
    }
    #endif
}

func checkInternet() -> Bool {
    do {
        let reachability = try Reachability()
        if reachability.connection == .unavailable {
            return false
        } else if reachability.connection == .cellular || reachability.connection == .wifi {
            return true
        } else {
            return false
        }
    } catch {
        return false
    }
}

func main(completion: @escaping () -> Void) {
    DispatchQueue.main.async {
        completion()
    }
}

func after(_ delay: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: completion)
}

func showLoader(_ text: String? = nil){
    ProgressHUD.animate(text, interaction: false)
}

func hideLoader(){
    ProgressHUD.dismiss()
}
