//
//  ScreenProtector.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import UIKit

final class ScreenProtector {

    static func protect() {
        NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("Screen recording detected")
        }
    }
}
