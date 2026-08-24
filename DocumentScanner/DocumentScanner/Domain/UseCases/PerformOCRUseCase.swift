//
//  PerformOCRUseCase.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import UIKit
internal import Foundation

class PerformOCRUseCase {
    private let ocrService: OCRService
    private let repository: FileRepositoryProtocol
    
    init(ocrService: OCRService = .shared, repository: FileRepositoryProtocol = FileRepository()) {
        self.ocrService = ocrService
        self.repository = repository
    }
    
    /// Recognizes text from an image.
    func performOCR(on image: UIImage) async throws -> String {
        return try await ocrService.performOCR(on: image)
    }
    
    /// Saves the recognized OCR text as a .txt file in the documents directory and records it in Core Data.
    func saveOCRResult(text: String, preferredName: String) throws -> SavedFile {
        let fullName = preferredName.lowercased().hasSuffix(".txt") ? preferredName : "\(preferredName).txt"
        
        guard let data = text.data(using: .utf8) else {
            throw NSError(domain: "PerformOCRUseCase", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert text to data."])
        }
        
        let (relativePath, _) = try TempFileManager.shared.saveRawDataToDocuments(data: data, preferredName: fullName)
        let size = Int64(data.count)
        
        return try repository.saveFile(
            name: (fullName as NSString).deletingPathExtension,
            path: relativePath,
            fileSize: size,
            fileType: "txt",
            sourceOperation: "OCR Text Extraction"
        )
    }
}
