//
//  PDFPageUtilityView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import PDFKit
import SwiftUI

enum PDFPageUtilityMode {
    case duplicate
    case crop
    case reverse
    case longImage

    var title: String {
        switch self {
        case .duplicate: return Strings.PDFTools.duplicatePagesTitle
        case .crop: return Strings.PDFTools.cropPDFTitle
        case .reverse: return Strings.PDFTools.reversePagesTitle
        case .longImage: return Strings.PDFTools.pdfToLongImageTitle
        }
    }

    var iconName: String {
        switch self {
        case .duplicate: return Images.System.duplicatePages
        case .crop: return Images.System.cropPdf
        case .reverse: return Images.System.reversePages
        case .longImage: return Images.System.pdfToLongImage
        }
    }

    var emptyTitle: String {
        switch self {
        case .duplicate: return "Select PDF to Duplicate Pages"
        case .crop: return "Select PDF to Crop"
        case .reverse: return "Select PDF to Reverse Pages"
        case .longImage: return "Select PDF to Convert"
        }
    }

    var emptyDescription: String {
        switch self {
        case .duplicate: return "Choose pages and duplicate them into a new PDF."
        case .crop: return "Crop page margins across the PDF and save a new file."
        case .reverse: return "Reverse the page order and save a new PDF."
        case .longImage: return "Render every PDF page into one continuous image."
        }
    }

    var instruction: String {
        switch self {
        case .duplicate: return "Select the pages to duplicate. Each duplicate is inserted after its original page."
        case .crop: return "Adjust margins. The crop applies to every page in the PDF."
        case .reverse: return "The saved PDF will use the opposite page order."
        case .longImage: return "All pages will be stacked vertically into one JPG image."
        }
    }

    var defaultFileName: String {
        switch self {
        case .duplicate: return "duplicated_pages_document"
        case .crop: return "cropped_document"
        case .reverse: return "reversed_pages_document"
        case .longImage: return "pdf_long_image"
        }
    }

    var saveButtonTitle: String {
        switch self {
        case .duplicate: return Strings.PDFTools.duplicatePagesBtn
        case .crop: return Strings.PDFTools.cropPDFBtn
        case .reverse: return Strings.PDFTools.reversePagesBtn
        case .longImage: return Strings.PDFTools.pdfToLongImageBtn
        }
    }

    var loadingMessage: String {
        switch self {
        case .duplicate: return "Duplicating pages..."
        case .crop: return "Cropping PDF..."
        case .reverse: return "Reversing pages..."
        case .longImage: return "Creating long image..."
        }
    }

    var successTitle: String {
        switch self {
        case .duplicate: return "Pages Duplicated!"
        case .crop: return "PDF Cropped!"
        case .reverse: return "Pages Reversed!"
        case .longImage: return "Long Image Created!"
        }
    }
}

struct PDFDuplicatePagesView: View {
    var body: some View { PDFPageUtilityView(mode: .duplicate) }
}

struct PDFCropView: View {
    var body: some View { PDFPageUtilityView(mode: .crop) }
}

struct PDFReversePagesView: View {
    var body: some View { PDFPageUtilityView(mode: .reverse) }
}

struct PDFToLongImageView: View {
    var body: some View { PDFPageUtilityView(mode: .longImage) }
}

struct PDFPageUtilityView: View {
    struct PageItem: Identifiable {
        let id = UUID()
        let index: Int
        let thumbnail: UIImage
    }

    @Environment(\.presentationMode) private var presentationMode

    private let mode: PDFPageUtilityMode
    private let columns = [
        GridItem(.adaptive(minimum: 96, maximum: 120), spacing: 12)
    ]

    @State private var selectedUrl: URL?
    @State private var pageItems: [PageItem] = []
    @State private var selectedPageIndices = IndexSet()
    @State private var showDocumentPicker = false
    @State private var fileName = ""
    @State private var cropTop: Double = 0.05
    @State private var cropBottom: Double = 0.05
    @State private var cropLeft: Double = 0.05
    @State private var cropRight: Double = 0.05
    @State private var isProcessing = false
    @State private var successFile: SavedFile?
    @State private var errorMessage: String?

    private let pdfUseCase = ProcessPDFUseCase()

    init(mode: PDFPageUtilityMode) {
        self.mode = mode
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedUrl == nil {
                emptyState
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 22) {
                        fileInfo
                        instructionText
                        selectionControls
                        cropControls
                        pagesArea
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
                        loadPDF(from: first)
                    }
                }
            ), allowsMultipleSelection: false)
        }
    }

    private var emptyState: some View {
        Button(action: { showDocumentPicker = true }) {
            VStack(spacing: 16) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 48))
                    .foregroundColor(.appPrimary)

                Text(mode.emptyTitle)
                    .appFont(.appTitle3, weight: .bold, color: .appPrimary)

                Text(mode.emptyDescription)
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
        HStack(spacing: 12) {
            Image(systemName: mode.iconName)
                .foregroundColor(.appPrimary)
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 4) {
                Text(selectedUrl?.lastPathComponent ?? "")
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                    .lineLimit(1)

                Text("\(pageItems.count) Pages")
                    .appFont(.appCaption, color: .appTextSecondary)
            }

            Spacer()

            Button("Change") {
                showDocumentPicker = true
            }
            .appFont(.appCallout, weight: .semibold, color: .appPrimary)
        }
        .cardStyle()
        .padding(.horizontal)
    }

    private var instructionText: some View {
        Text(mode.instruction)
            .appFont(.appCaption, color: .appTextSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }

    @ViewBuilder
    private var selectionControls: some View {
        if mode == .duplicate {
            HStack(spacing: 12) {
                Button("Select All") {
                    selectedPageIndices = IndexSet(pageItems.map(\.index))
                    resetResultState()
                }
                .appFont(.appFootnote, weight: .semibold, color: .appPrimary)

                Button("Deselect All") {
                    selectedPageIndices.removeAll()
                    resetResultState()
                }
                .appFont(.appFootnote, color: .appTextSecondary)

                Spacer()

                Text("\(selectedPageIndices.count) Selected")
                    .appFont(.appFootnote, weight: .bold, color: .appTextPrimary)
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var cropControls: some View {
        if mode == .crop {
            VStack(alignment: .leading, spacing: 14) {
                Text("Crop Margins")
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                CropSlider(title: "Top", value: $cropTop)
                CropSlider(title: "Bottom", value: $cropBottom)
                CropSlider(title: "Left", value: $cropLeft)
                CropSlider(title: "Right", value: $cropRight)

                Text("Current visible area: \(Int((1 - cropTop - cropBottom) * 100))% height x \(Int((1 - cropLeft - cropRight) * 100))% width")
                    .appFont(.appCaption, color: cropMargins.isValid ? .appTextSecondary : .appError)
            }
            .padding()
            .cardStyle()
            .padding(.horizontal)
            .onChange(of: cropTop) { _ in resetResultState() }
            .onChange(of: cropBottom) { _ in resetResultState() }
            .onChange(of: cropLeft) { _ in resetResultState() }
            .onChange(of: cropRight) { _ in resetResultState() }
        }
    }

    @ViewBuilder
    private var pagesArea: some View {
        if mode == .longImage {
            longImagePreview
        } else {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(pageItems) { item in
                    PDFUtilityPageCard(
                        item: item,
                        isSelected: selectedPageIndices.contains(item.index),
                        isSelectable: mode == .duplicate,
                        cropMargins: mode == .crop ? cropMargins : nil
                    ) {
                        guard mode == .duplicate else { return }
                        toggleSelection(for: item.index)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var longImagePreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Image Preview")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            HStack(alignment: .top, spacing: 8) {
                ForEach(pageItems.prefix(3)) { item in
                    Image(uiImage: item.thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 82)
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(6)
                }

                if pageItems.count > 3 {
                    Text("+\(pageItems.count - 3)")
                        .appFont(.appHeadline, weight: .bold, color: .appTextSecondary)
                        .frame(width: 54, height: 72)
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(6)
                }
            }

            Text("Pages will be stacked vertically in page order.")
                .appFont(.appCaption, color: .appTextSecondary)
        }
        .padding()
        .cardStyle()
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

        if let successFile {
            VStack(spacing: 12) {
                Image(systemName: Images.System.success)
                    .font(.system(size: 32))
                    .foregroundColor(.appSuccess)

                Text(mode.successTitle)
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                Text("Saved as \(successFile.name).\(successFile.fileType) in Files.")
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
                LoadingView(message: mode.loadingMessage)
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: mode.saveButtonTitle,
                    iconName: mode.iconName,
                    isEnabled: isActionEnabled
                ) {
                    Task { await saveOutput() }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private var cropMargins: PDFCropMargins {
        PDFCropMargins(
            top: CGFloat(cropTop),
            bottom: CGFloat(cropBottom),
            left: CGFloat(cropLeft),
            right: CGFloat(cropRight)
        )
    }

    private var isActionEnabled: Bool {
        guard selectedUrl != nil, !pageItems.isEmpty else { return false }

        switch mode {
        case .duplicate:
            return !selectedPageIndices.isEmpty
        case .crop:
            return cropMargins.isValid
        case .reverse:
            return pageItems.count > 1
        case .longImage:
            return true
        }
    }

    private func loadPDF(from url: URL) {
        selectedUrl = url
        selectedPageIndices.removeAll()
        pageItems.removeAll()
        resetResultState()

        guard let document = PDFDocument(url: url) else {
            errorMessage = "Failed to load the selected PDF."
            return
        }

        guard !document.isLocked else {
            errorMessage = "Unlock this PDF before using this tool."
            return
        }

        pageItems = (0..<document.pageCount).compactMap { index in
            guard let page = document.page(at: index) else { return nil }
            return PageItem(
                index: index,
                thumbnail: page.thumbnail(of: CGSize(width: 180, height: 240), for: .cropBox)
            )
        }

        fileName = mode.defaultFileName
    }

    private func toggleSelection(for pageIndex: Int) {
        if selectedPageIndices.contains(pageIndex) {
            selectedPageIndices.remove(pageIndex)
        } else {
            selectedPageIndices.insert(pageIndex)
        }
        resetResultState()
    }

    private func resetResultState() {
        successFile = nil
        errorMessage = nil
    }

    @MainActor
    private func saveOutput() async {
        guard let url = selectedUrl else { return }

        isProcessing = true
        errorMessage = nil
        successFile = nil

        let preferredName = fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? mode.defaultFileName : fileName

        do {
            switch mode {
            case .duplicate:
                successFile = try await pdfUseCase.duplicatePDFPages(url: url, pageIndices: selectedPageIndices, preferredName: preferredName)
            case .crop:
                successFile = try await pdfUseCase.cropPDF(url: url, margins: cropMargins, preferredName: preferredName)
            case .reverse:
                successFile = try await pdfUseCase.reversePDFPages(url: url, preferredName: preferredName)
            case .longImage:
                successFile = try await pdfUseCase.convertPDFToLongImage(url: url, preferredName: preferredName)
            }

            fileName = ""
            selectedPageIndices.removeAll()
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

private struct CropSlider: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .appFont(.appFootnote, weight: .semibold, color: .appTextPrimary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .appFont(.appFootnote, weight: .bold, color: .appTextSecondary)
            }

            Slider(value: $value, in: 0...0.4, step: 0.01)
        }
    }
}

private struct PDFUtilityPageCard: View {
    let item: PDFPageUtilityView.PageItem
    let isSelected: Bool
    let isSelectable: Bool
    let cropMargins: PDFCropMargins?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: item.thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(8)
                        .overlay(cropOverlay)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.appPrimary : Color.appSeparator, lineWidth: isSelected ? 2 : 1)
                        )

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.appPrimary)
                            .background(Circle().fill(Color.white))
                            .padding(6)
                    }
                }

                Text("Page \(item.index + 1)")
                    .appFont(.appCaption, weight: .semibold, color: .appTextPrimary)
                    .lineLimit(1)
            }
            .padding(8)
            .background(Color.appCardBackground)
            .cornerRadius(8)
        }
        .disabled(!isSelectable)
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var cropOverlay: some View {
        if let cropMargins {
            GeometryReader { proxy in
                let rect = CGRect(
                    x: proxy.size.width * cropMargins.left,
                    y: proxy.size.height * cropMargins.top,
                    width: proxy.size.width * (1 - cropMargins.left - cropMargins.right),
                    height: proxy.size.height * (1 - cropMargins.top - cropMargins.bottom)
                )

                ZStack(alignment: .topLeading) {
                    Color.black.opacity(0.18)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                        .blendMode(.destinationOut)
                    Rectangle()
                        .stroke(Color.appPrimary, lineWidth: 2)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                }
                .compositingGroup()
            }
        }
    }
}
