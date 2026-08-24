//
//  UtilityToolsView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

enum UtilityToolMode {
    case convertLivePhotos
    case extractVideoFrame

    var title: String {
        switch self {
        case .convertLivePhotos:
            return Strings.Utilities.convertLivePhotosTitle
        case .extractVideoFrame:
            return Strings.Utilities.extractFrameTitle
        }
    }

    var description: String {
        switch self {
        case .convertLivePhotos:
            return Strings.Utilities.convertLivePhotosDescription
        case .extractVideoFrame:
            return Strings.Utilities.extractFrameDescription
        }
    }

    var iconName: String {
        switch self {
        case .convertLivePhotos:
            return Images.System.convertLivePhotos
        case .extractVideoFrame:
            return Images.System.extractVideoFrame
        }
    }

    var defaultFileName: String {
        switch self {
        case .convertLivePhotos:
            return "live_photo"
        case .extractVideoFrame:
            return "video_frame"
        }
    }

    var buttonTitle: String {
        switch self {
        case .convertLivePhotos:
            return Strings.Utilities.convertLivePhotosButton
        case .extractVideoFrame:
            return Strings.Utilities.extractFrameButton
        }
    }
}

struct ConvertLivePhotosView: View {
    var body: some View {
        UtilityToolsView(mode: .convertLivePhotos)
    }
}

struct ExtractVideoFrameView: View {
    var body: some View {
        UtilityToolsView(mode: .extractVideoFrame)
    }
}

struct UtilityToolsView: View {
    @Environment(\.presentationMode) private var presentationMode

    private let mode: UtilityToolMode
    private let imageUseCase = ProcessImageUseCase()

    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideoURLs: [URL] = []
    @State private var showLivePhotoPicker = false
    @State private var showVideoPicker = false
    @State private var fileName = ""
    @State private var frameTimeText = "1.0"
    @State private var isProcessing = false
    @State private var successFiles: [SavedFile] = []
    @State private var errorMessage: String?

    init(mode: UtilityToolMode) {
        self.mode = mode
    }

    var body: some View {
        VStack(spacing: 0) {
            if hasNoSelection {
                emptyState
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 22) {
                        selectionSummary
                        if mode == .extractVideoFrame {
                            frameTimeField
                        }
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
        .sheet(isPresented: $showLivePhotoPicker) {
            LivePhotoStillPicker(selectedImages: $selectedImages)
        }
        .sheet(isPresented: $showVideoPicker) {
            VideoPicker(selectedURLs: $selectedVideoURLs)
        }
    }

    private var emptyState: some View {
        Button(action: showPicker) {
            VStack(spacing: 16) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 48))
                    .foregroundColor(.appPrimary)

                Text(mode.title)
                    .appFont(.appTitle3, weight: .bold, color: .appTextPrimary)

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

            if mode == .convertLivePhotos {
                imagePreviewStrip
            } else {
                videoList
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

    private var videoList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(selectedVideoURLs, id: \.self) { url in
                HStack(spacing: 8) {
                    Image(systemName: Images.System.extractVideoFrame)
                        .foregroundColor(.appPrimary)

                    Text(url.lastPathComponent)
                        .appFont(.appCaption, color: .appTextSecondary)
                        .lineLimit(1)

                    Spacer()

                    Button {
                        selectedVideoURLs.removeAll { $0 == url }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
        }
    }

    private var frameTimeField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.Utilities.frameTime)
                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

            TextField("1.0", text: $frameTimeText)
                .keyboardType(.decimalPad)
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

        if !successFiles.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: Images.System.success)
                        .foregroundColor(.appSuccess)

                    Text("Saved \(successFiles.count) File\(successFiles.count == 1 ? "" : "s")")
                        .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                }

                ForEach(successFiles) { file in
                    Text("• \(file.name).\(file.fileType)")
                        .appFont(.appCaption, color: .appTextSecondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
            .padding(.horizontal)
        }
    }

    private var actionArea: some View {
        Group {
            if isProcessing {
                LoadingView(message: Strings.Utilities.processing)
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: mode.buttonTitle,
                    iconName: mode.iconName,
                    isEnabled: canProcess
                ) {
                    Task { await processSelection() }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private var hasNoSelection: Bool {
        selectedImages.isEmpty && selectedVideoURLs.isEmpty
    }

    private var summaryTitle: String {
        switch mode {
        case .convertLivePhotos:
            return "Selected Live Photos (\(selectedImages.count))"
        case .extractVideoFrame:
            return "Selected Videos (\(selectedVideoURLs.count))"
        }
    }

    private var canProcess: Bool {
        switch mode {
        case .convertLivePhotos:
            return !selectedImages.isEmpty
        case .extractVideoFrame:
            return !selectedVideoURLs.isEmpty && frameTimeSeconds != nil
        }
    }

    private var frameTimeSeconds: Double? {
        Double(frameTimeText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func showPicker() {
        switch mode {
        case .convertLivePhotos:
            showLivePhotoPicker = true
        case .extractVideoFrame:
            showVideoPicker = true
        }
    }

    @MainActor
    private func processSelection() async {
        isProcessing = true
        errorMessage = nil
        successFiles.removeAll()

        let baseName = fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? mode.defaultFileName : fileName

        do {
            switch mode {
            case .convertLivePhotos:
                for (index, image) in selectedImages.enumerated() {
                    let name = selectedImages.count == 1 ? baseName : "\(baseName)_\(index + 1)"
                    let savedFile = try await imageUseCase.convertLivePhoto(image: image, preferredName: name)
                    successFiles.append(savedFile)
                }
                selectedImages.removeAll()
            case .extractVideoFrame:
                guard let seconds = frameTimeSeconds else {
                    throw NSError(domain: "UtilityToolsView", code: 400, userInfo: [NSLocalizedDescriptionKey: "Enter a valid frame time in seconds."])
                }

                for (index, url) in selectedVideoURLs.enumerated() {
                    let name = selectedVideoURLs.count == 1 ? baseName : "\(baseName)_\(index + 1)"
                    let savedFile = try await imageUseCase.extractFrameFromVideo(url: url, at: seconds, preferredName: name)
                    successFiles.append(savedFile)
                }
                selectedVideoURLs.removeAll()
            }

            fileName = ""
            dismissAfterSuccessfulSave()
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    private func dismissAfterSuccessfulSave() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
