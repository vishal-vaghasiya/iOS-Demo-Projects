//
//  ProcessedFileResult.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 16/06/26.
//

internal import Foundation

struct ProcessedFileResult: Identifiable, Equatable {
    let id = UUID()
    let url: URL
    let name: String
    let fileType: String
    let fileSize: Int64
    let sourceOperation: String

    var displayName: String {
        "\(name).\(fileType)"
    }
}
