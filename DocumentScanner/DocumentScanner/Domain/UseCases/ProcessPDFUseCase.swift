//
//  ProcessPDFUseCase.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import UIKit
internal import Foundation

class ProcessPDFUseCase {
    private let pdfService: PDFProcessingService
    private let repository: FileRepositoryProtocol

    init(pdfService: PDFProcessingService = .shared, repository: FileRepositoryProtocol = FileRepository()) {
        self.pdfService = pdfService
        self.repository = repository
    }

    func createPDFFromImages(images: [UIImage], preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.createPDFFromImages(images: images)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Create PDF")
    }

    func createPDFFromText(text: String, title: String, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.createPDFFromText(text: text, title: title)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Create PDF")
    }

    func mergePDFs(urls: [URL], preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.mergePDFs(urls: urls)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Merge PDF")
    }

    func splitPDF(url: URL, pageIndices: IndexSet, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.splitPDF(url: url, pageIndices: pageIndices)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Split PDF")
    }

    func compressPDF(url: URL, quality: CGFloat, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.compressPDF(url: url, quality: quality)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Compress PDF")
    }

    func passwordProtectPDF(url: URL, password: String, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.passwordProtectPDF(url: url, ownerPassword: password)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Protect PDF")
    }

    func removePasswordProtection(url: URL, password: String, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.removePasswordProtection(url: url, password: password)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Remove Protect PDF")
    }

    func editPDF(url: URL, configuration: PDFEditConfiguration, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.editPDF(url: url, configuration: configuration)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Edit PDF")
    }

    func addWatermark(url: URL, configuration: PDFWatermarkConfiguration, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.addWatermark(url: url, configuration: configuration)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Add Watermark")
    }

    func addPageNumbers(url: URL, configuration: PDFPageNumberConfiguration, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.addPageNumbers(url: url, configuration: configuration)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Add Page Numbers")
    }

    func saveAnnotatedPDF(data: Data, preferredName: String) async throws -> SavedFile {
        let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
        try data.write(to: tempUrl, options: .atomic)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Annotate PDF")
    }

    func deletePDFPages(url: URL, pageIndices: IndexSet, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.deletePages(url: url, pageIndices: pageIndices)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Delete PDF Pages")
    }

    func rearrangePDFPages(url: URL, orderedPageIndices: [Int], preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.rearrangePages(url: url, orderedPageIndices: orderedPageIndices)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Rearrange PDF Pages")
    }

    func rotatePDFPages(url: URL, pageIndices: IndexSet, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.rotatePages(url: url, pageIndices: pageIndices)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Rotate PDF Pages")
    }

    func rotatePDFPages(url: URL, pageRotations: [Int: Int], preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.rotatePages(url: url, pageRotations: pageRotations)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Rotate PDF Pages")
    }

    func duplicatePDFPages(url: URL, pageIndices: IndexSet, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.duplicatePages(url: url, pageIndices: pageIndices)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Duplicate PDF Pages")
    }

    func cropPDF(url: URL, margins: PDFCropMargins, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.cropPages(url: url, margins: margins)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Crop PDF")
    }

    func reversePDFPages(url: URL, preferredName: String) async throws -> SavedFile {
        let tempUrl = try await pdfService.reversePages(url: url)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "pdf", operation: "Reverse PDF Pages")
    }

    func convertPDFToLongImage(url: URL, preferredName: String) async throws -> SavedFile {
        let result = try await pdfService.renderLongImage(url: url)
        return try saveAndRegisterFile(tempUrl: result.url, name: preferredName, type: "jpg", operation: "PDF to Long Image")
    }

    private func saveAndRegisterFile(tempUrl: URL, name: String, type: String, operation: String) throws -> SavedFile {
        let fullName = name.lowercased().hasSuffix(".\(type)") ? name : "\(name).\(type)"

        let (relativePath, absoluteUrl) = try TempFileManager.shared.saveFileToDocuments(fromTempUrl: tempUrl, preferredName: fullName)

        // Get File Size
        let attributes = try FileManager.default.attributesOfItem(atPath: absoluteUrl.path)
        let size = attributes[.size] as? Int64 ?? 0

        return try repository.saveFile(
            name: (fullName as NSString).deletingPathExtension,
            path: relativePath,
            fileSize: size,
            fileType: type,
            sourceOperation: operation
        )
    }
}
