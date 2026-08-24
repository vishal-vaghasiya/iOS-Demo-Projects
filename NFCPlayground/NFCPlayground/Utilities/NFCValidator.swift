//
//  NFCValidator.swift
//  NFCPlayground
//
//  Created by Vishal Vaghasiya on 23/01/26.
//

import Foundation
struct NFCValidator {

    static func validate(_ input: String) -> Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && input.count < 800
    }
}
