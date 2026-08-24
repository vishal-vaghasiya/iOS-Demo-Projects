//
//  MetadataToolsUseCase.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Foundation

final class MetadataToolsUseCase {
    private let metadataService: MetadataCleaningService
    private let repository: FileRepositoryProtocol

    init(metadataService: MetadataCleaningService = .shared, repository: FileRepositoryProtocol = FileRepository()) {
        self.metadataService = metadataService
        self.repository = repository
    }

    func cleanFiles(urls: [URL], mode: MetadataCleaningMode, preferredName: String) async throws -> [SavedFile] {
        var savedFiles: [SavedFile] = []
        savedFiles.reserveCapacity(urls.count)

        for (index, url) in urls.enumerated() {
            let result = try await metadataService.cleanFile(url: url, mode: mode)
            let name = urls.count == 1 ? preferredName : "\(preferredName)_\(index + 1)"
            let savedFile = try saveAndRegisterFile(
                tempUrl: result.url,
                name: name,
                type: result.fileType,
                size: result.size,
                operation: mode.operationName
            )
            savedFiles.append(savedFile)
        }

        return savedFiles
    }

    private func saveAndRegisterFile(tempUrl: URL, name: String, type: String, size: Int64, operation: String) throws -> SavedFile {
        let fullName = name.lowercased().hasSuffix(".\(type)") ? name : "\(name).\(type)"
        let (relativePath, _) = try TempFileManager.shared.saveFileToDocuments(fromTempUrl: tempUrl, preferredName: fullName)

        return try repository.saveFile(
            name: (fullName as NSString).deletingPathExtension,
            path: relativePath,
            fileSize: size,
            fileType: type,
            sourceOperation: operation
        )
    }
}
