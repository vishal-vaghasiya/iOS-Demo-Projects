//
//  PDFOrganizationView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import PDFKit
import SwiftUI

enum PDFOrganizationMode {
    case extract
    case delete
    case rearrange
    case rotate

    var title: String {
        switch self {
        case .extract:
            return Strings.PDFTools.extractPagesTitle
        case .delete:
            return Strings.PDFTools.deletePagesTitle
        case .rearrange:
            return Strings.PDFTools.rearrangePagesTitle
        case .rotate:
            return Strings.PDFTools.rotatePagesTitle
        }
    }

    var iconName: String {
        switch self {
        case .extract:
            return Images.System.extractPages
        case .delete:
            return Images.System.deletePages
        case .rearrange:
            return Images.System.rearrangePages
        case .rotate:
            return Images.System.rotatePages
        }
    }

    var emptyTitle: String {
        switch self {
        case .extract:
            return "Select PDF to Extract Pages"
        case .delete:
            return "Select PDF to Delete Pages"
        case .rearrange:
            return "Select PDF to Rearrange Pages"
        case .rotate:
            return "Select PDF to Rotate Pages"
        }
    }

    var emptyDescription: String {
        switch self {
        case .extract:
            return "Choose a PDF and select the pages to save as a new file."
        case .delete:
            return "Choose a PDF and select the pages you want to remove."
        case .rearrange:
            return "Choose a PDF and drag pages into the order you need."
        case .rotate:
            return "Choose a PDF, select pages, then rotate them before saving."
        }
    }

    var instruction: String {
        switch self {
        case .extract:
            return "Select pages to extract into a new PDF."
        case .delete:
            return "Select pages to remove. At least one page must remain."
        case .rearrange:
            return "Drag pages up or down to change their final order."
        case .rotate:
            return "Select pages, tap Rotate Selected, then save the rotated PDF."
        }
    }

    var defaultFileName: String {
        switch self {
        case .extract:
            return "extracted_pages"
        case .delete:
            return "pages_deleted_document"
        case .rearrange:
            return "rearranged_document"
        case .rotate:
            return "rotated_pages_document"
        }
    }

    var successTitle: String {
        switch self {
        case .extract:
            return "Pages Extracted!"
        case .delete:
            return "Pages Deleted!"
        case .rearrange:
            return "Pages Rearranged!"
        case .rotate:
            return "Pages Rotated!"
        }
    }

    var loadingMessage: String {
        switch self {
        case .extract:
            return "Extracting pages..."
        case .delete:
            return "Deleting pages..."
        case .rearrange:
            return "Rearranging pages..."
        case .rotate:
            return "Rotating pages..."
        }
    }

    var saveButtonTitle: String {
        switch self {
        case .extract:
            return Strings.PDFTools.splitBtn
        case .delete:
            return Strings.PDFTools.deletePagesBtn
        case .rearrange:
            return Strings.PDFTools.rearrangePagesBtn
        case .rotate:
            return Strings.PDFTools.rotatePagesBtn
        }
    }
}

struct PDFExtractPagesView: View {
    var body: some View {
        PDFOrganizationView(mode: .extract)
    }
}

struct PDFDeletePagesView: View {
    var body: some View {
        PDFOrganizationView(mode: .delete)
    }
}

struct PDFRearrangePagesView: View {
    var body: some View {
        PDFOrganizationView(mode: .rearrange)
    }
}

struct PDFRotatePagesView: View {
    var body: some View {
        PDFOrganizationView(mode: .rotate)
    }
}

struct PDFOrganizationView: View {
    struct PageItem: Identifiable, Equatable {
        let id = UUID()
        let originalIndex: Int
        let thumbnail: UIImage
        var rotationDegrees = 0
    }

    @Environment(\.presentationMode) var presentationMode

    private let mode: PDFOrganizationMode
    private let columns = [
        GridItem(.adaptive(minimum: 96, maximum: 120), spacing: 12)
    ]

    @State private var selectedUrl: URL? = nil
    @State private var pageItems: [PageItem] = []
    @State private var selectedPageIndices = IndexSet()
    @State private var showDocumentPicker = false
    @State private var fileName = ""
    @State private var isProcessing = false
    @State private var successFile: SavedFile? = nil
    @State private var errorMessage: String? = nil

    private let pdfUseCase = ProcessPDFUseCase()

    init(mode: PDFOrganizationMode = .extract) {
        self.mode = mode
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedUrl == nil {
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
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 22) {
                        fileInfo
                        instructionText
                        modeControls
                        rotateAction
                        pagesArea
                        outputNameField
                        feedbackArea
                        actionArea
                    }
                    .padding(.top)
                }
            }
        }
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

    private var fileInfo: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .foregroundColor(.appError)
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
    private var modeControls: some View {
        if mode != .rearrange {
            HStack(spacing: 12) {
                Button("Select All") {
                    selectAllPages()
                }
                .appFont(.appFootnote, weight: .semibold, color: .appPrimary)

                Button("Deselect All") {
                    selectedPageIndices.removeAll()
                    resetResultState()
                }
                .appFont(.appFootnote, weight: .semibold, color: .appTextSecondary)

                Spacer()

                Text("\(selectedPageIndices.count) Selected")
                    .appFont(.appFootnote, weight: .bold, color: .appTextPrimary)
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var rotateAction: some View {
        if mode == .rotate {
            SecondaryButton(
                title: Strings.PDFTools.rotateSelectedPages,
                iconName: Images.System.rotatePages,
                isEnabled: !selectedPageIndices.isEmpty
            ) {
                rotateSelectedPages()
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var pagesArea: some View {
        if mode == .rearrange {
            List {
                ForEach(pageItems) { item in
                    HStack(spacing: 12) {
                        Image(uiImage: item.thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 56, height: 72)
                            .background(Color.appSecondaryBackground)
                            .cornerRadius(6)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Page \(item.originalIndex + 1)")
                                .appFont(.appCallout, weight: .bold, color: .appTextPrimary)

                            Text("Original page \(item.originalIndex + 1)")
                                .appFont(.appCaption, color: .appTextSecondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onMove(perform: movePages)
            }
            .environment(\.editMode, .constant(.active))
            .frame(height: min(CGFloat(max(pageItems.count, 1)) * 92, 520))
            .listStyle(.plain)
            .cornerRadius(8)
            .padding(.horizontal)
        } else {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(pageItems) { item in
                    PageSelectionCard(
                        item: item,
                        isSelected: selectedPageIndices.contains(item.originalIndex),
                        isRotateMode: mode == .rotate
                    ) {
                        toggleSelection(for: item.originalIndex)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var outputNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.PDFTools.enterFileName)
                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

            TextField("e.g. Organized_Document", text: $fileName)
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

                Text(mode.successTitle)
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
                LoadingView(message: mode.loadingMessage)
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: mode.saveButtonTitle,
                    iconName: mode.iconName,
                    isEnabled: isActionEnabled
                ) {
                    Task {
                        await saveOrganizedPDF()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private var isActionEnabled: Bool {
        guard selectedUrl != nil, !pageItems.isEmpty else { return false }

        switch mode {
        case .extract:
            return !selectedPageIndices.isEmpty
        case .delete:
            return !selectedPageIndices.isEmpty && selectedPageIndices.count < pageItems.count
        case .rearrange:
            return pageItems.map(\.originalIndex) != Array(0..<pageItems.count)
        case .rotate:
            return pageItems.contains { $0.rotationDegrees % 360 != 0 }
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
            errorMessage = "Unlock this PDF before organizing it."
            return
        }

        pageItems = (0..<document.pageCount).compactMap { index in
            guard let page = document.page(at: index) else { return nil }
            return PageItem(
                originalIndex: index,
                thumbnail: page.thumbnail(of: CGSize(width: 180, height: 240), for: .mediaBox)
            )
        }
    }

    private func toggleSelection(for pageIndex: Int) {
        if selectedPageIndices.contains(pageIndex) {
            selectedPageIndices.remove(pageIndex)
        } else {
            selectedPageIndices.insert(pageIndex)
        }
        resetResultState()
    }

    private func selectAllPages() {
        selectedPageIndices = IndexSet(pageItems.map(\.originalIndex))

        if mode == .delete, selectedPageIndices.count == pageItems.count {
            selectedPageIndices.remove(pageItems.last?.originalIndex ?? 0)
        }
        resetResultState()
    }

    private func rotateSelectedPages() {
        pageItems = pageItems.map { item in
            var updatedItem = item
            if selectedPageIndices.contains(item.originalIndex) {
                updatedItem.rotationDegrees = (item.rotationDegrees + 90) % 360
            }
            return updatedItem
        }
        resetResultState()
    }

    private func movePages(from source: IndexSet, to destination: Int) {
        pageItems.move(fromOffsets: source, toOffset: destination)
        resetResultState()
    }

    private func resetResultState() {
        successFile = nil
        errorMessage = nil
    }

    @MainActor
    private func saveOrganizedPDF() async {
        guard let url = selectedUrl else { return }

        isProcessing = true
        errorMessage = nil
        successFile = nil

        let preferredName = fileName.trimmingCharacters(in: .whitespaces).isEmpty ? mode.defaultFileName : fileName

        do {
            switch mode {
            case .extract:
                successFile = try await pdfUseCase.splitPDF(url: url, pageIndices: selectedPageIndices, preferredName: preferredName)
            case .delete:
                successFile = try await pdfUseCase.deletePDFPages(url: url, pageIndices: selectedPageIndices, preferredName: preferredName)
            case .rearrange:
                successFile = try await pdfUseCase.rearrangePDFPages(url: url, orderedPageIndices: pageItems.map(\.originalIndex), preferredName: preferredName)
            case .rotate:
                let pageRotations = Dictionary(uniqueKeysWithValues: pageItems.compactMap { item -> (Int, Int)? in
                    let degrees = item.rotationDegrees % 360
                    return degrees == 0 ? nil : (item.originalIndex, degrees)
                })
                successFile = try await pdfUseCase.rotatePDFPages(url: url, pageRotations: pageRotations, preferredName: preferredName)
                pageItems = pageItems.map { item in
                    var updatedItem = item
                    updatedItem.rotationDegrees = 0
                    return updatedItem
                }
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

private struct PageSelectionCard: View {
    let item: PDFOrganizationView.PageItem
    let isSelected: Bool
    let isRotateMode: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: item.thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .rotationEffect(.degrees(Double(item.rotationDegrees)))
                        .scaleEffect(item.rotationDegrees % 180 == 0 ? 1 : 0.72)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(borderColor, lineWidth: isSelected || isRotated ? 2 : 1)
                        )

                    if isSelected {
                        Image(systemName: isRotateMode ? "rotate.right.fill" : "checkmark.circle.fill")
                            .foregroundColor(.appPrimary)
                            .background(Color.white.clipShape(Circle()))
                            .padding(6)
                    } else if isRotated {
                        Image(systemName: "rotate.right.fill")
                            .foregroundColor(.appWarning)
                            .background(Color.white.clipShape(Circle()))
                            .padding(6)
                    }
                }

                Text(pageTitle)
                    .appFont(.appCaption, weight: .semibold, color: labelColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var isRotated: Bool {
        item.rotationDegrees % 360 != 0
    }

    private var borderColor: Color {
        if isSelected {
            return .appPrimary
        }
        return isRotated ? .appWarning : .appSeparator
    }

    private var labelColor: Color {
        if isSelected {
            return .appPrimary
        }
        return isRotated ? .appWarning : .appTextPrimary
    }

    private var pageTitle: String {
        guard isRotateMode, isRotated else {
            return "Page \(item.originalIndex + 1)"
        }
        return "Page \(item.originalIndex + 1)\n\(item.rotationDegrees) deg"
    }
}

#Preview {
    NavigationView {
        PDFRotatePagesView()
    }
}
