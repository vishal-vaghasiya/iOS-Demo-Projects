//
//  UtilityMediaPickers.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct LivePhotoStillPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var selectionLimit: Int = AppConstants.maxImageSelectionCount

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .livePhotos
        configuration.selectionLimit = selectionLimit

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: LivePhotoStillPicker

        init(_ parent: LivePhotoStillPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else { return }

            let group = DispatchGroup()
            var images = Array(repeating: UIImage(), count: results.count)
            var loadedIndices = Set<Int>()

            for (index, result) in results.enumerated() {
                group.enter()
                let provider = result.itemProvider
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let image = image as? UIImage {
                            images[index] = image
                            loadedIndices.insert(index)
                        }
                        group.leave()
                    }
                } else {
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                let loadedImages = images.enumerated()
                    .filter { loadedIndices.contains($0.offset) }
                    .map { $0.element }
                self.parent.selectedImages.append(contentsOf: loadedImages)
            }
        }
    }
}

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedURLs: [URL]
    var selectionLimit: Int = AppConstants.maxImageSelectionCount

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .videos
        configuration.selectionLimit = selectionLimit

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else { return }

            let group = DispatchGroup()
            var urls = Array(repeating: URL(fileURLWithPath: ""), count: results.count)
            var loadedIndices = Set<Int>()

            for (index, result) in results.enumerated() {
                group.enter()
                let provider = result.itemProvider
                let typeIdentifier = provider.registeredTypeIdentifiers.first {
                    UTType($0)?.conforms(to: .movie) == true
                } ?? UTType.movie.identifier

                provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, _ in
                    defer { group.leave() }
                    guard let url else { return }

                    let fileExtension = url.pathExtension.isEmpty ? "mov" : url.pathExtension
                    let targetURL = TempFileManager.shared.getTempUrl(extension: fileExtension)

                    do {
                        if FileManager.default.fileExists(atPath: targetURL.path) {
                            try FileManager.default.removeItem(at: targetURL)
                        }

                        try FileManager.default.copyItem(at: url, to: targetURL)
                        urls[index] = targetURL
                        loadedIndices.insert(index)
                    } catch {
                        return
                    }
                }
            }

            group.notify(queue: .main) {
                let loadedURLs = urls.enumerated()
                    .filter { loadedIndices.contains($0.offset) }
                    .map { $0.element }
                self.parent.selectedURLs.append(contentsOf: loadedURLs)
            }
        }
    }
}
