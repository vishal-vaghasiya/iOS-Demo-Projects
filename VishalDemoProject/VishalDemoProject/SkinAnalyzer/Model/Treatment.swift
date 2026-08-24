//
//  Treatment.swift
//  VishalDemoProject
//
//  Created by Nexios Technologies on 14/07/25.
//

import Foundation

struct Treatment: Decodable {
    let issue: String
    let summary: String
    let advice: [String]
}

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil),
              let data = try? Data(contentsOf: url) else {
            fatalError("Missing file: \(file)")
        }
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode: \(file)")
        }
        return loaded
    }
}
