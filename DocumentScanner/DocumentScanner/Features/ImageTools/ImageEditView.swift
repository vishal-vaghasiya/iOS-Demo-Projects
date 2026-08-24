//
//  ImageEditView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct ImageEditView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedImage: UIImage?
    @State private var previewImage: UIImage?
    @State private var showImagePicker = false

    @State private var cropPreset: CropPreset = .original
    @State private var cropLeft = 0.0
    @State private var cropRight = 0.0
    @State private var cropTop = 0.0
    @State private var cropBottom = 0.0
    @State private var rotationDegrees = 0.0
    @State private var flipHorizontal = false
    @State private var flipVertical = false
    @State private var brightness = 0.0
    @State private var contrast = 1.0
    @State private var saturation = 1.0
    @State private var sharpness = 0.0
    @State private var outputFormat: ImageFormat = .jpeg
    @State private var fileName = ""

    @State private var isRenderingPreview = false
    @State private var isProcessing = false
    @State private var successFile: SavedFile?
    @State private var errorMessage: String?

    private let imageUseCase = ProcessImageUseCase()

    enum CropPreset: String, CaseIterable, Identifiable {
        case original = "Original"
        case square = "Square"
        case ratio4x3 = "4:3"
        case ratio16x9 = "16:9"
        case custom = "Custom"

        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedImage == nil {
                emptyState
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 22) {
                        previewCanvas
                        transformControls
                        cropControls
                        adjustmentControls
                        outputControls
                        feedbackArea
                        actionArea
                    }
                    .padding(.top)
                }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(Strings.ImageTools.editTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            SingleImagePicker(selectedImage: Binding(
                get: { selectedImage },
                set: { image in
                    if let image {
                        selectedImage = image
                        resetEdits()
                        renderPreview()
                    }
                }
            ))
        }
    }

    private var emptyState: some View {
        Button(action: { showImagePicker = true }) {
            VStack(spacing: 16) {
                Image(systemName: Images.System.editImage)
                    .font(.system(size: 48))
                    .foregroundColor(.appPrimary)

                Text("Select Image to Edit")
                    .appFont(.appTitle3, weight: .bold, color: .appPrimary)

                Text("Crop, rotate, flip, and tune color before saving a new image.")
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

    private var previewCanvas: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Preview")
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                Spacer()

                Button("Change") {
                    showImagePicker = true
                }
                .appFont(.appCallout, weight: .semibold, color: .appPrimary)
            }

            ZStack {
                Color.appSecondaryBackground

                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(10)
                }

                if isRenderingPreview {
                    Color.appBackground.opacity(0.45)
                    LoadingView(message: "Updating preview...")
                }
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.appSeparator, lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }

    private var transformControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transform")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                editButton(title: "Rotate Left", iconName: "rotate.left") {
                    rotationDegrees = normalizedDegrees(rotationDegrees - 90)
                    renderPreview()
                }

                editButton(title: "Rotate Right", iconName: Images.System.rotate) {
                    rotationDegrees = normalizedDegrees(rotationDegrees + 90)
                    renderPreview()
                }

                toggleButton(title: "Flip Horizontal", iconName: "arrow.left.and.right.righttriangle.left.righttriangle.right", isActive: flipHorizontal) {
                    flipHorizontal.toggle()
                    renderPreview()
                }

                toggleButton(title: "Flip Vertical", iconName: "arrow.up.and.down.righttriangle.up.righttriangle.down", isActive: flipVertical) {
                    flipVertical.toggle()
                    renderPreview()
                }
            }

            Button(action: resetAndRender) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text(Strings.ImageTools.reset)
                }
                .appFont(.appCallout, weight: .semibold, color: .appTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.appSecondaryBackground)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }

    private var cropControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Crop")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CropPreset.allCases) { preset in
                        Button {
                            cropPreset = preset
                            if preset != .custom {
                                cropLeft = 0
                                cropRight = 0
                                cropTop = 0
                                cropBottom = 0
                            }
                            renderPreview()
                        } label: {
                            Text(preset.rawValue)
                                .appFont(.appCaption, weight: .semibold, color: cropPreset == preset ? .white : .appTextPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(cropPreset == preset ? Color.appPrimary : Color.appSecondaryBackground)
                                .cornerRadius(8)
                        }
                    }
                }
            }

            if cropPreset == .custom {
                adjustmentSlider(title: "Left", value: $cropLeft, range: 0...0.45, step: 0.01, displayMultiplier: 100, suffix: "%")
                adjustmentSlider(title: "Right", value: $cropRight, range: 0...0.45, step: 0.01, displayMultiplier: 100, suffix: "%")
                adjustmentSlider(title: "Top", value: $cropTop, range: 0...0.45, step: 0.01, displayMultiplier: 100, suffix: "%")
                adjustmentSlider(title: "Bottom", value: $cropBottom, range: 0...0.45, step: 0.01, displayMultiplier: 100, suffix: "%")
            }
        }
        .padding(.horizontal)
    }

    private var adjustmentControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Adjust")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            adjustmentSlider(title: "Brightness", value: $brightness, range: -0.6...0.6, step: 0.01, displayMultiplier: 100, suffix: "")
            adjustmentSlider(title: "Contrast", value: $contrast, range: 0.5...1.8, step: 0.01, displayMultiplier: 100, suffix: "%")
            adjustmentSlider(title: "Saturation", value: $saturation, range: 0...2, step: 0.01, displayMultiplier: 100, suffix: "%")
            adjustmentSlider(title: "Sharpness", value: $sharpness, range: 0...1.2, step: 0.01, displayMultiplier: 100, suffix: "%")
        }
        .padding(.horizontal)
    }

    private var outputControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Output")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            Picker("", selection: $outputFormat) {
                Text("JPG").tag(ImageFormat.jpeg)
                Text("PNG").tag(ImageFormat.png)
                Text("HEIC").tag(ImageFormat.heic)
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 8) {
                Text(Strings.PDFTools.enterFileName)
                    .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                TextField("e.g. Edited_Photo", text: $fileName)
                    .padding()
                    .background(Color.appCardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appSeparator, lineWidth: 1)
                    )
            }
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

        if let successFile {
            VStack(spacing: 12) {
                Image(systemName: Images.System.success)
                    .font(.system(size: 32))
                    .foregroundColor(.appSuccess)

                Text("Edited Image Saved!")
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                Text("Saved as \(successFile.name).\(successFile.fileType) in Files.")
                    .appFont(.appCaption, color: .appTextSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .cardStyle()
            .padding(.horizontal)
        }
    }

    private var actionArea: some View {
        Group {
            if isProcessing {
                LoadingView(message: "Saving edits...")
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: "Save Edited Image",
                    iconName: Images.System.editImage,
                    isEnabled: selectedImage != nil
                ) {
                    Task { await saveEdits() }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private func editButton(title: String, iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .appFont(.appCallout, weight: .semibold, color: .appPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.appSecondaryBackground)
            .cornerRadius(8)
        }
    }

    private func toggleButton(title: String, iconName: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .appFont(.appCallout, weight: .semibold, color: isActive ? .white : .appPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isActive ? Color.appPrimary : Color.appSecondaryBackground)
            .cornerRadius(8)
        }
    }

    private func adjustmentSlider(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        displayMultiplier: Double,
        suffix: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .appFont(.appCallout, weight: .bold, color: .appTextSecondary)
                Spacer()
                Text(sliderText(value.wrappedValue, multiplier: displayMultiplier, suffix: suffix))
                    .appFont(.appCaption, weight: .semibold, color: .appTextSecondary)
            }

            Slider(
                value: Binding(
                    get: { value.wrappedValue },
                    set: { newValue in
                        value.wrappedValue = newValue
                        renderPreview()
                    }
                ),
                in: range,
                step: step
            )
        }
    }

    private func sliderText(_ value: Double, multiplier: Double, suffix: String) -> String {
        if suffix == "%" {
            return "\(Int(value * multiplier))%"
        }

        return "\(Int(value * multiplier))"
    }

    private var editConfiguration: ImageEditConfiguration {
        ImageEditConfiguration(
            cropRect: cropRect,
            rotationDegrees: rotationDegrees,
            flipHorizontal: flipHorizontal,
            flipVertical: flipVertical,
            brightness: CGFloat(brightness),
            contrast: CGFloat(contrast),
            saturation: CGFloat(saturation),
            sharpness: CGFloat(sharpness)
        )
    }

    private var cropRect: CGRect {
        guard let selectedImage else {
            return CGRect(x: 0, y: 0, width: 1, height: 1)
        }

        switch cropPreset {
        case .original:
            return CGRect(x: 0, y: 0, width: 1, height: 1)
        case .square:
            return centerCropRect(imageSize: selectedImage.size, aspect: 1)
        case .ratio4x3:
            return centerCropRect(imageSize: selectedImage.size, aspect: 4.0 / 3.0)
        case .ratio16x9:
            return centerCropRect(imageSize: selectedImage.size, aspect: 16.0 / 9.0)
        case .custom:
            let left = min(max(cropLeft, 0), 0.45)
            let right = min(max(cropRight, 0), 0.45)
            let top = min(max(cropTop, 0), 0.45)
            let bottom = min(max(cropBottom, 0), 0.45)
            return CGRect(
                x: left,
                y: top,
                width: max(1 - left - right, 0.05),
                height: max(1 - top - bottom, 0.05)
            )
        }
    }

    private func centerCropRect(imageSize: CGSize, aspect: CGFloat) -> CGRect {
        guard imageSize.width > 0 && imageSize.height > 0 else {
            return CGRect(x: 0, y: 0, width: 1, height: 1)
        }

        let sourceAspect = imageSize.width / imageSize.height
        let cropSize: CGSize

        if sourceAspect > aspect {
            let height = imageSize.height
            cropSize = CGSize(width: height * aspect, height: height)
        } else {
            let width = imageSize.width
            cropSize = CGSize(width: width, height: width / aspect)
        }

        return CGRect(
            x: (imageSize.width - cropSize.width) / 2 / imageSize.width,
            y: (imageSize.height - cropSize.height) / 2 / imageSize.height,
            width: cropSize.width / imageSize.width,
            height: cropSize.height / imageSize.height
        )
    }

    private func resetEdits() {
        cropPreset = .original
        cropLeft = 0
        cropRight = 0
        cropTop = 0
        cropBottom = 0
        rotationDegrees = 0
        flipHorizontal = false
        flipVertical = false
        brightness = 0
        contrast = 1
        saturation = 1
        sharpness = 0
        successFile = nil
        errorMessage = nil
    }

    private func resetAndRender() {
        resetEdits()
        renderPreview()
    }

    private func normalizedDegrees(_ degrees: Double) -> Double {
        let remainder = degrees.truncatingRemainder(dividingBy: 360)
        return remainder < 0 ? remainder + 360 : remainder
    }

    private func renderPreview() {
        guard let selectedImage else { return }

        successFile = nil
        errorMessage = nil
        isRenderingPreview = true

        let configuration = editConfiguration
        Task {
            do {
                let image = try await imageUseCase.previewEditedImage(image: selectedImage, configuration: configuration)
                await MainActor.run {
                    previewImage = image
                    isRenderingPreview = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isRenderingPreview = false
                }
            }
        }
    }

    @MainActor
    private func saveEdits() async {
        guard let selectedImage else { return }

        isProcessing = true
        errorMessage = nil
        successFile = nil

        let preferredName = fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "edited_image" : fileName

        do {
            successFile = try await imageUseCase.editImage(
                image: selectedImage,
                configuration: editConfiguration,
                format: outputFormat,
                preferredName: preferredName
            )
            fileName = ""
            try? await Task.sleep(nanoseconds: 800_000_000)
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }
}

#Preview {
    NavigationView {
        ImageEditView()
    }
}
