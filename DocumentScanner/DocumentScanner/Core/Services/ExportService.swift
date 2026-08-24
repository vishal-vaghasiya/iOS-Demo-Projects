//
//  ExportService.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Foundation

struct ExportFileDescriptor: Identifiable {
    let id: UUID
    let name: String
    let fileName: String
    let fileType: String
    let fileSize: Int64
    let createdAt: Date
    let sourceOperation: String
    let isFavorite: Bool
    let fileURL: URL
}

final class ExportService {
    static let shared = ExportService()

    private init() {}

    func createZipArchive(files: [ExportFileDescriptor], archiveName: String = "DocumentScanner_Export") async throws -> URL {
        let tempUrl = TempFileManager.shared.getTempUrl(extension: "zip")

        return try await Task.detached(priority: .userInitiated) {
            let availableFiles = files.filter { FileManager.default.fileExists(atPath: $0.fileURL.path) }

            guard !availableFiles.isEmpty else {
                throw NSError(domain: "ExportService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No saved files are available to export."])
            }

            let zipData = try ZipArchiveWriter.makeArchive(files: availableFiles)
            try zipData.write(to: tempUrl, options: .atomic)
            return tempUrl
        }.value
    }

}

private enum ZipArchiveWriter {
    private struct CentralDirectoryEntry {
        let fileNameData: Data
        let crc32: UInt32
        let size: UInt32
        let localHeaderOffset: UInt32
    }

    nonisolated static func makeArchive(files: [ExportFileDescriptor]) throws -> Data {
        var archive = Data()
        var centralDirectory: [CentralDirectoryEntry] = []
        var usedNames = Set<String>()

        for file in files {
            let fileData = try Data(contentsOf: file.fileURL)

            guard fileData.count <= Int(UInt32.max), archive.count <= Int(UInt32.max) else {
                throw NSError(domain: "ExportService", code: 413, userInfo: [NSLocalizedDescriptionKey: "ZIP export supports files up to 4 GB."])
            }

            let archiveName = uniqueArchiveName(for: file, usedNames: &usedNames)
            guard let fileNameData = archiveName.data(using: .utf8) else { continue }

            let crc32 = CRC32.checksum(fileData)
            let fileSize = UInt32(fileData.count)
            let localHeaderOffset = UInt32(archive.count)

            archive.appendUInt32(0x04034b50)
            archive.appendUInt16(20)
            archive.appendUInt16(0)
            archive.appendUInt16(0)
            archive.appendUInt16(0)
            archive.appendUInt16(0)
            archive.appendUInt32(crc32)
            archive.appendUInt32(fileSize)
            archive.appendUInt32(fileSize)
            archive.appendUInt16(UInt16(fileNameData.count))
            archive.appendUInt16(0)
            archive.append(fileNameData)
            archive.append(fileData)

            centralDirectory.append(CentralDirectoryEntry(
                fileNameData: fileNameData,
                crc32: crc32,
                size: fileSize,
                localHeaderOffset: localHeaderOffset
            ))
        }

        let centralDirectoryOffset = UInt32(archive.count)

        for entry in centralDirectory {
            archive.appendUInt32(0x02014b50)
            archive.appendUInt16(20)
            archive.appendUInt16(20)
            archive.appendUInt16(0)
            archive.appendUInt16(0)
            archive.appendUInt16(0)
            archive.appendUInt16(0)
            archive.appendUInt32(entry.crc32)
            archive.appendUInt32(entry.size)
            archive.appendUInt32(entry.size)
            archive.appendUInt16(UInt16(entry.fileNameData.count))
            archive.appendUInt16(0)
            archive.appendUInt16(0)
            archive.appendUInt16(0)
            archive.appendUInt16(0)
            archive.appendUInt32(0)
            archive.appendUInt32(entry.localHeaderOffset)
            archive.append(entry.fileNameData)
        }

        let centralDirectorySize = UInt32(archive.count) - centralDirectoryOffset

        archive.appendUInt32(0x06054b50)
        archive.appendUInt16(0)
        archive.appendUInt16(0)
        archive.appendUInt16(UInt16(centralDirectory.count))
        archive.appendUInt16(UInt16(centralDirectory.count))
        archive.appendUInt32(centralDirectorySize)
        archive.appendUInt32(centralDirectoryOffset)
        archive.appendUInt16(0)

        return archive
    }

    nonisolated private static func uniqueArchiveName(for file: ExportFileDescriptor, usedNames: inout Set<String>) -> String {
        let sanitized = sanitize(file.fileName.isEmpty ? "\(file.name).\(file.fileType)" : file.fileName)
        let baseName = (sanitized as NSString).deletingPathExtension
        let ext = (sanitized as NSString).pathExtension
        var candidate = sanitized
        var counter = 1

        while usedNames.contains(candidate) {
            candidate = ext.isEmpty ? "\(baseName)_\(counter)" : "\(baseName)_\(counter).\(ext)"
            counter += 1
        }

        usedNames.insert(candidate)
        return candidate
    }

    nonisolated private static func sanitize(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let cleanName = name.components(separatedBy: invalidCharacters).joined(separator: "_")
        return cleanName.isEmpty ? "document" : cleanName
    }
}

private enum CRC32 {
    nonisolated static func checksum(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xffffffff

        for byte in data {
            crc ^= UInt32(byte)
            for _ in 0..<8 {
                if crc & 1 == 1 {
                    crc = 0xedb88320 ^ (crc >> 1)
                } else {
                    crc >>= 1
                }
            }
        }

        return crc ^ 0xffffffff
    }
}

private extension Data {
    nonisolated mutating func appendUInt16(_ value: UInt16) {
        var littleEndianValue = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndianValue) { append(contentsOf: $0) }
    }

    nonisolated mutating func appendUInt32(_ value: UInt32) {
        var littleEndianValue = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndianValue) { append(contentsOf: $0) }
    }
}
