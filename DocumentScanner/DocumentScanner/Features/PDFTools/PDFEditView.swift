//
//  PDFEditView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Combine
import PDFKit
import SwiftUI
import UIKit

struct PDFEditView: View {
    @Environment(\.presentationMode) var presentationMode

    @StateObject private var signatureStore = SignatureStore()

    @State private var selectedUrl: URL? = nil
    @State private var previewImage: UIImage? = nil
    @State private var previewPageSize = CGSize(width: 612, height: 792)
    @State private var showDocumentPicker = false
    @State private var showImagePicker = false
    @State private var showSignatureCreator = false

    @State private var selectedElement: PDFEditElement = .signature
    @State private var textInput = ""
    @State private var selectedImage: UIImage? = nil
    @State private var selectedSignatureId: UUID? = nil
    @State private var overlayPosition = CGPoint(x: 0.76, y: 0.84)
    @State private var appliesToAllPages = false
    @State private var fontSize: Double = 38
    @State private var opacity: Double = 1.0
    @State private var pageNumberPosition: PDFPageNumberPosition = .bottomCenter
    @State private var pageNumberFormat: PDFPageNumberFormat = .numberOnly
    @State private var pageNumberStart: Double = 1
    @State private var fileName = ""

    @State private var isProcessing = false
    @State private var successFile: SavedFile? = nil
    @State private var errorMessage: String? = nil

    private let locksElement: Bool
    private let pdfUseCase = ProcessPDFUseCase()

    init(initialElement: PDFEditElement = .signature, locksElement: Bool = false) {
        self.locksElement = locksElement
        _selectedElement = State(initialValue: initialElement)
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedUrl == nil {
                Button(action: { showDocumentPicker = true }) {
                    VStack(spacing: 16) {
                        Image(systemName: Images.System.editPdf)
                            .font(.system(size: 48))
                            .foregroundColor(.appPrimary)

                        Text(locksElement ? "Select PDF" : "Select PDF to Edit")
                            .appFont(.appTitle3, weight: .bold, color: .appPrimary)

                        Text(locksElement ? "Add a signature to a PDF document." : "Add a signature, text, watermark, image, or page numbers to a PDF document.")
                            .appFont(.appBody, color: .appTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .cardStyle()
                    .padding()
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 22) {
                        fileInfo
                        if !locksElement {
                            editModePicker
                        }
                        editorPreview
                        editOptions
                        outputNameField
                        feedbackArea
                        actionArea
                    }
                    .padding(.top)
                }
            }
        }
        .navigationTitle(locksElement ? selectedElement.fullTitle : Strings.PDFTools.editTitle)
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
                get: { selectedImage },
                set: { image in
                    selectedImage = image
                    selectedSignatureId = nil
                    if selectedElement == .signature {
                        textInput = ""
                    }
                    resetResultState()
                }
            ))
        }
        .sheet(isPresented: $showSignatureCreator) {
            SignatureCreatorView { image in
                let signature = signatureStore.addSignature(image: image)
                selectedSignatureId = signature.id
                selectedImage = nil
                textInput = ""
                resetResultState()
            }
        }
        .onChange(of: selectedElement) { _ in
            resetElementState()
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

    private var editModePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Editing Tool")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            Picker("", selection: $selectedElement) {
                ForEach(PDFEditElement.allCases) { element in
                    Text(element.segmentTitle).tag(element)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal)
    }

    private var editorPreview: some View {
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

                        if shouldShowOverlay {
                            if selectedElement == .pageNumber {
                                draggableOverlay
                                    .opacity(opacity)
                                    .position(pageNumberPoint(in: imageFrame))
                            } else {
                                draggableOverlay
                                    .opacity(opacity)
                                    .position(
                                        x: imageFrame.minX + overlayPosition.x * imageFrame.width,
                                        y: imageFrame.minY + overlayPosition.y * imageFrame.height
                                    )
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                overlayPosition = normalizedPoint(for: value.location, in: imageFrame)
                                                resetResultState()
                                            }
                                    )
                            }
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

            Text(selectedElement == .pageNumber ? "Choose a position to set where numbers appear in the saved PDF." : "Drag the item on the page to set where it appears in the saved PDF.")
                .appFont(.appCaption, color: .appTextSecondary)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var draggableOverlay: some View {
        switch selectedElement {
        case .signature:
            if let image = activeSignatureImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: CGFloat(fontSize) * 4.6, height: CGFloat(fontSize) * 1.8)
                    .padding(6)
                    .background(Color.white.opacity(0.001))
            } else {
                Text(textInput)
                    .font(.custom("Snell Roundhand", size: CGFloat(fontSize)))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.001))
            }
        case .text:
            Text(textInput)
                .font(.system(size: CGFloat(fontSize), weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.001))
        case .watermark:
            Text(textInput)
                .font(.system(size: CGFloat(fontSize), weight: .bold))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .rotationEffect(.degrees(-45))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.001))
        case .image:
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: CGFloat(fontSize) * 4.5, height: CGFloat(fontSize) * 3.2)
                    .padding(6)
                    .background(Color.white.opacity(0.001))
            }
        case .pageNumber:
            Text(pageNumberPreviewText)
                .font(.system(size: CGFloat(fontSize), weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.001))
        }
    }

    private var editOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedElement.fullTitle)
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            modeSpecificInputs

            if selectedElement != .pageNumber {
                Toggle("Apply to all pages", isOn: $appliesToAllPages)
                    .appFont(.appCallout, weight: .semibold, color: .appTextPrimary)
            }

            sliderRow(
                title: selectedElement == .watermark ? "Watermark Size" : "Size",
                value: $fontSize,
                range: selectedElement == .watermark ? 32...96 : (selectedElement == .pageNumber ? 9...24 : 14...64),
                step: 1,
                suffix: "pt"
            )

            sliderRow(
                title: "Opacity",
                value: $opacity,
                range: selectedElement == .watermark ? 0.08...0.4 : 0.25...1.0,
                step: 0.01,
                suffix: "%"
            )
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var modeSpecificInputs: some View {
        switch selectedElement {
        case .signature:
            signatureControls
        case .text:
            labeledTextField(title: "Text", placeholder: "Text to add")
        case .watermark:
            labeledTextField(title: "Watermark Text", placeholder: "e.g. CONFIDENTIAL")
        case .image:
            VStack(alignment: .leading, spacing: 10) {
                imageSelectionButton(title: selectedImage == nil ? "Select Image" : "Change Image")
                selectedImagePreview
            }
        case .pageNumber:
            pageNumberControls
        }
    }

    private var pageNumberControls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("", selection: $pageNumberFormat) {
                Text("1, 2, 3").tag(PDFPageNumberFormat.numberOnly)
                Text("Page 1 of N").tag(PDFPageNumberFormat.pageOfTotal)
            }
            .pickerStyle(.segmented)
            .onChange(of: pageNumberFormat) { _ in resetResultState() }

            VStack(alignment: .leading, spacing: 8) {
                Text("Position")
                    .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(PDFPageNumberPosition.allCases) { position in
                        Button {
                            pageNumberPosition = position
                            overlayPosition = normalizedCenter(for: position)
                            resetResultState()
                        } label: {
                            Text(position.title)
                                .appFont(.appCaption, weight: .semibold, color: pageNumberPosition == position ? .white : .appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .background(pageNumberPosition == position ? Color.appPrimary : Color.appSecondaryBackground)
                                .cornerRadius(8)
                        }
                    }
                }
            }

            sliderRow(title: "Start At", value: $pageNumberStart, range: 1...999, step: 1, suffix: "")
        }
    }

    private var signatureControls: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Button(action: { showSignatureCreator = true }) {
                    labelButton(title: "Create Signature", iconName: "signature")
                }

                Button(action: { showImagePicker = true }) {
                    labelButton(title: selectedImage == nil ? "Import Image" : "Change Image", iconName: Images.System.photoLibrary)
                }
            }

            if !signatureStore.signatures.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Saved Signatures")
                        .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(signatureStore.signatures) { signature in
                                signatureChip(signature)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Typed Signature")
                    .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                TextField("e.g. Alex Morgan", text: $textInput)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.appCardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appSeparator, lineWidth: 1)
                    )
                    .onChange(of: textInput) { newValue in
                        if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            selectedSignatureId = nil
                            selectedImage = nil
                        }
                        resetResultState()
                    }
            }

            selectedImagePreview
        }
    }

    private func signatureChip(_ signature: StoredSignature) -> some View {
        let isSelected = selectedSignatureId == signature.id

        return Button {
            selectedSignatureId = signature.id
            selectedImage = nil
            textInput = ""
            resetResultState()
        } label: {
            VStack(spacing: 6) {
                if let image = signature.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 112, height: 48)
                }

                Text(signature.name)
                    .appFont(.appCaption, weight: .semibold, color: isSelected ? .white : .appTextPrimary)
                    .lineLimit(1)
            }
            .padding(8)
            .frame(width: 132, height: 82)
            .background(isSelected ? Color.appPrimary : Color.appSecondaryBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.appPrimary : Color.appSeparator, lineWidth: 1)
            )
        }
    }

    private var outputNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.PDFTools.enterFileName)
                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

            TextField("e.g. Edited_Document", text: $fileName)
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
        if let errorMsg = errorMessage {
            Text(errorMsg)
                .appFont(.appCallout, color: .appError)
                .padding(.horizontal)
        }

        if let success = successFile {
            VStack(spacing: 12) {
                Image(systemName: Images.System.success)
                    .font(.system(size: 32))
                    .foregroundColor(.appSuccess)

                Text("PDF Edited!")
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                Text("Saved as \(success.name).pdf in Files.")
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
                LoadingView(message: "Saving PDF edits...")
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: Strings.PDFTools.editBtn,
                    iconName: Images.System.editPdf,
                    isEnabled: isFormValid
                ) {
                    Task {
                        await saveEditedPDF()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private var selectedImagePreview: some View {
        Group {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color.appSecondaryBackground)
                    .cornerRadius(8)
            }
        }
    }

    private var activeSignatureImage: UIImage? {
        if let selectedSignatureId,
           let signature = signatureStore.signatures.first(where: { $0.id == selectedSignatureId }) {
            return signature.image
        }

        return selectedElement == .signature ? selectedImage : nil
    }

    private var overlayImage: UIImage? {
        switch selectedElement {
        case .signature:
            return activeSignatureImage
        case .image:
            return selectedImage
        case .text, .watermark:
            return nil
        case .pageNumber:
            return nil
        }
    }

    private var shouldShowOverlay: Bool {
        switch selectedElement {
        case .signature:
            return activeSignatureImage != nil || !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .text, .watermark:
            return !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .image:
            return selectedImage != nil
        case .pageNumber:
            return true
        }
    }

    private var isFormValid: Bool {
        guard selectedUrl != nil else { return false }

        switch selectedElement {
        case .signature:
            return activeSignatureImage != nil || !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .text, .watermark:
            return !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .image:
            return selectedImage != nil
        case .pageNumber:
            return true
        }
    }

    private func labeledTextField(title: String, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

            TextField(placeholder, text: $textInput)
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appSeparator, lineWidth: 1)
                )
                .onChange(of: textInput) { _ in
                    resetResultState()
                }
        }
    }

    private func imageSelectionButton(title: String) -> some View {
        Button(action: { showImagePicker = true }) {
            labelButton(title: title, iconName: Images.System.photoLibrary)
        }
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
            return "\(Int(value * 100))%"
        }
        if suffix.isEmpty {
            return "\(Int(value))"
        }
        return "\(Int(value))\(suffix)"
    }

    private var pageNumberPreviewText: String {
        let start = Int(pageNumberStart)
        switch pageNumberFormat {
        case .numberOnly:
            return "\(start)"
        case .pageOfTotal:
            return "Page \(start) of N"
        }
    }

    private func normalizedCenter(for position: PDFPageNumberPosition) -> CGPoint {
        switch position {
        case .bottomCenter:
            return CGPoint(x: 0.5, y: 0.94)
        case .bottomRight:
            return CGPoint(x: 0.82, y: 0.94)
        case .bottomLeft:
            return CGPoint(x: 0.18, y: 0.94)
        case .topCenter:
            return CGPoint(x: 0.5, y: 0.06)
        case .topRight:
            return CGPoint(x: 0.82, y: 0.06)
        case .topLeft:
            return CGPoint(x: 0.18, y: 0.06)
        }
    }

    private func pageNumberPoint(in imageFrame: CGRect) -> CGPoint {
        let scale = previewScale(in: imageFrame)
        let fontPointSize = max(CGFloat(fontSize) * scale, 8)
        let maxWidth = imageFrame.width * 0.42
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontPointSize, weight: .semibold)
        ]
        let measuredSize = (pageNumberPreviewText as NSString).boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).integral.size
        let size = CGSize(
            width: min(max(measuredSize.width + (16 * scale), 48 * scale), maxWidth),
            height: measuredSize.height + (8 * scale)
        )
        let margin = max(CGFloat(fontSize) * scale * 1.2, 24 * scale)
        let origin: CGPoint

        switch pageNumberPosition {
        case .bottomCenter:
            origin = CGPoint(x: (imageFrame.width - size.width) / 2, y: imageFrame.height - margin - size.height)
        case .bottomRight:
            origin = CGPoint(x: imageFrame.width - margin - size.width, y: imageFrame.height - margin - size.height)
        case .bottomLeft:
            origin = CGPoint(x: margin, y: imageFrame.height - margin - size.height)
        case .topCenter:
            origin = CGPoint(x: (imageFrame.width - size.width) / 2, y: margin)
        case .topRight:
            origin = CGPoint(x: imageFrame.width - margin - size.width, y: margin)
        case .topLeft:
            origin = CGPoint(x: margin, y: margin)
        }

        return CGPoint(
            x: imageFrame.minX + origin.x + size.width / 2,
            y: imageFrame.minY + origin.y + size.height / 2
        )
    }

    private func previewScale(in imageFrame: CGRect) -> CGFloat {
        guard previewPageSize.width > 0 && previewPageSize.height > 0 else { return 1 }
        return min(imageFrame.width / previewPageSize.width, imageFrame.height / previewPageSize.height)
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

    private func normalizedPoint(for location: CGPoint, in frame: CGRect) -> CGPoint {
        guard frame.width > 0 && frame.height > 0 else { return overlayPosition }

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
            errorMessage = "Unlock this PDF before editing it."
            return
        }

        previewPageSize = page.bounds(for: .mediaBox).size
        previewImage = page.thumbnail(of: CGSize(width: 900, height: 1200), for: .mediaBox)
    }

    private func resetResultState() {
        successFile = nil
        errorMessage = nil
    }

    private func resetElementState() {
        textInput = ""
        selectedImage = nil
        selectedSignatureId = nil
        successFile = nil
        errorMessage = nil

        switch selectedElement {
        case .signature:
            overlayPosition = CGPoint(x: 0.76, y: 0.84)
            appliesToAllPages = false
            fontSize = 38
            opacity = 1.0
        case .text:
            overlayPosition = CGPoint(x: 0.25, y: 0.18)
            appliesToAllPages = false
            fontSize = 18
            opacity = 1.0
        case .watermark:
            overlayPosition = CGPoint(x: 0.5, y: 0.5)
            appliesToAllPages = true
            fontSize = 56
            opacity = 0.18
        case .image:
            overlayPosition = CGPoint(x: 0.26, y: 0.82)
            appliesToAllPages = false
            fontSize = 28
            opacity = 1.0
        case .pageNumber:
            pageNumberPosition = .bottomCenter
            pageNumberFormat = .numberOnly
            pageNumberStart = 1
            overlayPosition = normalizedCenter(for: .bottomCenter)
            appliesToAllPages = true
            fontSize = 12
            opacity = 0.8
        }
    }

    @MainActor
    private func saveEditedPDF() async {
        guard let url = selectedUrl else { return }

        isProcessing = true
        errorMessage = nil
        successFile = nil

        let trimmedText = textInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let preferredName = fileName.trimmingCharacters(in: .whitespaces).isEmpty ? selectedElement.defaultFileName : fileName

        if selectedElement == .pageNumber {
            let configuration = PDFPageNumberConfiguration(
                position: pageNumberPosition,
                format: pageNumberFormat,
                startingNumber: Int(pageNumberStart),
                fontSize: CGFloat(fontSize),
                opacity: CGFloat(opacity)
            )

            do {
                successFile = try await pdfUseCase.addPageNumbers(url: url, configuration: configuration, preferredName: preferredName)
                fileName = ""
                dismissAfterSuccessfulSave()
            } catch {
                errorMessage = error.localizedDescription
            }

            isProcessing = false
            return
        }

        let configuration = PDFEditConfiguration(
            element: selectedElement,
            text: trimmedText,
            image: overlayImage,
            normalizedCenter: overlayPosition,
            appliesToAllPages: appliesToAllPages,
            fontSize: CGFloat(fontSize),
            opacity: CGFloat(opacity)
        )

        do {
            successFile = try await pdfUseCase.editPDF(url: url, configuration: configuration, preferredName: preferredName)
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

struct AddSignatureView: View {
    var body: some View {
        PDFEditView(initialElement: .signature, locksElement: true)
    }
}

private struct StoredSignature: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let pngData: Data

    var image: UIImage? {
        UIImage(data: pngData)
    }
}

private final class SignatureStore: ObservableObject {
    @Published private(set) var signatures: [StoredSignature] = []

    private let storageKey = "document_scanner_saved_signatures"

    init() {
        load()
    }

    @discardableResult
    func addSignature(image: UIImage) -> StoredSignature {
        let name = "Signature \(signatures.count + 1)"
        let signature = StoredSignature(id: UUID(), name: name, pngData: image.pngData() ?? Data())
        signatures.insert(signature, at: 0)
        save()
        return signature
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([StoredSignature].self, from: data) else {
            signatures = []
            return
        }

        signatures = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(signatures) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

private struct SignatureCreatorView: View {
    @Environment(\.presentationMode) var presentationMode

    let onSave: (UIImage) -> Void

    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var canvasSize = CGSize(width: 600, height: 220)

    var body: some View {
        NavigationView {
            VStack(spacing: 18) {
                GeometryReader { proxy in
                    Canvas { context, _ in
                        for stroke in strokes {
                            draw(stroke: stroke, in: &context)
                        }
                        draw(stroke: currentStroke, in: &context)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appSeparator, lineWidth: 1)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                canvasSize = proxy.size
                                currentStroke.append(value.location)
                            }
                            .onEnded { _ in
                                if !currentStroke.isEmpty {
                                    strokes.append(currentStroke)
                                    currentStroke = []
                                }
                            }
                    )
                    .onAppear {
                        canvasSize = proxy.size
                    }
                }
                .frame(height: 220)
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button(action: clearSignature) {
                        labelButton(title: "Clear", iconName: "arrow.counterclockwise")
                    }

                    Button(action: saveSignature) {
                        labelButton(title: "Save Signature", iconName: Images.System.success)
                    }
                    .disabled(strokes.isEmpty && currentStroke.isEmpty)
                    .opacity((strokes.isEmpty && currentStroke.isEmpty) ? 0.5 : 1)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 20)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Create Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Strings.General.cancel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func draw(stroke: [CGPoint], in context: inout GraphicsContext) {
        guard stroke.count > 1 else { return }

        var path = Path()
        path.move(to: stroke[0])
        for point in stroke.dropFirst() {
            path.addLine(to: point)
        }
        context.stroke(path, with: .color(.black), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
    }

    private func clearSignature() {
        strokes = []
        currentStroke = []
    }

    private func saveSignature() {
        let image = renderSignatureImage()
        onSave(image)
        presentationMode.wrappedValue.dismiss()
    }

    private func renderSignatureImage() -> UIImage {
        let outputSize = CGSize(width: 900, height: 330)
        let sourceSize = canvasSize.width > 0 && canvasSize.height > 0 ? canvasSize : CGSize(width: 600, height: 220)
        let xScale = outputSize.width / sourceSize.width
        let yScale = outputSize.height / sourceSize.height

        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1

        return UIGraphicsImageRenderer(size: outputSize, format: format).image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: outputSize))

            UIColor.black.setStroke()
            let path = UIBezierPath()
            path.lineWidth = 8
            path.lineCapStyle = .round
            path.lineJoinStyle = .round

            for stroke in strokes {
                guard let first = stroke.first else { continue }
                path.move(to: CGPoint(x: first.x * xScale, y: first.y * yScale))
                for point in stroke.dropFirst() {
                    path.addLine(to: CGPoint(x: point.x * xScale, y: point.y * yScale))
                }
            }

            path.stroke()
        }
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
}

private extension PDFEditElement {
    var segmentTitle: String {
        switch self {
        case .signature:
            return "Sign"
        case .text:
            return "Text"
        case .watermark:
            return "Mark"
        case .image:
            return "Image"
        case .pageNumber:
            return "Pages"
        }
    }

    var fullTitle: String {
        switch self {
        case .signature:
            return Strings.PDFTools.addSignature
        case .text:
            return Strings.PDFTools.addText
        case .watermark:
            return Strings.PDFTools.addWatermark
        case .image:
            return Strings.PDFTools.addImage
        case .pageNumber:
            return "Add Page Numbers"
        }
    }

    var defaultFileName: String {
        switch self {
        case .signature:
            return "signed_document"
        case .text:
            return "text_added_document"
        case .watermark:
            return "watermarked_document"
        case .image:
            return "image_added_document"
        case .pageNumber:
            return "numbered_document"
        }
    }
}

#Preview {
    NavigationView {
        PDFEditView()
    }
}
