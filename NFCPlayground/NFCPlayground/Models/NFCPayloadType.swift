//
//  NFCPayloadType.swift
//  NFCPlayground
//
//  Created by Vishal Vaghasiya on 23/01/26.
//

enum NFCPayloadType: String, CaseIterable {
    case text = "Text"
    case url = "URL"
    case json = "JSON"
    case custom = "Custom App Payload"
}
