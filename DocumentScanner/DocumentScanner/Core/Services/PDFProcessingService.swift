//
//  PDFProcessingService.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import PDFKit
import UIKit
import CoreGraphics

enum PDFEditElement: String, CaseIterable, Identifiable {
    case signature
    case text
    case watermark
    case image
    case pageNumber

    var id: String { rawValue }
}

struct PDFEditConfiguration {
    let element: PDFEditElement
    let text: String
    let image: UIImage?
    let normalizedCenter: CGPoint
    let appliesToAllPages: Bool
    let fontSize: CGFloat
    let opacity: CGFloat
}

enum PDFWatermarkKind {
    case text
    case logo
}

struct PDFWatermarkConfiguration {
    static let logoMaxHeightRatio: CGFloat = 0.35

    let kind: PDFWatermarkKind
    let text: String
    let image: UIImage?
    let normalizedCenter: CGPoint
    let appliesToAllPages: Bool
    let size: CGFloat
    let opacity: CGFloat
}

enum PDFPageNumberFormat: String, CaseIterable, Identifiable {
    case numberOnly
    case pageOfTotal

    var id: String { rawValue }
}

enum PDFPageNumberPosition: String, CaseIterable, Identifiable {
    case bottomCenter
    case bottomRight
    case bottomLeft
    case topCenter
    case topRight
    case topLeft

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bottomCenter: return "Bottom Center"
        case .bottomRight: return "Bottom Right"
        case .bottomLeft: return "Bottom Left"
        case .topCenter: return "Top Center"
        case .topRight: return "Top Right"
        case .topLeft: return "Top Left"
        }
    }
}

struct PDFPageNumberConfiguration {
    let position: PDFPageNumberPosition
    let format: PDFPageNumberFormat
    let startingNumber: Int
    let fontSize: CGFloat
    let opacity: CGFloat
}

class PDFProcessingService {
    static let shared = PDFProcessingService()

    private init() {}

    /// Creates a PDF from a list of UIImages. Writes directly to disk to minimize memory footprint.
    func createPDFFromImages(images: [UIImage], compressionQuality: CGFloat = 0.8) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")

            // Set up PDF page bounds (Standard Letter size: 612 x 792 points)
            let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)

            guard UIGraphicsBeginPDFContextToFile(tempUrl.path, .zero, nil) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize PDF file context."])
            }

            defer {
                UIGraphicsEndPDFContext()
            }

            for image in images {
                try autoreleasepool {
                    // Compress image memory-safely by converting to JPEG data before rendering
                    guard let compressedData = image.jpegData(compressionQuality: compressionQuality),
                          let compressedImage = UIImage(data: compressedData) else {
                        return
                    }

                    // Create page
                    UIGraphicsBeginPDFPageWithInfo(pageRect, nil)

                    // Calculate aspect ratio fit
                    let imgSize = compressedImage.size
                    let scale = min(pageRect.width / imgSize.width, pageRect.height / imgSize.height)
                    let width = imgSize.width * scale
                    let height = imgSize.height * scale
                    let x = (pageRect.width - width) / 2
                    let y = (pageRect.height - height) / 2
                    let destRect = CGRect(x: x, y: y, width: width, height: height)

                    compressedImage.draw(in: destRect)
                }
            }

            return tempUrl
        }.value
    }

    /// Creates a PDF from plain text, rendering paragraphs across multiple pages.
    func createPDFFromText(text: String, title: String) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
            let margin: CGFloat = 50
            let printableRect = pageRect.insetBy(dx: margin, dy: margin)

            guard UIGraphicsBeginPDFContextToFile(tempUrl.path, .zero, nil) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize PDF file context."])
            }

            defer {
                UIGraphicsEndPDFContext()
            }

            // Text attributes
            let font = UIFont.systemFont(ofSize: 12)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.black
            ]

            let attributedText = NSAttributedString(string: text, attributes: attributes)
            let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)

            var textRange = CFRangeMake(0, 0)
            var pageIndex = 0

            repeat {
                UIGraphicsBeginPDFPageWithInfo(pageRect, nil)

                // Draw Page Header
                let titleFont = UIFont.boldSystemFont(ofSize: 10)
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor.darkGray
                ]
                let headerText = NSAttributedString(string: "\(title) - Page \(pageIndex + 1)", attributes: headerAttributes)
                headerText.draw(at: CGPoint(x: margin, y: 25))

                // Draw footer line / separator
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: 40))
                path.addLine(to: CGPoint(x: pageRect.width - margin, y: 40))
                path.lineWidth = 0.5
                UIColor.lightGray.setStroke()
                path.stroke()

                // Set text path
                let currentTextRect = CGRect(x: printableRect.origin.x,
                                             y: printableRect.origin.y + 15,
                                             width: printableRect.width,
                                             height: printableRect.height - 35)

                let pathRef = CGPath(rect: currentTextRect, transform: nil)
                let frameRef = CTFramesetterCreateFrame(framesetter, textRange, pathRef, nil)

                guard let context = UIGraphicsGetCurrentContext() else { break }

                // CoreText draws upside down, adjust coordinate system
                context.saveGState()
                context.textMatrix = .identity
                context.translateBy(x: 0, y: pageRect.height)
                context.scaleBy(x: 1.0, y: -1.0)

                // We need to invert the rectangle y coordinate since we flipped the context
                let coreTextRect = CGRect(x: currentTextRect.origin.x,
                                          y: pageRect.height - currentTextRect.origin.y - currentTextRect.height,
                                          width: currentTextRect.width,
                                          height: currentTextRect.height)

                let coreTextPath = CGPath(rect: coreTextRect, transform: nil)
                let flippedFrame = CTFramesetterCreateFrame(framesetter, textRange, coreTextPath, nil)

                CTFrameDraw(flippedFrame, context)
                context.restoreGState()

                let visibleRange = CTFrameGetVisibleStringRange(flippedFrame)
                textRange.location += visibleRange.length
                pageIndex += 1

            } while textRange.location < attributedText.length

            return tempUrl
        }.value
    }

    /// Merges multiple PDFs into a single file. Memory optimized using autoreleasepools.
    func mergePDFs(urls: [URL]) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            let mergedDoc = PDFDocument()

            var totalPageCount = 0
            for url in urls {
                try autoreleasepool {
                    guard let sourceDoc = PDFDocument(url: url) else {
                        throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to open PDF: \(url.lastPathComponent)"])
                    }

                    let pageCount = sourceDoc.pageCount
                    for i in 0..<pageCount {
                        if let page = sourceDoc.page(at: i) {
                            // Copy page to prevent resource retention
                            if let pageCopy = page.copy() as? PDFPage {
                                mergedDoc.insert(pageCopy, at: totalPageCount)
                                totalPageCount += 1
                            }
                        }
                    }
                }
            }

            guard mergedDoc.write(to: tempUrl) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to write merged PDF document."])
            }

            return tempUrl
        }.value
    }

    /// Splits a PDF document by extracting only the requested pages.
    func splitPDF(url: URL, pageIndices: IndexSet) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let sourceDoc = PDFDocument(url: url) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not open source PDF document."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            let newDoc = PDFDocument()
            var newPageIndex = 0

            for index in pageIndices {
                if index >= 0 && index < sourceDoc.pageCount {
                    if let page = sourceDoc.page(at: index),
                       let pageCopy = page.copy() as? PDFPage {
                        newDoc.insert(pageCopy, at: newPageIndex)
                        newPageIndex += 1
                    }
                }
            }

            guard newDoc.write(to: tempUrl) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not write split PDF document."])
            }

            return tempUrl
        }.value
    }

    /// Compresses a PDF by rendering pages down to images, applying JPEG compression, and rebuilds the PDF.
    func compressPDF(url: URL, quality: CGFloat) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let sourceDoc = PDFDocument(url: url) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not open source PDF."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")

            guard UIGraphicsBeginPDFContextToFile(tempUrl.path, .zero, nil) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not initialize compressed PDF context."])
            }

            defer {
                UIGraphicsEndPDFContext()
            }

            for i in 0..<sourceDoc.pageCount {
                try autoreleasepool {
                    guard let page = sourceDoc.page(at: i) else { return }

                    let pageBounds = page.bounds(for: .mediaBox)
                    UIGraphicsBeginPDFPageWithInfo(pageBounds, nil)

                    guard let context = UIGraphicsGetCurrentContext() else { return }

                    // Render page as image with custom resolution scale depending on quality settings
                    let scale: CGFloat = quality > 0.5 ? 2.0 : 1.0 // 2.0 scale matches retina displays
                    let format = UIGraphicsImageRendererFormat()
                    format.scale = scale

                    let renderer = UIGraphicsImageRenderer(size: pageBounds.size, format: format)
                    let pageImage = renderer.image { ctx in
                        // Flip coordinates for drawing PDF Page
                        ctx.cgContext.saveGState()
                        ctx.cgContext.translateBy(x: 0, y: pageBounds.height)
                        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                        // Shift translation by page origin offset
                        ctx.cgContext.translateBy(x: -pageBounds.origin.x, y: -pageBounds.origin.y)

                        page.draw(with: .mediaBox, to: ctx.cgContext)
                        ctx.cgContext.restoreGState()
                    }

                    // Compress image using JPEG conversion
                    guard let jpegData = pageImage.jpegData(compressionQuality: quality),
                          let compressedImage = UIImage(data: jpegData) else {
                        // Fallback: draw original page structure
                        context.saveGState()
                        context.translateBy(x: 0, y: pageBounds.height)
                        context.scaleBy(x: 1.0, y: -1.0)
                        context.translateBy(x: -pageBounds.origin.x, y: -pageBounds.origin.y)
                        page.draw(with: .mediaBox, to: context)
                        context.restoreGState()
                        return
                    }

                    compressedImage.draw(in: CGRect(origin: .zero, size: pageBounds.size))
                }
            }

            return tempUrl
        }.value
    }

    /// Encrypts and password protects a PDF.
    func passwordProtectPDF(url: URL, ownerPassword: String) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let doc = PDFDocument(url: url) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to read PDF for encryption."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            let options: [AnyHashable: Any] = [
                PDFDocumentWriteOption.ownerPasswordOption: ownerPassword,
                PDFDocumentWriteOption.userPasswordOption: ownerPassword
            ]

            // Obtain encrypted PDF data and write to disk
            guard let data = doc.dataRepresentation(options: options) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to generate password-protected PDF data."])
            }
            do {
                try data.write(to: tempUrl, options: .atomic)
            } catch {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to write password-protected PDF."])
            }

            return tempUrl
        }.value
    }

    /// Unlocks a password-protected PDF and writes a new unencrypted copy.
    func removePasswordProtection(url: URL, password: String) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let doc = PDFDocument(url: url) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to read PDF for unlocking."])
            }

            guard doc.isEncrypted else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "The selected PDF is not password-protected."])
            }

            if doc.isLocked {
                guard doc.unlock(withPassword: password) else {
                    throw NSError(domain: "PDFProcessingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Incorrect PDF password."])
                }
            }

            guard !doc.isLocked else {
                throw NSError(domain: "PDFProcessingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Could not unlock the PDF with this password."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            guard doc.write(to: tempUrl) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to write unlocked PDF."])
            }

            return tempUrl
        }.value
    }

    /// Rebuilds a PDF with a text, watermark, signature, or image overlay.
    func editPDF(url: URL, configuration: PDFEditConfiguration) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let sourceDoc = PDFDocument(url: url) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not open source PDF."])
            }

            guard !sourceDoc.isLocked else {
                throw NSError(domain: "PDFProcessingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unlock this PDF before editing it."])
            }

            guard sourceDoc.pageCount > 0 else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "The selected PDF does not contain any pages."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")

            guard UIGraphicsBeginPDFContextToFile(tempUrl.path, .zero, nil) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not initialize edited PDF context."])
            }

            defer {
                UIGraphicsEndPDFContext()
            }

            for pageIndex in 0..<sourceDoc.pageCount {
                try autoreleasepool {
                    guard let page = sourceDoc.page(at: pageIndex) else { return }

                    let pageBounds = page.bounds(for: .mediaBox)
                    let pageRect = CGRect(origin: .zero, size: pageBounds.size)
                    UIGraphicsBeginPDFPageWithInfo(pageRect, nil)

                    guard let context = UIGraphicsGetCurrentContext() else { return }

                    context.saveGState()
                    context.translateBy(x: 0, y: pageRect.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                    context.translateBy(x: -pageBounds.origin.x, y: -pageBounds.origin.y)
                    page.draw(with: .mediaBox, to: context)
                    context.restoreGState()

                    guard configuration.appliesToAllPages || pageIndex == 0 else { return }

                    context.saveGState()
                    context.setAlpha(configuration.opacity)

                    switch configuration.element {
                    case .text:
                        Self.drawTextOverlay(configuration.text, font: .systemFont(ofSize: configuration.fontSize, weight: .semibold), color: .black, center: configuration.normalizedCenter, pageRect: pageRect)
                    case .signature:
                        if let image = configuration.image {
                            Self.drawImageOverlay(image, center: configuration.normalizedCenter, pageRect: pageRect, maxWidthRatio: min(max(configuration.fontSize / 100, 0.16), 0.55))
                        } else {
                            let font = UIFont(name: "SnellRoundhand-Bold", size: configuration.fontSize) ?? .italicSystemFont(ofSize: configuration.fontSize)
                            Self.drawTextOverlay(configuration.text, font: font, color: .black, center: configuration.normalizedCenter, pageRect: pageRect)
                        }
                    case .watermark:
                        Self.drawWatermarkOverlay(configuration.text, center: configuration.normalizedCenter, fontSize: configuration.fontSize, pageRect: pageRect)
                    case .image:
                        guard let image = configuration.image else { break }
                        Self.drawImageOverlay(image, center: configuration.normalizedCenter, pageRect: pageRect, maxWidthRatio: min(max(configuration.fontSize / 100, 0.16), 0.6))
                    case .pageNumber:
                        Self.drawPageNumberOverlay(
                            "\(pageIndex + 1)",
                            position: .bottomCenter,
                            fontSize: configuration.fontSize,
                            opacity: configuration.opacity,
                            pageRect: pageRect
                        )
                    }

                    context.restoreGState()
                }
            }

            return tempUrl
        }.value
    }

    /// Rebuilds a PDF with a preview-matched text or logo watermark overlay.
    func addWatermark(url: URL, configuration: PDFWatermarkConfiguration) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let sourceDoc = PDFDocument(url: url) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not open source PDF."])
            }

            guard !sourceDoc.isLocked else {
                throw NSError(domain: "PDFProcessingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unlock this PDF before adding a watermark."])
            }

            guard sourceDoc.pageCount > 0 else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "The selected PDF does not contain any pages."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")

            guard UIGraphicsBeginPDFContextToFile(tempUrl.path, .zero, nil) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not initialize watermarked PDF context."])
            }

            defer {
                UIGraphicsEndPDFContext()
            }

            for pageIndex in 0..<sourceDoc.pageCount {
                try autoreleasepool {
                    guard let page = sourceDoc.page(at: pageIndex) else { return }

                    let pageBounds = page.bounds(for: .mediaBox)
                    let pageRect = CGRect(origin: .zero, size: pageBounds.size)
                    UIGraphicsBeginPDFPageWithInfo(pageRect, nil)

                    guard let context = UIGraphicsGetCurrentContext() else { return }

                    context.saveGState()
                    context.translateBy(x: 0, y: pageRect.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                    context.translateBy(x: -pageBounds.origin.x, y: -pageBounds.origin.y)
                    page.draw(with: .mediaBox, to: context)
                    context.restoreGState()

                    guard configuration.appliesToAllPages || pageIndex == 0 else { return }

                    switch configuration.kind {
                    case .text:
                        Self.drawPreviewMatchedWatermarkText(
                            configuration.text,
                            center: configuration.normalizedCenter,
                            fontSize: configuration.size,
                            opacity: configuration.opacity,
                            pageRect: pageRect
                        )
                    case .logo:
                        guard let image = configuration.image else { return }
                        Self.drawPreviewMatchedWatermarkLogo(
                            image,
                            center: configuration.normalizedCenter,
                            widthRatio: configuration.size / 100,
                            opacity: configuration.opacity,
                            pageRect: pageRect
                        )
                    }
                }
            }

            return tempUrl
        }.value
    }

    /// Rebuilds a PDF with page numbers on every page.
    func addPageNumbers(url: URL, configuration: PDFPageNumberConfiguration) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let sourceDoc = PDFDocument(url: url) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not open source PDF."])
            }

            guard !sourceDoc.isLocked else {
                throw NSError(domain: "PDFProcessingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unlock this PDF before adding page numbers."])
            }

            guard sourceDoc.pageCount > 0 else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "The selected PDF does not contain any pages."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")

            guard UIGraphicsBeginPDFContextToFile(tempUrl.path, .zero, nil) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not initialize page-numbered PDF context."])
            }

            defer {
                UIGraphicsEndPDFContext()
            }

            for pageIndex in 0..<sourceDoc.pageCount {
                try autoreleasepool {
                    guard let page = sourceDoc.page(at: pageIndex) else { return }

                    let pageBounds = page.bounds(for: .mediaBox)
                    let pageRect = CGRect(origin: .zero, size: pageBounds.size)
                    UIGraphicsBeginPDFPageWithInfo(pageRect, nil)

                    guard let context = UIGraphicsGetCurrentContext() else { return }

                    context.saveGState()
                    context.translateBy(x: 0, y: pageRect.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                    context.translateBy(x: -pageBounds.origin.x, y: -pageBounds.origin.y)
                    page.draw(with: .mediaBox, to: context)
                    context.restoreGState()

                    let pageNumber = max(configuration.startingNumber, 1) + pageIndex
                    let text: String
                    switch configuration.format {
                    case .numberOnly:
                        text = "\(pageNumber)"
                    case .pageOfTotal:
                        text = "Page \(pageNumber) of \(sourceDoc.pageCount)"
                    }

                    Self.drawPageNumberOverlay(
                        text,
                        position: configuration.position,
                        fontSize: configuration.fontSize,
                        opacity: configuration.opacity,
                        pageRect: pageRect
                    )
                }
            }

            return tempUrl
        }.value
    }

    private static func drawTextOverlay(_ text: String, font: UIFont, color: UIColor, center: CGPoint, pageRect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        let constrainedSize = CGSize(width: pageRect.width * 0.6, height: .greatestFiniteMagnitude)
        let measuredSize = (text as NSString).boundingRect(
            with: constrainedSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).integral.size
        let rect = centeredRect(for: CGSize(width: measuredSize.width + 24, height: measuredSize.height + 12), normalizedCenter: center, in: pageRect)

        (text as NSString).draw(in: rect, withAttributes: attributes)
    }

    private static func drawWatermarkOverlay(_ text: String, center: CGPoint, fontSize: CGFloat, pageRect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: UIColor.gray,
            .paragraphStyle: paragraphStyle
        ]
        let drawRect = CGRect(x: -pageRect.width * 0.15, y: -fontSize / 2, width: pageRect.width * 1.3, height: fontSize * 2)
        let resolvedCenter = CGPoint(x: pageRect.width * center.x, y: pageRect.height * center.y)

        context.saveGState()
        context.translateBy(x: resolvedCenter.x, y: resolvedCenter.y)
        context.rotate(by: -.pi / 4)
        (text as NSString).draw(in: drawRect, withAttributes: attributes)
        context.restoreGState()
    }

    private static func drawImageOverlay(_ image: UIImage, center: CGPoint, pageRect: CGRect, maxWidthRatio: CGFloat) {
        let maxSize = CGSize(width: pageRect.width * maxWidthRatio, height: pageRect.height * 0.22)
        let imageSize = image.size
        guard imageSize.width > 0 && imageSize.height > 0 else { return }

        let scale = min(maxSize.width / imageSize.width, maxSize.height / imageSize.height)
        let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let rect = centeredRect(for: drawSize, normalizedCenter: center, in: pageRect)
        image.draw(in: rect)
    }

    private static func drawPreviewMatchedWatermarkText(_ text: String, center: CGPoint, fontSize: CGFloat, opacity: CGFloat, pageRect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: UIColor.gray.withAlphaComponent(opacity),
            .paragraphStyle: paragraphStyle
        ]
        let constrainedSize = CGSize(width: pageRect.width * 1.3, height: .greatestFiniteMagnitude)
        let measuredSize = (text as NSString).boundingRect(
            with: constrainedSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).integral.size
        let drawSize = CGSize(width: measuredSize.width + 24, height: measuredSize.height + 12)
        let drawRect = CGRect(x: -drawSize.width / 2, y: -drawSize.height / 2, width: drawSize.width, height: drawSize.height)
        let resolvedCenter = unclampedCenter(for: center, in: pageRect)

        context.saveGState()
        context.translateBy(x: resolvedCenter.x, y: resolvedCenter.y)
        context.rotate(by: -.pi / 4)
        (text as NSString).draw(in: drawRect, withAttributes: attributes)
        context.restoreGState()
    }

    private static func drawPreviewMatchedWatermarkLogo(_ image: UIImage, center: CGPoint, widthRatio: CGFloat, opacity: CGFloat, pageRect: CGRect) {
        let imageSize = image.size
        guard imageSize.width > 0 && imageSize.height > 0 else { return }

        let safeWidthRatio = min(max(widthRatio, 0.05), 0.9)
        let maxSize = CGSize(
            width: pageRect.width * safeWidthRatio,
            height: pageRect.height * PDFWatermarkConfiguration.logoMaxHeightRatio
        )
        let drawSize = fittedSize(for: imageSize, in: maxSize)
        let resolvedCenter = unclampedCenter(for: center, in: pageRect)
        let rect = CGRect(
            x: resolvedCenter.x - drawSize.width / 2,
            y: resolvedCenter.y - drawSize.height / 2,
            width: drawSize.width,
            height: drawSize.height
        )

        image.draw(in: rect, blendMode: .normal, alpha: min(max(opacity, 0), 1))
    }

    private static func drawPageNumberOverlay(_ text: String, position: PDFPageNumberPosition, fontSize: CGFloat, opacity: CGFloat, pageRect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: UIColor.black.withAlphaComponent(min(max(opacity, 0), 1)),
            .paragraphStyle: paragraphStyle
        ]
        let maxWidth = pageRect.width * 0.42
        let measuredSize = (text as NSString).boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).integral.size

        let margin = max(fontSize * 1.2, 24)
        let size = CGSize(width: min(max(measuredSize.width + 16, 48), maxWidth), height: measuredSize.height + 8)
        let origin: CGPoint

        switch position {
        case .bottomCenter:
            origin = CGPoint(x: (pageRect.width - size.width) / 2, y: pageRect.height - margin - size.height)
        case .bottomRight:
            origin = CGPoint(x: pageRect.width - margin - size.width, y: pageRect.height - margin - size.height)
        case .bottomLeft:
            origin = CGPoint(x: margin, y: pageRect.height - margin - size.height)
        case .topCenter:
            origin = CGPoint(x: (pageRect.width - size.width) / 2, y: margin)
        case .topRight:
            origin = CGPoint(x: pageRect.width - margin - size.width, y: margin)
        case .topLeft:
            origin = CGPoint(x: margin, y: margin)
        }

        (text as NSString).draw(in: CGRect(origin: origin, size: size), withAttributes: attributes)
    }

    private static func fittedSize(for imageSize: CGSize, in maxSize: CGSize) -> CGSize {
        guard imageSize.width > 0 && imageSize.height > 0 && maxSize.width > 0 && maxSize.height > 0 else {
            return .zero
        }

        let scale = min(maxSize.width / imageSize.width, maxSize.height / imageSize.height)
        return CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }

    private static func unclampedCenter(for normalizedCenter: CGPoint, in pageRect: CGRect) -> CGPoint {
        CGPoint(
            x: pageRect.width * min(max(normalizedCenter.x, 0), 1),
            y: pageRect.height * min(max(normalizedCenter.y, 0), 1)
        )
    }

    private static func centeredRect(for contentSize: CGSize, normalizedCenter: CGPoint, in pageRect: CGRect) -> CGRect {
        let x = pageRect.width * min(max(normalizedCenter.x, 0), 1)
        let y = pageRect.height * min(max(normalizedCenter.y, 0), 1)
        let originX = min(max(x - contentSize.width / 2, 0), max(pageRect.width - contentSize.width, 0))
        let originY = min(max(y - contentSize.height / 2, 0), max(pageRect.height - contentSize.height, 0))

        return CGRect(origin: CGPoint(x: originX, y: originY), size: contentSize)
    }

    /// Deletes selected pages and writes a new PDF.
    func deletePages(url: URL, pageIndices: IndexSet) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let sourceDoc = PDFDocument(url: url) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not open source PDF document."])
            }

            guard !sourceDoc.isLocked else {
                throw NSError(domain: "PDFProcessingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unlock this PDF before organizing it."])
            }

            guard sourceDoc.pageCount > 0 else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "The selected PDF does not contain any pages."])
            }

            guard !pageIndices.isEmpty else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Select at least one page to delete."])
            }

            guard pageIndices.count < sourceDoc.pageCount else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "A PDF must contain at least one page."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            let outputDoc = PDFDocument()
            var outputIndex = 0

            for pageIndex in 0..<sourceDoc.pageCount where !pageIndices.contains(pageIndex) {
                if let page = sourceDoc.page(at: pageIndex),
                   let pageCopy = page.copy() as? PDFPage {
                    outputDoc.insert(pageCopy, at: outputIndex)
                    outputIndex += 1
                }
            }

            guard outputDoc.write(to: tempUrl) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not write PDF after deleting pages."])
            }

            return tempUrl
        }.value
    }

    /// Reorders pages according to the provided zero-based source page order.
    func rearrangePages(url: URL, orderedPageIndices: [Int]) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let sourceDoc = PDFDocument(url: url) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not open source PDF document."])
            }

            guard !sourceDoc.isLocked else {
                throw NSError(domain: "PDFProcessingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unlock this PDF before organizing it."])
            }

            guard orderedPageIndices.count == sourceDoc.pageCount,
                  Set(orderedPageIndices) == Set(0..<sourceDoc.pageCount) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Page order is invalid."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            let outputDoc = PDFDocument()

            for (outputIndex, sourceIndex) in orderedPageIndices.enumerated() {
                if let page = sourceDoc.page(at: sourceIndex),
                   let pageCopy = page.copy() as? PDFPage {
                    outputDoc.insert(pageCopy, at: outputIndex)
                }
            }

            guard outputDoc.write(to: tempUrl) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not write rearranged PDF."])
            }

            return tempUrl
        }.value
    }

    /// Rotates selected pages clockwise and writes a new PDF.
    func rotatePages(url: URL, pageIndices: IndexSet, degrees: Int = 90) async throws -> URL {
        let pageRotations = Dictionary(uniqueKeysWithValues: pageIndices.map { ($0, degrees) })
        return try await rotatePages(url: url, pageRotations: pageRotations)
    }

    /// Rotates pages using zero-based page indices mapped to clockwise degree amounts.
    func rotatePages(url: URL, pageRotations: [Int: Int]) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let sourceDoc = PDFDocument(url: url) else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not open source PDF document."])
            }

            guard !sourceDoc.isLocked else {
                throw NSError(domain: "PDFProcessingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unlock this PDF before organizing it."])
            }

            guard !pageRotations.isEmpty else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Select at least one page to rotate."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            let outputDoc = PDFDocument()

            for pageIndex in 0..<sourceDoc.pageCount {
                if let page = sourceDoc.page(at: pageIndex),
                   let pageCopy = page.copy() as? PDFPage {
                    let degrees = ((pageRotations[pageIndex] ?? 0) % 360 + 360) % 360
                    if degrees > 0 {
                        pageCopy.rotation = (pageCopy.rotation + degrees) % 360
                    }
                    outputDoc.insert(pageCopy, at: pageIndex)
                }
            }

            guard outputDoc.write(to: tempUrl) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not write rotated PDF."])
            }

            return tempUrl
        }.value
    }

    /// Duplicates selected pages directly after their original page positions.
    func duplicatePages(url: URL, pageIndices: IndexSet) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            let sourceDoc = try Self.openEditableDocument(url: url, action: "duplicating pages")

            guard !pageIndices.isEmpty else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Select at least one page to duplicate."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            let outputDoc = PDFDocument()
            var outputIndex = 0

            for pageIndex in 0..<sourceDoc.pageCount {
                guard let page = sourceDoc.page(at: pageIndex),
                      let pageCopy = page.copy() as? PDFPage else { continue }

                outputDoc.insert(pageCopy, at: outputIndex)
                outputIndex += 1

                if pageIndices.contains(pageIndex),
                   let duplicateCopy = page.copy() as? PDFPage {
                    outputDoc.insert(duplicateCopy, at: outputIndex)
                    outputIndex += 1
                }
            }

            guard outputDoc.write(to: tempUrl) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not write duplicated PDF."])
            }

            return tempUrl
        }.value
    }

    /// Crops every page by normalized margins from each page edge.
    func cropPages(url: URL, margins: PDFCropMargins) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            let sourceDoc = try Self.openEditableDocument(url: url, action: "cropping pages")

            guard margins.isValid else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Crop margins leave no visible page area."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            let outputDoc = PDFDocument()

            for pageIndex in 0..<sourceDoc.pageCount {
                guard let page = sourceDoc.page(at: pageIndex),
                      let pageCopy = page.copy() as? PDFPage else { continue }

                let mediaBox = pageCopy.bounds(for: .mediaBox)
                let cropBox = CGRect(
                    x: mediaBox.minX + mediaBox.width * margins.left,
                    y: mediaBox.minY + mediaBox.height * margins.bottom,
                    width: mediaBox.width * (1 - margins.left - margins.right),
                    height: mediaBox.height * (1 - margins.top - margins.bottom)
                )

                pageCopy.setBounds(cropBox, for: .cropBox)
                outputDoc.insert(pageCopy, at: pageIndex)
            }

            guard outputDoc.write(to: tempUrl) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not write cropped PDF."])
            }

            return tempUrl
        }.value
    }

    /// Reverses every page in the PDF.
    func reversePages(url: URL) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            let sourceDoc = try Self.openEditableDocument(url: url, action: "reversing pages")

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "pdf")
            let outputDoc = PDFDocument()
            var outputIndex = 0

            for pageIndex in stride(from: sourceDoc.pageCount - 1, through: 0, by: -1) {
                guard let page = sourceDoc.page(at: pageIndex),
                      let pageCopy = page.copy() as? PDFPage else { continue }

                outputDoc.insert(pageCopy, at: outputIndex)
                outputIndex += 1
            }

            guard outputDoc.write(to: tempUrl) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not write reversed PDF."])
            }

            return tempUrl
        }.value
    }

    /// Renders all pages vertically into one long JPEG image.
    func renderLongImage(url: URL, quality: CGFloat = 0.9) async throws -> (url: URL, size: Int64) {
        return try await Task.detached(priority: .userInitiated) {
            let sourceDoc = try Self.openEditableDocument(url: url, action: "converting to a long image")

            let pageBoxes = (0..<sourceDoc.pageCount).compactMap { index -> (page: PDFPage, bounds: CGRect)? in
                guard let page = sourceDoc.page(at: index) else { return nil }
                return (page, page.bounds(for: .cropBox))
            }

            guard !pageBoxes.isEmpty else {
                throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "The selected PDF does not contain any pages."])
            }

            let maxPageWidth = pageBoxes.map { $0.bounds.width }.max() ?? 1
            let totalHeight = pageBoxes.reduce(CGFloat(0)) { $0 + $1.bounds.height }
            let widthScale = min(1600 / maxPageWidth, 1.5)
            let heightScale = min(24000 / max(totalHeight, 1), widthScale)
            let scale = max(min(widthScale, heightScale), 0.2)
            let outputSize = CGSize(width: maxPageWidth * scale, height: totalHeight * scale)

            let format = UIGraphicsImageRendererFormat()
            format.scale = 1.0
            format.opaque = true

            let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)
            let image = renderer.image { rendererContext in
                let context = rendererContext.cgContext
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: outputSize))

                var yOffset: CGFloat = 0

                for item in pageBoxes {
                    let page = item.page
                    let bounds = item.bounds
                    let pageSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)
                    let xOffset = (outputSize.width - pageSize.width) / 2
                    let targetRect = CGRect(x: xOffset, y: yOffset, width: pageSize.width, height: pageSize.height)

                    UIColor.white.setFill()
                    context.fill(targetRect)

                    context.saveGState()
                    context.translateBy(x: targetRect.minX, y: targetRect.maxY)
                    context.scaleBy(x: scale, y: -scale)
                    context.translateBy(x: -bounds.minX, y: -bounds.minY)
                    page.draw(with: .cropBox, to: context)
                    context.restoreGState()

                    yOffset += pageSize.height
                }
            }

            guard let data = image.jpegData(compressionQuality: quality) else {
                throw NSError(domain: "PDFProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not encode long image."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "jpg")
            try data.write(to: tempUrl, options: .atomic)
            return (tempUrl, Int64(data.count))
        }.value
    }

    private static func openEditableDocument(url: URL, action: String) throws -> PDFDocument {
        guard let sourceDoc = PDFDocument(url: url) else {
            throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not open source PDF document."])
        }

        guard !sourceDoc.isLocked else {
            throw NSError(domain: "PDFProcessingService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unlock this PDF before \(action)."])
        }

        guard sourceDoc.pageCount > 0 else {
            throw NSError(domain: "PDFProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "The selected PDF does not contain any pages."])
        }

        return sourceDoc
    }
}

struct PDFCropMargins {
    let top: CGFloat
    let bottom: CGFloat
    let left: CGFloat
    let right: CGFloat

    var isValid: Bool {
        top >= 0 && bottom >= 0 && left >= 0 && right >= 0 && top + bottom < 0.9 && left + right < 0.9
    }
}
