//
//  NotificationType.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 20/03/24.
//

import Foundation

enum NotificationType {
    case test
    
    var id: String {
        switch self {
        case .test:
            return "1"
        }
    }
    
    var time: (hour: Int, minute: Int) {
        switch self {
        case .test:
            return (10, 44)
        }
    }
    
    var body: (title: String, subTitle: String) {
        switch self {
        case .test:
            let title = "Aenean commodo ligula eget dolor. Aenean massa."
            let subtitle = "One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin. He lay on his armour-like back, and if he lifted his hea One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin. He lay on his armour-like back, and if he lifted his hea"
            return (title, subtitle)
        }
    }
}
