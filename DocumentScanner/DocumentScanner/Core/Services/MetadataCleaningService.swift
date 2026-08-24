//
//  MetadataCleaningService.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import ImageIO
import PDFKit
import UIKit
import UniformTypeIdentifiers

enum MetadataCleaningMode {
    case removeMetadata
    case privacyCleaner

    var operationName: String {
        switch self {
        case .removeMetadata:
            return "Remove Metadata"
        case .privacyCleaner:
            return "Privacy Cleaner"
        }
    }
}

struct MetadataCleaningResult {
    let url: URL
    let fileType: String
    let size: Int64
}

final class MetadataCleaningService {
    static let shared = MetadataCleaningService()

    private init() {}

    func cleanFile(url: URL, mode: MetadataCleaningMode) async throws -> MetadataCleaningResult {
        try await Task.detached(priority: .userInitiated) {
            if Self.isPDF(url) {
                return try self.cleanPDF(url: url, mode: mode)
            }

            return try self.cleanImage(url: url, mode: mode)
        }.value
    }

    private func cleanPDF(url: URL, mode: MetadataCleaningMode) throws -> MetadataCleaningResult {
        switch mode {
        case .removeMetadata:
            return try removePDFMetadata(url: url)
        case .privacyCleaner:
            return try rebuildPDFAsFlattenedDocument(url: url)
        }
    }

    private func removePDFMetadata(url: URL) throws -> MetadataCleaningResult {
        guard let document = PDFDocument(url: url) else {
            throw metadataError("Could not open the selected PDF.")
        }

        guard !document.isLocked else {
            throw metadataError("This PDF is locked. Unlock it before cleaning metadata.")
        }

        document.documentAttributes = [:]

        let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
        guard document.write(to: tempUrl) else {
            throw metadataError("Could not save the metadata-cleaned PDF.")
        }

        return try result(url: tempUrl, fileType: "pdf")
    }

    private func rebuildPDFAsFlattenedDocument(url: URL) throws -> MetadataCleaningResult {
        guard let document = PDFDocument(url: url) else {
            throw metadataError("Could not open the selected PDF.")
        }

        guard !document.isLocked else {
            throw metadataError("This PDF is locked. Unlock it before running Privacy Cleaner.")
        }

        guard document.pageCount > 0 else {
            throw metadataError("The selected PDF does not contain any pages.")
        }

        let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
        let metadata = [
            kCGPDFContextCreator as String: "",
            kCGPDFContextTitle as String: ""
        ]

        guard UIGraphicsBeginPDFContextToFile(tempUrl.path, .zero, metadata) else {
            throw metadataError("Could not create the cleaned PDF.")
        }

        defer {
            UIGraphicsEndPDFContext()
        }

        for index in 0..<document.pageCount {
            guard let page = document.page(at: index) else { continue }
            let pageBounds = page.bounds(for: .mediaBox)
            let outputBounds = CGRect(origin: .zero, size: pageBounds.size)
            UIGraphicsBeginPDFPageWithInfo(outputBounds, nil)

            guard let context = UIGraphicsGetCurrentContext() else { continue }
            context.saveGState()
            context.translateBy(x: 0, y: outputBounds.height)
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: -pageBounds.minX, y: -pageBounds.minY)
            page.draw(with: .mediaBox, to: context)
            context.restoreGState()
        }

        return try result(url: tempUrl, fileType: "pdf")
    }

    private func cleanImage(url: URL, mode: MetadataCleaningMode) throws -> MetadataCleaningResult {
        switch mode {
        case .removeMetadata:
            return try removeImageMetadata(url: url)
        case .privacyCleaner:
            return try rebuildImagePixels(url: url)
        }
    }

    private func removeImageMetadata(url: URL) throws -> MetadataCleaningResult {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let typeIdentifier = CGImageSourceGetType(source) else {
            throw metadataError("Could not read the selected image.")
        }

        let frameCount = max(CGImageSourceGetCount(source), 1)
        let fileType = Self.fileExtension(for: typeIdentifier as String, fallback: url.pathExtension)

        if frameCount == 1 {
            return try rewriteStaticImageWithoutMetadata(url: url, typeIdentifier: typeIdentifier, fileType: fileType)
        }

        let tempUrl = TempFileManager.shared.getTempUrl(extension: fileType)

        guard let destination = CGImageDestinationCreateWithURL(tempUrl as CFURL, typeIdentifier, frameCount, nil) else {
            return try rebuildImagePixels(url: url)
        }

        let containerProperties = animationContainerProperties(from: source)
        if !containerProperties.isEmpty {
            CGImageDestinationSetProperties(destination, containerProperties as CFDictionary)
        }

        for index in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            let frameProperties = animationFrameProperties(from: source, index: index)
            CGImageDestinationAddImage(destination, cgImage, frameProperties.isEmpty ? nil : frameProperties as CFDictionary)
        }

        guard CGImageDestinationFinalize(destination) else {
            throw metadataError("Could not write the metadata-cleaned image.")
        }

        return try result(url: tempUrl, fileType: fileType)
    }

    private func rewriteStaticImageWithoutMetadata(url: URL, typeIdentifier: CFString, fileType: String) throws -> MetadataCleaningResult {
        guard let image = UIImage(contentsOfFile: url.path) ?? Self.imageFromImageSource(url: url) else {
            throw metadataError("Could not read the selected image.")
        }

        let rendered = renderImagePixels(image, preservesAlpha: Self.preservesAlpha(for: typeIdentifier as String))
        guard let cgImage = rendered.cgImage else {
            throw metadataError("Could not rebuild the selected image.")
        }

        let tempUrl = TempFileManager.shared.getTempUrl(extension: fileType)
        guard let destination = CGImageDestinationCreateWithURL(tempUrl as CFURL, typeIdentifier, 1, nil) else {
            return try rebuildImagePixels(url: url)
        }

        let options = Self.lossyImageOptions(for: typeIdentifier as String)
        CGImageDestinationAddImage(destination, cgImage, options)

        guard CGImageDestinationFinalize(destination) else {
            throw metadataError("Could not write the metadata-cleaned image.")
        }

        return try result(url: tempUrl, fileType: fileType)
    }

    private func rebuildImagePixels(url: URL) throws -> MetadataCleaningResult {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw metadataError("Could not read the selected image.")
        }

        let usesPNG = url.pathExtension.lowercased() == "png"
        let fileType = usesPNG ? "png" : "jpg"
        let tempUrl = TempFileManager.shared.getTempUrl(extension: fileType)
        let image = UIImage(contentsOfFile: url.path) ?? UIImage(cgImage: cgImage)
        let rendered = renderImagePixels(image, preservesAlpha: usesPNG)

        let data = usesPNG ? rendered.pngData() : rendered.jpegData(compressionQuality: 0.92)
        guard let data else {
            throw metadataError("Could not encode the privacy-cleaned image.")
        }

        try data.write(to: tempUrl, options: .atomic)
        return try result(url: tempUrl, fileType: fileType)
    }

    private func renderImagePixels(_ image: UIImage, preservesAlpha: Bool) -> UIImage {
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = image.scale
        rendererFormat.opaque = !preservesAlpha

        return UIGraphicsImageRenderer(size: image.size, format: rendererFormat).image { context in
            if !preservesAlpha {
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: image.size))
            }

            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    private func animationContainerProperties(from source: CGImageSource) -> [CFString: Any] {
        guard let properties = CGImageSourceCopyProperties(source, nil) as? [CFString: Any],
              let gif = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
              let loopCount = gif[kCGImagePropertyGIFLoopCount] else {
            return [:]
        }

        return [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: loopCount
            ]
        ]
    }

    private func animationFrameProperties(from source: CGImageSource, index: Int) -> [CFString: Any] {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gif = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return [:]
        }

        var cleanedGIF: [CFString: Any] = [:]
        if let delay = gif[kCGImagePropertyGIFDelayTime] {
            cleanedGIF[kCGImagePropertyGIFDelayTime] = delay
        }
        if let unclampedDelay = gif[kCGImagePropertyGIFUnclampedDelayTime] {
            cleanedGIF[kCGImagePropertyGIFUnclampedDelayTime] = unclampedDelay
        }

        return cleanedGIF.isEmpty ? [:] : [kCGImagePropertyGIFDictionary: cleanedGIF]
    }

    private func result(url: URL, fileType: String) throws -> MetadataCleaningResult {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let size = attributes[.size] as? Int64 ?? 0
        return MetadataCleaningResult(url: url, fileType: fileType, size: size)
    }

    private static func isPDF(_ url: URL) -> Bool {
        if url.pathExtension.lowercased() == "pdf" {
            return true
        }

        return UTType(filenameExtension: url.pathExtension)?.conforms(to: .pdf) == true
    }

    private static func fileExtension(for typeIdentifier: String, fallback: String) -> String {
        if typeIdentifier == "org.webmproject.webp" {
            return "webp"
        }

        if typeIdentifier == "com.compuserve.gif" {
            return "gif"
        }

        if let type = UTType(typeIdentifier),
           let preferredExtension = type.preferredFilenameExtension {
            return preferredExtension == "jpeg" ? "jpg" : preferredExtension
        }

        let normalizedFallback = fallback.lowercased()
        return normalizedFallback.isEmpty ? "jpg" : normalizedFallback
    }

    private static func preservesAlpha(for typeIdentifier: String) -> Bool {
        typeIdentifier == UTType.png.identifier ||
        typeIdentifier == "org.webmproject.webp" ||
        typeIdentifier == "com.compuserve.gif"
    }

    private static func lossyImageOptions(for typeIdentifier: String) -> CFDictionary? {
        let lossyTypes = [
            UTType.jpeg.identifier,
            UTType.heic.identifier,
            "org.webmproject.webp"
        ]

        guard lossyTypes.contains(typeIdentifier) else { return nil }

        return [kCGImageDestinationLossyCompressionQuality: 0.92] as CFDictionary
    }

    private static func imageFromImageSource(url: URL) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    private func metadataError(_ message: String) -> NSError {
        NSError(domain: "MetadataCleaningService", code: 400, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
