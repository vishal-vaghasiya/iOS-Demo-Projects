//
//  ImageFormatUtilityView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

enum ImageFormatUtilityMode {
    case convertToHEIC
    case convertToWebP
    case convertToJPG
    case convertToPNG
    case convertToGIF
    case webpToJpg
    case webpToPng
    case jpgToWebp
    case pngToWebp
    case gifToImages
    case imagesToGif

    var title: String {
        switch self {
        case .convertToHEIC: return "Convert to HEIC"
        case .convertToWebP: return "Convert to WEBP"
        case .convertToJPG: return "Convert to JPG"
        case .convertToPNG: return "Convert to PNG"
        case .convertToGIF: return "Convert to GIF"
        case .webpToJpg: return Strings.ImageTools.webpToJpgTitle
        case .webpToPng: return Strings.ImageTools.webpToPngTitle
        case .jpgToWebp: return Strings.ImageTools.jpgToWebpTitle
        case .pngToWebp: return Strings.ImageTools.pngToWebpTitle
        case .gifToImages: return Strings.ImageTools.gifToImagesTitle
        case .imagesToGif: return Strings.ImageTools.imagesToGifTitle
        }
    }

    var dashboardTitle: String {
        switch self {
        case .convertToHEIC: return "Convert to HEIC"
        case .convertToWebP: return "Convert to WEBP"
        case .convertToJPG: return "Convert to JPG"
        case .convertToPNG: return "Convert to PNG"
        case .convertToGIF: return "Convert to GIF"
        case .webpToJpg: return "WEBP to JPG"
        case .webpToPng: return "WEBP to PNG"
        case .jpgToWebp: return "JPG to WEBP"
        case .pngToWebp: return "PNG to WEBP"
        case .gifToImages: return "GIF to Images"
        case .imagesToGif: return "Images to GIF"
        }
    }

    var description: String {
        switch self {
        case .convertToHEIC: return "Convert selected image files into compact HEIC images."
        case .convertToWebP: return "Convert selected image files into WEBP images."
        case .convertToJPG: return "Convert selected image files into JPG photos."
        case .convertToPNG: return "Convert selected image files into PNG images."
        case .convertToGIF: return "Combine selected images into an animated GIF."
        case .webpToJpg: return "Convert WEBP files into JPG images."
        case .webpToPng: return "Convert WEBP files into PNG images."
        case .jpgToWebp: return "Convert JPG photos into WEBP files."
        case .pngToWebp: return "Convert PNG images into WEBP files."
        case .gifToImages: return "Extract GIF frames as PNG images."
        case .imagesToGif: return "Combine selected images into an animated GIF."
        }
    }

    var iconName: String {
        switch self {
        case .convertToHEIC, .convertToWebP, .convertToJPG, .convertToPNG, .webpToJpg, .webpToPng, .jpgToWebp, .pngToWebp:
            return Images.System.imageFormatConvert
        case .convertToGIF:
            return Images.System.imagesToGif
        case .gifToImages:
            return Images.System.gifToImages
        case .imagesToGif:
            return Images.System.imagesToGif
        }
    }

    var sourceTypes: [UTType] {
        switch self {
        case .convertToHEIC, .convertToWebP, .convertToJPG, .convertToPNG:
            return [.image]
        case .convertToGIF:
            return [.image]
        case .webpToJpg, .webpToPng:
            return [UTType(filenameExtension: "webp") ?? .image]
        case .jpgToWebp:
            return [.jpeg]
        case .pngToWebp:
            return [.png]
        case .gifToImages:
            return [.gif]
        case .imagesToGif:
            return [.image]
        }
    }

    var targetFormat: ImageFormat? {
        switch self {
        case .convertToHEIC: return .heic
        case .convertToWebP: return .webp
        case .convertToJPG: return .jpeg
        case .convertToPNG: return .png
        case .convertToGIF: return nil
        case .webpToJpg: return .jpeg
        case .webpToPng: return .png
        case .jpgToWebp, .pngToWebp: return .webp
        case .gifToImages, .imagesToGif: return nil
        }
    }

    var defaultFileName: String {
        switch self {
        case .convertToHEIC: return "converted_heic"
        case .convertToWebP: return "converted_webp"
        case .convertToJPG: return "converted_jpg"
        case .convertToPNG: return "converted_png"
        case .convertToGIF: return "converted_gif"
        case .webpToJpg: return "webp_converted_jpg"
        case .webpToPng: return "webp_converted_png"
        case .jpgToWebp: return "jpg_converted_webp"
        case .pngToWebp: return "png_converted_webp"
        case .gifToImages: return "gif_frame"
        case .imagesToGif: return "animated_images"
        }
    }

    var loadingMessage: String {
        switch self {
        case .gifToImages: return "Extracting GIF frames..."
        case .convertToGIF, .imagesToGif: return "Creating GIF..."
        default: return "Converting image..."
        }
    }
}

struct ConvertToHEICView: View { var body: some View { ImageFormatUtilityView(mode: .convertToHEIC) } }
struct ConvertToWebPView: View { var body: some View { ImageFormatUtilityView(mode: .convertToWebP) } }
struct ConvertToJPGView: View { var body: some View { ImageFormatUtilityView(mode: .convertToJPG) } }
struct ConvertToPNGView: View { var body: some View { ImageFormatUtilityView(mode: .convertToPNG) } }
struct ConvertToGIFView: View { var body: some View { ImageFormatUtilityView(mode: .convertToGIF) } }
struct WebPToJPGView: View { var body: some View { ImageFormatUtilityView(mode: .webpToJpg) } }
struct WebPToPNGView: View { var body: some View { ImageFormatUtilityView(mode: .webpToPng) } }
struct JPGToWebPView: View { var body: some View { ImageFormatUtilityView(mode: .jpgToWebp) } }
struct PNGToWebPView: View { var body: some View { ImageFormatUtilityView(mode: .pngToWebp) } }
struct GIFToImagesView: View { var body: some View { ImageFormatUtilityView(mode: .gifToImages) } }
struct ImagesToGIFView: View { var body: some View { ImageFormatUtilityView(mode: .imagesToGif) } }

struct ImageFormatUtilityView: View {
    @Environment(\.presentationMode) private var presentationMode

    private let mode: ImageFormatUtilityMode

    @State private var selectedURLs: [URL] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showDocumentPicker = false
    @State private var showImagePicker = false
    @State private var fileName = ""
    @State private var isProcessing = false
    @State private var processedResults: [ProcessedFileResult] = []
    @State private var errorMessage: String?

    private let imageUseCase = ProcessImageUseCase()

    init(mode: ImageFormatUtilityMode) {
        self.mode = mode
    }

    var body: some View {
        VStack(spacing: 0) {
            if !processedResults.isEmpty {
                ProcessedResultsPreviewView(
                    title: "\(mode.title) Preview",
                    defaultFolderName: outputBaseName,
                    operationIcon: mode.iconName,
                    onDone: { presentationMode.wrappedValue.dismiss() },
                    results: $processedResults
                )
            } else if selectedURLs.isEmpty && selectedImages.isEmpty {
                emptyState
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 22) {
                        selectionSummary
                        outputNameField
                        feedbackArea
                        actionArea
                    }
                    .padding(.top)
                }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(
                selectedUrls: $selectedURLs,
                allowedContentTypes: mode.sourceTypes,
                allowsMultipleSelection: true
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
    }

    private var emptyState: some View {
        Button(action: showPicker) {
            VStack(spacing: 16) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 48))
                    .foregroundColor(.appSecondary)

                Text(mode.title)
                    .appFont(.appTitle3, weight: .bold, color: .appPrimary)

                Text(mode.description)
                    .appFont(.appBody, color: .appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .cardStyle()
            .padding()
        }
    }

    private var selectionSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(summaryTitle)
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                Spacer()
                Button("Add More") {
                    showPicker()
                }
                .appFont(.appCallout, weight: .semibold, color: .appPrimary)
            }

            if mode == .imagesToGif || mode == .convertToGIF {
                imagePreviewStrip
            } else {
                fileList
            }
        }
        .cardStyle()
        .padding(.horizontal)
    }

    private var imagePreviewStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(selectedImages.indices, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: selectedImages[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 74, height: 74)
                            .cornerRadius(8)
                            .clipped()

                        Button(action: { selectedImages.remove(at: index) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6).clipShape(Circle()))
                                .padding(2)
                        }
                    }
                }
            }
        }
    }

    private var fileList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(selectedURLs, id: \.self) { url in
                HStack(spacing: 8) {
                    Image(systemName: "doc")
                        .foregroundColor(.appSecondary)
                    Text(url.lastPathComponent)
                        .appFont(.appCaption, color: .appTextSecondary)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        selectedURLs.removeAll { $0 == url }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
        }
    }

    private var outputNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.PDFTools.enterFileName)
                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

            TextField("e.g. \(mode.defaultFileName)", text: $fileName)
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appSeparator, lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var feedbackArea: some View {
        if let errorMessage {
            Text(errorMessage)
                .appFont(.appCallout, color: .appError)
                .padding(.horizontal)
        }

        EmptyView()
    }

    private var actionArea: some View {
        Group {
            if isProcessing {
                LoadingView(message: mode.loadingMessage)
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: actionTitle,
                    iconName: mode.iconName,
                    isEnabled: canConvert
                ) {
                    Task { await convert() }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private var summaryTitle: String {
        if mode == .imagesToGif || mode == .convertToGIF {
            return "Selected Images (\(selectedImages.count))"
        }

        return "Selected Files (\(selectedURLs.count))"
    }

    private var actionTitle: String {
        switch mode {
        case .gifToImages:
            return "Extract Images"
        case .convertToGIF, .imagesToGif:
            return "Create GIF"
        default:
            return "Convert"
        }
    }

    private var canConvert: Bool {
        (mode == .imagesToGif || mode == .convertToGIF) ? !selectedImages.isEmpty : !selectedURLs.isEmpty
    }

    private var outputBaseName: String {
        fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? mode.defaultFileName : fileName
    }

    private func showPicker() {
        if mode == .imagesToGif || mode == .convertToGIF {
            showImagePicker = true
        } else {
            showDocumentPicker = true
        }
    }

    @MainActor
    private func convert() async {
        isProcessing = true
        errorMessage = nil
        processedResults.removeAll()

        let baseName = outputBaseName

        do {
            var newResults: [ProcessedFileResult] = []
            switch mode {
            case .convertToHEIC, .convertToWebP, .convertToJPG, .convertToPNG, .webpToJpg, .webpToPng, .jpgToWebp, .pngToWebp:
                guard let targetFormat = mode.targetFormat else { break }
                for (index, url) in selectedURLs.enumerated() {
                    let name = selectedURLs.count == 1 ? baseName : "\(baseName)_\(index + 1)"
                    let result = try await imageUseCase.prepareConvertedImageFile(
                        url: url,
                        targetFormat: targetFormat,
                        preferredName: name,
                        operation: mode.dashboardTitle
                    )
                    newResults.append(result)
                }
                selectedURLs.removeAll()
            case .gifToImages:
                for (index, url) in selectedURLs.enumerated() {
                    let name = selectedURLs.count == 1 ? baseName : "\(baseName)_gif_\(index + 1)"
                    let results = try await imageUseCase.prepareSplitGIF(url: url, preferredName: name)
                    newResults.append(contentsOf: results)
                }
                selectedURLs.removeAll()
            case .convertToGIF, .imagesToGif:
                let result = try await imageUseCase.prepareGIF(images: selectedImages, preferredName: baseName, operation: mode.dashboardTitle)
                newResults.append(result)
                selectedImages.removeAll()
            }

            processedResults = newResults
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }
}
