//
//  NFCPayloadBuilder.swift
//  NFCPlayground
//
//  Created by Vishal Vaghasiya on 23/01/26.
//

import Foundation
import CoreNFC

struct NFCPayloadBuilder {

    static func build(
        type: NFCPayloadType,
        input: String
    ) throws -> NFCNDEFMessage {

        switch type {

        case .text:
            let payload = NFCNDEFPayload.wellKnownTypeTextPayload(
                string: input,
                locale: .current
            )!
            return NFCNDEFMessage(records: [payload])

        case .url:
            guard let url = URL(string: input) else {
                throw NSError(domain: "Invalid URL", code: 0)
            }
            let payload = NFCNDEFPayload.wellKnownTypeURIPayload(url: url)!
            return NFCNDEFMessage(records: [payload])

        case .json:
            let model = NFCPayload(
                version: 1,
                id: UUID(),
                title: input,
                amount: Double.random(in: 10...500),
                timestamp: Date().timeIntervalSince1970
            )

            let data = try JSONEncoder().encode(model)

            let payload = NFCNDEFPayload(
                format: .media,
                type: "application/json".data(using: .utf8)!,
                identifier: Data(),
                payload: data
            )
            return NFCNDEFMessage(records: [payload])

        case .custom:
            let data = input.data(using: .utf8)!

            let payload = NFCNDEFPayload(
                format: .nfcExternal,
                type: "com.mycompany.nfcadvancedkit:data".data(using: .utf8)!,
                identifier: Data(),
                payload: data
            )
            return NFCNDEFMessage(records: [payload])
        }
    }
}
