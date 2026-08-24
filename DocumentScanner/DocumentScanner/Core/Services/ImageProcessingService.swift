//
//  ImageProcessingService.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreGraphics
import ImageIO
import UIKit

enum ImageFormat: String, CaseIterable, Identifiable {
    case jpeg = "jpeg"
    case png = "png"
    case heic = "heic"
    case webp = "webp"
    
    var id: String { self.rawValue }
    var fileExtension: String {
        switch self {
        case .jpeg: return "jpg"
        case .png: return "png"
        case .heic: return "heic"
        case .webp: return "webp"
        }
    }
}

struct ImageEditConfiguration {
    let cropRect: CGRect
    let rotationDegrees: Double
    let flipHorizontal: Bool
    let flipVertical: Bool
    let brightness: CGFloat
    let contrast: CGFloat
    let saturation: CGFloat
    let sharpness: CGFloat
}

class ImageProcessingService {
    static let shared = ImageProcessingService()
    
    private init() {}
    
    /// Compresses an image with a specific quality slider level and returns the temp file URL and actual byte size.
    func compressImage(image: UIImage, quality: CGFloat, format: ImageFormat = .jpeg) async throws -> (url: URL, size: Int64) {
        return try await Task.detached(priority: .userInitiated) {
            let tempUrl = TempFileManager.shared.getTempUrl(extension: format.fileExtension)
            
            let data: Data?
            switch format {
            case .jpeg:
                data = image.jpegData(compressionQuality: quality)
            case .png:
                // PNG is lossless, compression factor is not directly supported by pngData().
                // However, we can compress by reducing the pixel size first or rendering onto smaller canvas if needed,
                // or just exporting pngData. To simulate PNG compression, we write pngData.
                data = image.pngData()
            case .heic:
                // Fallback to jpeg for systems/simulators where HEIC encoding isn't natively writable via UIImageDataWriter,
                // or use AVFoundation AVFileTypeHEIC writer.
                // Standard production fallback is JPEG or HEIC using CGImageDestination.
                data = try self.encodeToHEIC(image: image, quality: quality)
            case .webp:
                data = try self.encode(image: image, typeIdentifier: "org.webmproject.webp", quality: quality)
            }
            
            guard let finalData = data else {
                throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to compress and encode image."])
            }
            
            try finalData.write(to: tempUrl, options: .atomic)
            let size = Int64(finalData.count)
            return (tempUrl, size)
        }.value
    }
    
    /// Resizes an image to custom dimensions, option to preserve aspect ratio.
    func resizeImage(image: UIImage, targetWidth: CGFloat, targetHeight: CGFloat, preserveAspectRatio: Bool) async throws -> UIImage {
        return try await Task.detached(priority: .userInitiated) {
            var drawSize = CGSize(width: targetWidth, height: targetHeight)
            
            if preserveAspectRatio {
                let originalSize = image.size
                let widthRatio = targetWidth / originalSize.width
                let heightRatio = targetHeight / originalSize.height
                let ratio = min(widthRatio, heightRatio)
                drawSize = CGSize(width: originalSize.width * ratio, height: originalSize.height * ratio)
            }
            
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1.0 // Ensure output matches exact pixel dimensions requested
            
            let renderer = UIGraphicsImageRenderer(size: drawSize, format: format)
            let resized = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: drawSize))
            }
            
            return resized
        }.value
    }
    
    /// Non-destructively rotates an image by 90-degree increments.
    func rotateImage(image: UIImage, rotationAngle: Double) async throws -> UIImage {
        return try await Task.detached(priority: .userInitiated) {
            guard let cgImage = image.cgImage else { return image }
            
            let radians = CGFloat(rotationAngle * .pi / 180.0)
            let width = image.size.width
            let height = image.size.height
            
            // Calculate size of new rotated boundary box
            var newRect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
                .applying(CGAffineTransform(rotationAngle: radians))
            
            // Core Graphics coords can result in fractional offsets
            newRect.origin = .zero
            
            let format = UIGraphicsImageRendererFormat()
            format.scale = image.scale
            
            let renderer = UIGraphicsImageRenderer(size: newRect.size, format: format)
            let rotatedImage = renderer.image { context in
                let cgContext = context.cgContext
                
                // Move origin to center of drawing context
                cgContext.translateBy(x: newRect.width / 2.0, y: newRect.height / 2.0)
                cgContext.rotate(by: radians)
                
                // Flip context back for drawing CGImage correctly
                cgContext.scaleBy(x: 1.0, y: -1.0)
                
                let drawRect = CGRect(x: -width / 2.0, y: -height / 2.0, width: width, height: height)
                cgContext.draw(cgImage, in: drawRect)
            }
            
            return rotatedImage
        }.value
    }
    
    /// Crops an image to a specific relative unit rect.
    func cropImage(image: UIImage, to rect: CGRect) async throws -> UIImage {
        return try await Task.detached(priority: .userInitiated) {
            guard let cgImage = image.cgImage else { return image }
            
            // Map crop rect percentage/relative dimensions to absolute pixels
            let cgWidth = CGFloat(cgImage.width)
            let cgHeight = CGFloat(cgImage.height)
            
            let absoluteRect = CGRect(
                x: rect.origin.x * cgWidth,
                y: rect.origin.y * cgHeight,
                width: rect.size.width * cgWidth,
                height: rect.size.height * cgHeight
            )
            
            guard let croppedCgImage = cgImage.cropping(to: absoluteRect) else {
                throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to crop image context."])
            }
            
            return UIImage(cgImage: croppedCgImage, scale: image.scale, orientation: image.imageOrientation)
        }.value
    }

    /// Applies all image editor operations in a stable order so preview and save match.
    func editImage(image: UIImage, configuration: ImageEditConfiguration) async throws -> UIImage {
        return try await Task.detached(priority: .userInitiated) {
            var result = Self.normalizedImage(image)
            result = try Self.croppedImage(result, relativeRect: configuration.cropRect)

            if configuration.rotationDegrees.truncatingRemainder(dividingBy: 360) != 0 {
                result = Self.rotatedImage(result, degrees: configuration.rotationDegrees)
            }

            if configuration.flipHorizontal || configuration.flipVertical {
                result = Self.flippedImage(
                    result,
                    horizontal: configuration.flipHorizontal,
                    vertical: configuration.flipVertical
                )
            }

            return try Self.adjustedImage(
                result,
                brightness: configuration.brightness,
                contrast: configuration.contrast,
                saturation: configuration.saturation,
                sharpness: configuration.sharpness
            )
        }.value
    }
    
    // HEIC encoder utilizing CGImageDestination
    private func encodeToHEIC(image: UIImage, quality: CGFloat) throws -> Data {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ImageProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "CGImage is missing."])
        }
        
        let data = NSMutableData()
        let type = "public.heic" as CFString
        
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, type, 1, nil) else {
            // HEIC not supported (e.g. simulator fallback) -> encode to JPEG
            guard let jpegData = image.jpegData(compressionQuality: quality) else {
                throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize image encoder."])
            }
            return jpegData
        }
        
        let options = [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)
        
        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize HEIC data."])
        }
        
        return data as Data
    }

    func convertImageFile(url: URL, targetFormat: ImageFormat, quality: CGFloat = 0.9) async throws -> (url: URL, size: Int64) {
        return try await Task.detached(priority: .userInitiated) {
            guard let image = UIImage(contentsOfFile: url.path) ?? Self.imageFromImageSource(url: url) else {
                throw NSError(domain: "ImageProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not read the selected image."])
            }

            return try self.encodeImageToTempFile(image: image, format: targetFormat, quality: quality)
        }.value
    }

    func splitGIF(url: URL, targetFormat: ImageFormat = .png, quality: CGFloat = 0.9) async throws -> [(url: URL, size: Int64)] {
        return try await Task.detached(priority: .userInitiated) {
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
                throw NSError(domain: "ImageProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not open the selected GIF."])
            }

            let frameCount = CGImageSourceGetCount(source)
            guard frameCount > 0 else {
                throw NSError(domain: "ImageProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "The selected GIF does not contain any frames."])
            }

            var outputs: [(url: URL, size: Int64)] = []
            outputs.reserveCapacity(frameCount)

            for index in 0..<frameCount {
                guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
                let image = UIImage(cgImage: cgImage)
                outputs.append(try self.encodeImageToTempFile(image: image, format: targetFormat, quality: quality))
            }

            return outputs
        }.value
    }

    func createGIF(images: [UIImage], frameDuration: Double = 0.25) async throws -> (url: URL, size: Int64) {
        return try await Task.detached(priority: .userInitiated) {
            guard !images.isEmpty else {
                throw NSError(domain: "ImageProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Select at least one image to create a GIF."])
            }

            let tempUrl = TempFileManager.shared.getTempUrl(extension: "gif")
            guard let destination = CGImageDestinationCreateWithURL(tempUrl as CFURL, "com.compuserve.gif" as CFString, images.count, nil) else {
                throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not create GIF destination."])
            }

            let gifProperties = [
                kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFLoopCount: 0
                ]
            ] as CFDictionary
            CGImageDestinationSetProperties(destination, gifProperties)

            let frameProperties = [
                kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFDelayTime: frameDuration
                ]
            ] as CFDictionary

            for image in images {
                guard let cgImage = image.cgImage else { continue }
                CGImageDestinationAddImage(destination, cgImage, frameProperties)
            }

            guard CGImageDestinationFinalize(destination) else {
                throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not finalize GIF."])
            }

            let attributes = try FileManager.default.attributesOfItem(atPath: tempUrl.path)
            let size = attributes[.size] as? Int64 ?? 0
            return (tempUrl, size)
        }.value
    }

    func extractFrameFromVideo(url: URL, at seconds: Double, quality: CGFloat = 0.92) async throws -> (url: URL, size: Int64) {
        return try await Task.detached(priority: .userInitiated) {
            let asset = AVURLAsset(url: url)
            let duration = try await asset.load(.duration)
            let durationSeconds = CMTimeGetSeconds(duration)
            let safeDuration = durationSeconds.isFinite ? max(durationSeconds, 0) : 0
            let requestedSeconds = max(seconds, 0)
            let clampedSeconds = safeDuration > 0 ? min(requestedSeconds, safeDuration) : requestedSeconds
            let time = CMTime(seconds: clampedSeconds, preferredTimescale: 600)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = .zero

            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: cgImage)
                return try self.encodeImageToTempFile(image: image, format: .jpeg, quality: quality)
            } catch {
                throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not extract a frame from this video."])
            }
        }.value
    }

    private func encodeImageToTempFile(image: UIImage, format: ImageFormat, quality: CGFloat) throws -> (url: URL, size: Int64) {
        let tempUrl = TempFileManager.shared.getTempUrl(extension: format.fileExtension)
        let data: Data?

        switch format {
        case .jpeg:
            data = image.jpegData(compressionQuality: quality)
        case .png:
            data = image.pngData()
        case .heic:
            data = try encodeToHEIC(image: image, quality: quality)
        case .webp:
            data = try encode(image: image, typeIdentifier: "org.webmproject.webp", quality: quality)
        }

        guard let outputData = data else {
            throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not encode image."])
        }

        try outputData.write(to: tempUrl, options: .atomic)
        return (tempUrl, Int64(outputData.count))
    }

    private func encode(image: UIImage, typeIdentifier: String, quality: CGFloat) throws -> Data {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ImageProcessingService", code: 400, userInfo: [NSLocalizedDescriptionKey: "CGImage is missing."])
        }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, typeIdentifier as CFString, 1, nil) else {
            throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "This image format is not supported on this device."])
        }

        let options = [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)

        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize image data."])
        }

        return data as Data
    }

    private static func imageFromImageSource(url: URL) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    private static func normalizedImage(_ image: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: image.size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    private static func croppedImage(_ image: UIImage, relativeRect: CGRect) throws -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let safeRect = CGRect(
            x: min(max(relativeRect.minX, 0), 1),
            y: min(max(relativeRect.minY, 0), 1),
            width: min(max(relativeRect.width, 0.01), 1),
            height: min(max(relativeRect.height, 0.01), 1)
        ).intersection(CGRect(x: 0, y: 0, width: 1, height: 1))

        let cropRect = CGRect(
            x: safeRect.minX * CGFloat(cgImage.width),
            y: safeRect.minY * CGFloat(cgImage.height),
            width: safeRect.width * CGFloat(cgImage.width),
            height: safeRect.height * CGFloat(cgImage.height)
        ).integral

        guard let cropped = cgImage.cropping(to: cropRect) else {
            throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to crop image context."])
        }

        return UIImage(cgImage: cropped, scale: image.scale, orientation: .up)
    }

    private static func rotatedImage(_ image: UIImage, degrees: Double) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let radians = CGFloat(degrees * .pi / 180)
        let sourceSize = image.size
        var outputRect = CGRect(origin: .zero, size: sourceSize).applying(CGAffineTransform(rotationAngle: radians))
        outputRect.origin = .zero

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: outputRect.size, format: format).image { context in
            let cgContext = context.cgContext
            cgContext.translateBy(x: outputRect.width / 2, y: outputRect.height / 2)
            cgContext.rotate(by: radians)
            cgContext.scaleBy(x: 1, y: -1)
            cgContext.draw(cgImage, in: CGRect(
                x: -sourceSize.width / 2,
                y: -sourceSize.height / 2,
                width: sourceSize.width,
                height: sourceSize.height
            ))
        }
    }

    private static func flippedImage(_ image: UIImage, horizontal: Bool, vertical: Bool) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: image.size, format: format).image { _ in
            var transform = CGAffineTransform.identity

            if horizontal {
                transform = transform.translatedBy(x: image.size.width, y: 0).scaledBy(x: -1, y: 1)
            }

            if vertical {
                transform = transform.translatedBy(x: 0, y: image.size.height).scaledBy(x: 1, y: -1)
            }

            let context = UIGraphicsGetCurrentContext()
            context?.concatenate(transform)
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    private static func adjustedImage(_ image: UIImage, brightness: CGFloat, contrast: CGFloat, saturation: CGFloat, sharpness: CGFloat) throws -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = ciImage
        colorControls.brightness = Float(brightness)
        colorControls.contrast = Float(contrast)
        colorControls.saturation = Float(saturation)

        let sharpen = CIFilter.sharpenLuminance()
        sharpen.inputImage = colorControls.outputImage
        sharpen.sharpness = Float(sharpness)

        guard let output = sharpen.outputImage else { return image }
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(output, from: output.extent) else {
            throw NSError(domain: "ImageProcessingService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not render adjusted image."])
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
    }
}
