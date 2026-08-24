//
//  Data+Append.swift
//  GreenScanAI
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
