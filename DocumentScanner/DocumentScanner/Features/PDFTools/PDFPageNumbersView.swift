//
//  PDFPageNumbersView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 16/06/26.
//

import PDFKit
import SwiftUI
import UIKit

struct PDFPageNumbersView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var selectedUrl: URL?
    @State private var previewImage: UIImage?
    @State private var previewPageSize = CGSize(width: 612, height: 792)
    @State private var showDocumentPicker = false
    @State private var selectedPosition: PDFPageNumberPosition = .bottomCenter
    @State private var selectedFormat: PDFPageNumberFormat = .numberOnly
    @State private var startingNumber = 1.0
    @State private var fontSize = 12.0
    @State private var opacity = 0.8
    @State private var fileName = ""
    @State private var isProcessing = false
    @State private var successFile: SavedFile?
    @State private var errorMessage: String?

    private let pdfUseCase = ProcessPDFUseCase()

    var body: some View {
        VStack(spacing: 0) {
            if selectedUrl == nil {
                emptyState
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 22) {
                        fileInfo
                        preview
                        pageNumberOptions
                        outputNameField
                        feedbackArea
                        actionArea
                    }
                    .padding(.top)
                }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Add Page Numbers")
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
    }

    private var emptyState: some View {
        Button(action: { showDocumentPicker = true }) {
            VStack(spacing: 16) {
                Image(systemName: Images.System.pageNumbers)
                    .font(.system(size: 48))
                    .foregroundColor(.appPrimary)

                Text("Select PDF")
                    .appFont(.appTitle3, weight: .bold, color: .appPrimary)

                Text("Add page numbers to every page of a PDF document.")
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

                        let frameSize = pageNumberFrameSize(in: imageFrame)
                        Text(previewText)
                            .font(.system(size: previewFontSize(in: imageFrame), weight: .semibold))
                            .foregroundColor(.black.opacity(opacity))
                            .frame(width: frameSize.width, height: frameSize.height)
                            .position(pageNumberPoint(in: imageFrame))
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
        }
        .padding(.horizontal)
    }

    private var pageNumberOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Page Number Settings")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            Picker("", selection: $selectedFormat) {
                Text("1, 2, 3").tag(PDFPageNumberFormat.numberOnly)
                Text("Page 1 of N").tag(PDFPageNumberFormat.pageOfTotal)
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedFormat) { _ in resetResultState() }

            VStack(alignment: .leading, spacing: 8) {
                Text("Position")
                    .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(PDFPageNumberPosition.allCases) { position in
                        Button {
                            selectedPosition = position
                            resetResultState()
                        } label: {
                            Text(position.title)
                                .appFont(.appCaption, weight: .semibold, color: selectedPosition == position ? .white : .appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .background(selectedPosition == position ? Color.appPrimary : Color.appSecondaryBackground)
                                .cornerRadius(8)
                        }
                    }
                }
            }

            sliderRow(title: "Start At", value: $startingNumber, range: 1...999, step: 1, suffix: "")
            sliderRow(title: "Size", value: $fontSize, range: 9...24, step: 1, suffix: "pt")
            sliderRow(title: "Opacity", value: $opacity, range: 0.25...1.0, step: 0.01, suffix: "%")
        }
        .padding(.horizontal)
    }

    private var outputNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.PDFTools.enterFileName)
                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

            TextField("e.g. numbered_document", text: $fileName)
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

                Text("Page Numbers Added!")
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
                LoadingView(message: "Adding page numbers...")
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: "Save Page Numbers",
                    iconName: Images.System.pageNumbers,
                    isEnabled: selectedUrl != nil
                ) {
                    Task { await savePageNumbers() }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private var previewText: String {
        let start = Int(startingNumber)
        switch selectedFormat {
        case .numberOnly:
            return "\(start)"
        case .pageOfTotal:
            return "Page \(start) of N"
        }
    }

    private func sliderRow(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, suffix: String) -> some View {
        let clampedValue = Binding<Double>(
            get: { min(max(value.wrappedValue, range.lowerBound), range.upperBound) },
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
                Text(displayValue(clampedValue.wrappedValue, suffix: suffix))
                    .appFont(.appCaption, weight: .semibold, color: .appTextSecondary)
            }

            Slider(value: clampedValue, in: range, step: step)
        }
    }

    private func displayValue(_ value: Double, suffix: String) -> String {
        if suffix == "%" {
            return "\(Int(value * 100))%"
        }

        if suffix == "pt" {
            return "\(Int(value))pt"
        }

        return "\(Int(value))"
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

    private func previewScale(in imageFrame: CGRect) -> CGFloat {
        guard previewPageSize.width > 0 && previewPageSize.height > 0 else { return 1 }
        return min(imageFrame.width / previewPageSize.width, imageFrame.height / previewPageSize.height)
    }

    private func previewFontSize(in imageFrame: CGRect) -> CGFloat {
        max(CGFloat(fontSize) * previewScale(in: imageFrame), 8)
    }

    private func pageNumberFrameSize(in imageFrame: CGRect) -> CGSize {
        let scale = previewScale(in: imageFrame)
        let fontSize = previewFontSize(in: imageFrame)
        let maxWidth = imageFrame.width * 0.42
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        ]
        let measuredSize = (previewText as NSString).boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).integral.size

        return CGSize(
            width: min(max(measuredSize.width + (16 * scale), 48 * scale), maxWidth),
            height: measuredSize.height + (8 * scale)
        )
    }

    private func pageNumberPoint(in imageFrame: CGRect) -> CGPoint {
        let scale = previewScale(in: imageFrame)
        let size = pageNumberFrameSize(in: imageFrame)
        let margin = max(CGFloat(fontSize) * scale * 1.2, 24 * scale)
        let xCenter = (imageFrame.width - size.width) / 2
        let yTop = margin
        let yBottom = imageFrame.height - margin - size.height
        let xLeft = margin
        let xRight = imageFrame.width - margin - size.width
        let origin: CGPoint

        switch selectedPosition {
        case .bottomCenter:
            origin = CGPoint(x: xCenter, y: yBottom)
        case .bottomRight:
            origin = CGPoint(x: xRight, y: yBottom)
        case .bottomLeft:
            origin = CGPoint(x: xLeft, y: yBottom)
        case .topCenter:
            origin = CGPoint(x: xCenter, y: yTop)
        case .topRight:
            origin = CGPoint(x: xRight, y: yTop)
        case .topLeft:
            origin = CGPoint(x: xLeft, y: yTop)
        }

        return CGPoint(
            x: imageFrame.minX + origin.x + size.width / 2,
            y: imageFrame.minY + origin.y + size.height / 2
        )
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
            errorMessage = "Unlock this PDF before adding page numbers."
            return
        }

        previewPageSize = page.bounds(for: .mediaBox).size
        previewImage = page.thumbnail(of: CGSize(width: 900, height: 1200), for: .mediaBox)
    }

    private func resetResultState() {
        successFile = nil
        errorMessage = nil
    }

    @MainActor
    private func savePageNumbers() async {
        guard let selectedUrl else { return }

        isProcessing = true
        errorMessage = nil
        successFile = nil

        let preferredName = fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "numbered_document" : fileName
        let configuration = PDFPageNumberConfiguration(
            position: selectedPosition,
            format: selectedFormat,
            startingNumber: Int(startingNumber),
            fontSize: CGFloat(fontSize),
            opacity: CGFloat(opacity)
        )

        do {
            successFile = try await pdfUseCase.addPageNumbers(
                url: selectedUrl,
                configuration: configuration,
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
        PDFPageNumbersView()
    }
}
