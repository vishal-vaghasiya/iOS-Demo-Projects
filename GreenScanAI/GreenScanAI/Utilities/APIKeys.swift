//
//  APIKeys.swift
//  GreenScanAI
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import Foundation

enum APIKeys {
    static let plantNet: String = {
        Bundle.main.object(
            forInfoDictionaryKey: "PLANTNET_API_KEY"
        ) as? String ?? ""
    }()

    static let kindwise: String = {
        Bundle.main.object(
            forInfoDictionaryKey: "KINDWISE_API_KEY"
        ) as? String ?? ""
    }()
}
