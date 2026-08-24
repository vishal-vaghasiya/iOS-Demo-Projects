//
//  WatermarkToolsView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 16/06/26.
//

import PDFKit
import SwiftUI
import UIKit

enum WatermarkToolMode {
    case text
    case logo

    var title: String {
        switch self {
        case .text:
            return Strings.WatermarkTools.textTitle
        case .logo:
            return Strings.WatermarkTools.logoTitle
        }
    }

    var description: String {
        switch self {
        case .text:
            return Strings.WatermarkTools.textDescription
        case .logo:
            return Strings.WatermarkTools.logoDescription
        }
    }

    var iconName: String {
        switch self {
        case .text:
            return Images.System.textWatermark
        case .logo:
            return Images.System.logoWatermark
        }
    }

    var saveButtonTitle: String {
        switch self {
        case .text:
            return Strings.WatermarkTools.saveTextButton
        case .logo:
            return Strings.WatermarkTools.saveLogoButton
        }
    }

    var defaultFileName: String {
        switch self {
        case .text:
            return "text_watermarked_document"
        case .logo:
            return "logo_watermarked_document"
        }
    }

    var defaultSize: Double {
        switch self {
        case .text:
            return 56
        case .logo:
            return 42
        }
    }

    var sizeRange: ClosedRange<Double> {
        switch self {
        case .text:
            return 32...96
        case .logo:
            return 18...60
        }
    }

    var defaultOpacity: Double {
        switch self {
        case .text:
            return 0.18
        case .logo:
            return 0.28
        }
    }

    var watermarkKind: PDFWatermarkKind {
        switch self {
        case .text:
            return .text
        case .logo:
            return .logo
        }
    }
}

struct AddTextWatermarkView: View {
    var body: some View {
        WatermarkToolsView(mode: .text)
    }
}

struct AddLogoWatermarkView: View {
    var body: some View {
        WatermarkToolsView(mode: .logo)
    }
}

struct WatermarkToolsView: View {
    @Environment(\.presentationMode) private var presentationMode

    private let mode: WatermarkToolMode
    private let pdfUseCase = ProcessPDFUseCase()

    @State private var selectedUrl: URL?
    @State private var previewImage: UIImage?
    @State private var previewPageSize = CGSize(width: 612, height: 792)
    @State private var showDocumentPicker = false
    @State private var showImagePicker = false
    @State private var watermarkText = ""
    @State private var logoImage: UIImage?
    @State private var watermarkPosition = CGPoint(x: 0.5, y: 0.5)
    @State private var appliesToAllPages = true
    @State private var watermarkSize: Double
    @State private var opacity: Double
    @State private var fileName = ""
    @State private var isProcessing = false
    @State private var successFile: SavedFile?
    @State private var errorMessage: String?

    init(mode: WatermarkToolMode) {
        self.mode = mode
        _watermarkSize = State(initialValue: mode.defaultSize)
        _opacity = State(initialValue: mode.defaultOpacity)
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedUrl == nil {
                selectPDFState
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 22) {
                        fileInfo
                        preview
                        watermarkOptions
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
            DocumentPicker(selectedUrls: Binding(
                get: { [] },
                set: { urls in
                    if let first = urls.first {
                        selectedUrl = first
                        loadPDFPreview(from: first)
                        resetResultState()
                    }
                }
            ), allowsMultipleSelection: false)
        }
        .sheet(isPresented: $showImagePicker) {
            SingleImagePicker(selectedImage: Binding(
                get: { logoImage },
                set: { image in
                    logoImage = image
                    resetResultState()
                }
            ))
        }
        .onChange(of: watermarkText) { _ in
            resetResultState()
        }
    }

    private var selectPDFState: some View {
        Button(action: { showDocumentPicker = true }) {
            VStack(spacing: 16) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 48))
                    .foregroundColor(.appPrimary)

                Text(Strings.WatermarkTools.selectPDF)
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

    private var fileInfo: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .foregroundColor(.appError)
                .font(.system(size: 28))

            Text(selectedUrl?.lastPathComponent ?? "")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                .lineLimit(1)

            Spacer()

            Button("Change") {
                showDocumentPicker = true
            }
            .appFont(.appCallout, weight: .semibold, color: .appPrimary)
        }
        .cardStyle()
        .padding(.horizontal)
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preview")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            GeometryReader { proxy in
                let imageFrame = aspectFitFrame(
                    imageSize: previewImage?.size ?? CGSize(width: 612, height: 792),
                    containerSize: proxy.size
                )

                ZStack(alignment: .topLeading) {
                    Color.appSecondaryBackground

                    if let previewImage {
                        Image(uiImage: previewImage)
                            .resizable()
                            .frame(width: imageFrame.width, height: imageFrame.height)
                            .position(x: imageFrame.midX, y: imageFrame.midY)
                            .shadow(color: Color.appTextPrimary.opacity(0.12), radius: 8, x: 0, y: 4)

                        if shouldShowWatermark {
                            watermarkOverlay(in: imageFrame)
                                .opacity(opacity)
                                .position(
                                    x: imageFrame.minX + watermarkPosition.x * imageFrame.width,
                                    y: imageFrame.minY + watermarkPosition.y * imageFrame.height
                                )
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            watermarkPosition = normalizedPoint(for: value.location, in: imageFrame)
                                            resetResultState()
                                        }
                                )
                        }
                    } else {
                        LoadingView(message: "Loading preview...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appSeparator, lineWidth: 1)
                )
            }
            .frame(height: 420)

            Text("Drag the watermark on the page to set where it appears in the saved PDF.")
                .appFont(.appCaption, color: .appTextSecondary)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func watermarkOverlay(in imageFrame: CGRect) -> some View {
        switch mode {
        case .text:
            Text(watermarkText)
                .font(.system(size: scaledWatermarkSize(in: imageFrame), weight: .bold))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .rotationEffect(.degrees(-45))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.001))
        case .logo:
            if let logoImage {
                let logoSize = scaledLogoSize(for: logoImage, in: imageFrame)
                Image(uiImage: logoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: logoSize.width, height: logoSize.height)
                    .background(Color.white.opacity(0.001))
            }
        }
    }

    private var watermarkOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(mode.title)
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            modeSpecificInputs

            Toggle(Strings.WatermarkTools.applyToAllPages, isOn: $appliesToAllPages)
                .appFont(.appCallout, weight: .semibold, color: .appTextPrimary)
                .onChange(of: appliesToAllPages) { _ in
                    resetResultState()
                }

            sliderRow(
                title: Strings.WatermarkTools.size,
                value: $watermarkSize,
                range: mode.sizeRange,
                step: 1,
                suffix: mode == .text ? "pt" : "%"
            )

            sliderRow(
                title: Strings.WatermarkTools.opacity,
                value: $opacity,
                range: 0.08...0.6,
                step: 0.01,
                suffix: "%"
            )
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var modeSpecificInputs: some View {
        switch mode {
        case .text:
            VStack(alignment: .leading, spacing: 8) {
                Text(Strings.WatermarkTools.watermarkText)
                    .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                TextField("e.g. CONFIDENTIAL", text: $watermarkText)
                    .padding()
                    .background(Color.appCardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appSeparator, lineWidth: 1)
                    )
            }
        case .logo:
            VStack(alignment: .leading, spacing: 10) {
                Text(Strings.WatermarkTools.logoImage)
                    .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                Button(action: { showImagePicker = true }) {
                    labelButton(
                        title: logoImage == nil ? Strings.WatermarkTools.chooseLogo : Strings.WatermarkTools.changeLogo,
                        iconName: Images.System.photoLibrary
                    )
                }

                if let logoImage {
                    Image(uiImage: logoImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 120)
                        .frame(maxWidth: .infinity)
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(8)
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

        if let successFile {
            VStack(spacing: 12) {
                Image(systemName: Images.System.success)
                    .font(.system(size: 32))
                    .foregroundColor(.appSuccess)

                Text(Strings.WatermarkTools.savedTitle)
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                Text("Saved as \(successFile.name).pdf in Files.")
                    .appFont(.appCaption, color: .appTextSecondary)
                    .multilineTextAlignment(.center)
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
                LoadingView(message: "Saving watermark...")
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: mode.saveButtonTitle,
                    iconName: mode.iconName,
                    isEnabled: isFormValid
                ) {
                    Task {
                        await saveWatermarkedPDF()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private var shouldShowWatermark: Bool {
        switch mode {
        case .text:
            return !watermarkText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .logo:
            return logoImage != nil
        }
    }

    private var isFormValid: Bool {
        guard selectedUrl != nil else { return false }
        return shouldShowWatermark
    }

    private func labelButton(title: String, iconName: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .appFont(.appCallout, weight: .semibold, color: .appPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.appSecondaryBackground)
        .cornerRadius(8)
    }

    private func sliderRow(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, suffix: String) -> some View {
        let clampedValue = Binding<Double>(
            get: {
                min(max(value.wrappedValue, range.lowerBound), range.upperBound)
            },
            set: { newValue in
                value.wrappedValue = min(max(newValue, range.lowerBound), range.upperBound)
                resetResultState()
            }
        )

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .appFont(.appCallout, weight: .bold, color: .appTextSecondary)
                Spacer()
                Text(displayValue(for: clampedValue.wrappedValue, suffix: suffix))
                    .appFont(.appCaption, weight: .semibold, color: .appTextSecondary)
            }

            Slider(value: clampedValue, in: range, step: step)
        }
    }

    private func displayValue(for value: Double, suffix: String) -> String {
        if suffix == "%" {
            let percentValue = value <= 1 ? value * 100 : value
            return "\(Int(percentValue))%"
        }

        return "\(Int(value))\(suffix)"
    }

    private func aspectFitFrame(imageSize: CGSize, containerSize: CGSize) -> CGRect {
        guard imageSize.width > 0 && imageSize.height > 0 && containerSize.width > 0 && containerSize.height > 0 else {
            return .zero
        }

        let scale = min(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
        let width = imageSize.width * scale
        let height = imageSize.height * scale

        return CGRect(
            x: (containerSize.width - width) / 2,
            y: (containerSize.height - height) / 2,
            width: width,
            height: height
        )
    }

    private func scaledWatermarkSize(in imageFrame: CGRect) -> CGFloat {
        CGFloat(watermarkSize) * pagePreviewScale(in: imageFrame)
    }

    private func scaledLogoSize(for image: UIImage, in imageFrame: CGRect) -> CGSize {
        let imageSize = image.size
        guard imageSize.width > 0 && imageSize.height > 0 else { return .zero }

        let widthRatio = min(max(CGFloat(watermarkSize) / 100, 0.05), 0.9)
        let maxSize = CGSize(
            width: imageFrame.width * widthRatio,
            height: imageFrame.height * PDFWatermarkConfiguration.logoMaxHeightRatio
        )
        let scale = min(maxSize.width / imageSize.width, maxSize.height / imageSize.height)
        return CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }

    private func pagePreviewScale(in imageFrame: CGRect) -> CGFloat {
        guard previewPageSize.width > 0 && previewPageSize.height > 0 else { return 1 }
        return min(imageFrame.width / previewPageSize.width, imageFrame.height / previewPageSize.height)
    }

    private func normalizedPoint(for location: CGPoint, in frame: CGRect) -> CGPoint {
        guard frame.width > 0 && frame.height > 0 else { return watermarkPosition }

        let x = min(max((location.x - frame.minX) / frame.width, 0), 1)
        let y = min(max((location.y - frame.minY) / frame.height, 0), 1)
        return CGPoint(x: x, y: y)
    }

    private func loadPDFPreview(from url: URL) {
        guard let document = PDFDocument(url: url),
              let page = document.page(at: 0) else {
            previewImage = nil
            errorMessage = "Could not load PDF preview."
            return
        }

        if document.isLocked {
            previewImage = nil
            errorMessage = "Unlock this PDF before adding a watermark."
            return
        }

        let pageBounds = page.bounds(for: .mediaBox)
        previewPageSize = CGSize(width: max(pageBounds.width, 1), height: max(pageBounds.height, 1))
        previewImage = page.thumbnail(of: CGSize(width: 900, height: 1200), for: .mediaBox)
    }

    private func resetResultState() {
        successFile = nil
        errorMessage = nil
    }

    @MainActor
    private func saveWatermarkedPDF() async {
        guard let url = selectedUrl else { return }

        isProcessing = true
        errorMessage = nil
        successFile = nil

        let trimmedText = watermarkText.trimmingCharacters(in: .whitespacesAndNewlines)
        let preferredName = fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? mode.defaultFileName : fileName
        let configuration = PDFWatermarkConfiguration(
            kind: mode.watermarkKind,
            text: trimmedText,
            image: logoImage,
            normalizedCenter: watermarkPosition,
            appliesToAllPages: appliesToAllPages,
            size: CGFloat(watermarkSize),
            opacity: CGFloat(opacity)
        )

        do {
            successFile = try await pdfUseCase.addWatermark(url: url, configuration: configuration, preferredName: preferredName)
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

#Preview {
    NavigationView {
        AddTextWatermarkView()
    }
}
