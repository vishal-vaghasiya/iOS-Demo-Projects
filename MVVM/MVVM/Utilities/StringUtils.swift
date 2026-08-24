//
//  StringUtils.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import Foundation

struct StringUtils {

    static func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func containsHTML(_ text: String) -> Bool {
        text.range(of: "<[^>]+>", options: .regularExpression) != nil
    }
}
