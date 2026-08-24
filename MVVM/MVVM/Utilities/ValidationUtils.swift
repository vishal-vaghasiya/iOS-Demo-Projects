//
//  ValidationUtils.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import Foundation

struct ValidationUtils {

    static func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }

    static func isNonEmpty(_ text: String) -> Bool {
        !text.isEmpty
    }
}
