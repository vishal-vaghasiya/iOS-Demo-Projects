//
//  ProcessImageUseCase.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import UIKit
internal import Foundation

class ProcessImageUseCase {
    private let imageService: ImageProcessingService
    private let repository: FileRepositoryProtocol
    
    init(imageService: ImageProcessingService = .shared, repository: FileRepositoryProtocol = FileRepository()) {
        self.imageService = imageService
        self.repository = repository
    }
    
    func compressImage(image: UIImage, quality: CGFloat, format: ImageFormat, preferredName: String) async throws -> SavedFile {
        let (tempUrl, size) = try await imageService.compressImage(image: image, quality: quality, format: format)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: format.fileExtension, size: size, operation: "Compress Image")
    }
    
    func resizeImage(image: UIImage, width: CGFloat, height: CGFloat, keepAspectRatio: Bool, format: ImageFormat, preferredName: String) async throws -> SavedFile {
        let resizedImage = try await imageService.resizeImage(image: image, targetWidth: width, targetHeight: height, preserveAspectRatio: keepAspectRatio)
        let (tempUrl, size) = try await imageService.compressImage(image: resizedImage, quality: 0.9, format: format)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: format.fileExtension, size: size, operation: "Resize Image")
    }
    
    func convertImage(image: UIImage, targetFormat: ImageFormat, preferredName: String) async throws -> SavedFile {
        let (tempUrl, size) = try await imageService.compressImage(image: image, quality: 0.9, format: targetFormat)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: targetFormat.fileExtension, size: size, operation: "Convert Image")
    }

    func prepareConvertedImage(image: UIImage, targetFormat: ImageFormat, preferredName: String) async throws -> ProcessedFileResult {
        let (tempUrl, size) = try await imageService.compressImage(image: image, quality: 0.9, format: targetFormat)
        return ProcessedFileResult(
            url: tempUrl,
            name: (preferredName as NSString).deletingPathExtension,
            fileType: targetFormat.fileExtension,
            fileSize: size,
            sourceOperation: "Convert Image"
        )
    }

    func editImage(image: UIImage, configuration: ImageEditConfiguration, format: ImageFormat, preferredName: String) async throws -> SavedFile {
        let editedImage = try await imageService.editImage(image: image, configuration: configuration)
        let (tempUrl, size) = try await imageService.compressImage(image: editedImage, quality: 0.92, format: format)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: format.fileExtension, size: size, operation: "Edit Image")
    }

    func previewEditedImage(image: UIImage, configuration: ImageEditConfiguration) async throws -> UIImage {
        return try await imageService.editImage(image: image, configuration: configuration)
    }

    func convertImageFile(url: URL, targetFormat: ImageFormat, preferredName: String, operation: String) async throws -> SavedFile {
        let (tempUrl, size) = try await imageService.convertImageFile(url: url, targetFormat: targetFormat)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: targetFormat.fileExtension, size: size, operation: operation)
    }

    func prepareConvertedImageFile(url: URL, targetFormat: ImageFormat, preferredName: String, operation: String) async throws -> ProcessedFileResult {
        let (tempUrl, size) = try await imageService.convertImageFile(url: url, targetFormat: targetFormat)
        return ProcessedFileResult(
            url: tempUrl,
            name: (preferredName as NSString).deletingPathExtension,
            fileType: targetFormat.fileExtension,
            fileSize: size,
            sourceOperation: operation
        )
    }

    func splitGIF(url: URL, preferredName: String) async throws -> [SavedFile] {
        let outputs = try await imageService.splitGIF(url: url, targetFormat: .png)
        var savedFiles: [SavedFile] = []
        savedFiles.reserveCapacity(outputs.count)

        for (index, output) in outputs.enumerated() {
            let name = outputs.count == 1 ? preferredName : "\(preferredName)_frame_\(index + 1)"
            let savedFile = try saveAndRegisterFile(
                tempUrl: output.url,
                name: name,
                type: ImageFormat.png.fileExtension,
                size: output.size,
                operation: "GIF to Images"
            )
            savedFiles.append(savedFile)
        }

        return savedFiles
    }

    func prepareSplitGIF(url: URL, preferredName: String) async throws -> [ProcessedFileResult] {
        let outputs = try await imageService.splitGIF(url: url, targetFormat: .png)
        return outputs.enumerated().map { index, output in
            let name = outputs.count == 1 ? preferredName : "\(preferredName)_frame_\(index + 1)"
            return ProcessedFileResult(
                url: output.url,
                name: (name as NSString).deletingPathExtension,
                fileType: ImageFormat.png.fileExtension,
                fileSize: output.size,
                sourceOperation: "GIF to Images"
            )
        }
    }

    func createGIF(images: [UIImage], preferredName: String) async throws -> SavedFile {
        let (tempUrl, size) = try await imageService.createGIF(images: images)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: "gif", size: size, operation: "Images to GIF")
    }

    func prepareGIF(images: [UIImage], preferredName: String, operation: String) async throws -> ProcessedFileResult {
        let (tempUrl, size) = try await imageService.createGIF(images: images)
        return ProcessedFileResult(
            url: tempUrl,
            name: (preferredName as NSString).deletingPathExtension,
            fileType: "gif",
            fileSize: size,
            sourceOperation: operation
        )
    }

    func convertLivePhoto(image: UIImage, preferredName: String) async throws -> SavedFile {
        let (tempUrl, size) = try await imageService.compressImage(image: image, quality: 0.95, format: .jpeg)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: ImageFormat.jpeg.fileExtension, size: size, operation: "Convert Live Photos")
    }

    func extractFrameFromVideo(url: URL, at seconds: Double, preferredName: String) async throws -> SavedFile {
        let (tempUrl, size) = try await imageService.extractFrameFromVideo(url: url, at: seconds)
        return try saveAndRegisterFile(tempUrl: tempUrl, name: preferredName, type: ImageFormat.jpeg.fileExtension, size: size, operation: "Extract Frame from Video")
    }
    
    func rotateImage(image: UIImage, angle: Double) async throws -> UIImage {
        return try await imageService.rotateImage(image: image, rotationAngle: angle)
    }
    
    func cropImage(image: UIImage, relativeRect: CGRect) async throws -> UIImage {
        return try await imageService.cropImage(image: image, to: relativeRect)
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
