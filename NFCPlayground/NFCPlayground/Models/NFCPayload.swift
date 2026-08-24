//
//  NFCPayload.swift
//  NFCPlayground
//
//  Created by Vishal Vaghasiya on 23/01/26.
//

import Foundation

struct NFCPayload: Codable {
    let version: Int
    let id: UUID
    let title: String
    let amount: Double
    let timestamp: TimeInterval
}
