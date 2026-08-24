//
//  PDFAIUseCase.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Foundation

struct SavedPDFAIResult {
    let file: SavedFile
    let text: String
}

final class PDFAIUseCase {
    private let aiService: PDFAIService
    private let repository: FileRepositoryProtocol

    init(aiService: PDFAIService = .shared, repository: FileRepositoryProtocol = FileRepository()) {
        self.aiService = aiService
        self.repository = repository
    }

    func processPDF(
        url: URL,
        mode: PDFAIToolMode,
        question: String?,
        preferredName: String
    ) async throws -> SavedPDFAIResult {
        let result = try await aiService.processPDF(url: url, mode: mode, question: question)
        let file = try saveText(result.text, preferredName: preferredName, operation: result.operationName)
        return SavedPDFAIResult(file: file, text: result.text)
    }

    private func saveText(_ text: String, preferredName: String, operation: String) throws -> SavedFile {
        let fullName = preferredName.lowercased().hasSuffix(".txt") ? preferredName : "\(preferredName).txt"

        guard let data = text.data(using: .utf8) else {
            throw NSError(domain: "PDFAIUseCase", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert AI output to text data."])
        }

        let (relativePath, _) = try TempFileManager.shared.saveRawDataToDocuments(data: data, preferredName: fullName)

        return try repository.saveFile(
            name: (fullName as NSString).deletingPathExtension,
            path: relativePath,
            fileSize: Int64(data.count),
            fileType: "txt",
            sourceOperation: operation
        )
    }
}
