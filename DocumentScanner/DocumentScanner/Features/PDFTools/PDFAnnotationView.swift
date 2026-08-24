//
//  PDFAnnotationView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import PDFKit
import SwiftUI
import UIKit

struct PDFAnnotationView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var selectedUrl: URL?
    @State private var document: PDFDocument?
    @State private var showDocumentPicker = false
    @State private var selectedTool: PDFAnnotationTool
    @State private var selectedColor: Color
    @State private var noteText = "Note"
    @State private var fileName = ""
    @State private var isProcessing = false
    @State private var hasUnsavedChanges = false
    @State private var successFile: SavedFile?
    @State private var errorMessage: String?
    @State private var statusMessage: String?

    private let pdfUseCase = ProcessPDFUseCase()
    private let initialTool: PDFAnnotationTool

    init(initialTool: PDFAnnotationTool = .highlight) {
        self.initialTool = initialTool
        _selectedTool = State(initialValue: initialTool)
        _selectedColor = State(initialValue: initialTool.defaultColor)
    }

    var body: some View {
        VStack(spacing: 0) {
            if document == nil {
                emptyState
            } else {
                VStack(spacing: 12) {
                    fileInfo
                    toolPicker
                    colorPicker

                    PDFAnnotationCanvas(
                        document: $document,
                        selectedTool: selectedTool,
                        annotationColor: UIColor(selectedColor),
                        noteText: noteText,
                        onChange: markChanged
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appSeparator, lineWidth: 1)
                    )
                    .padding(.horizontal)

                    optionsArea
                    feedbackArea
                    saveArea
                }
                .padding(.top, 10)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(initialTool.dashboardTitle)
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
        VStack {
            Button(action: { showDocumentPicker = true }) {
                VStack(spacing: 16) {
                    Image(systemName: Images.System.annotatePdf)
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(.appPrimary)

                    Text("Select PDF to Annotate")
                        .appFont(.appTitle3, weight: .bold, color: .appPrimary)

                    Text("Highlight, underline, strike through, draw, and add notes to PDF documents.")
                        .appFont(.appBody, color: .appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .cardStyle()
                .padding()
            }

            Spacer()
        }
    }

    private var fileInfo: some View {
        HStack(spacing: 12) {
            Image(systemName: Images.System.annotatePdf)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.appPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text(selectedUrl?.lastPathComponent ?? "")
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                    .lineLimit(1)

                Text(hasUnsavedChanges ? "Unsaved annotations" : "Ready to annotate")
                    .appFont(.appCaption, color: hasUnsavedChanges ? .appWarning : .appTextSecondary)
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

    private var toolPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PDFAnnotationTool.allCases) { tool in
                    Button {
                        selectedTool = tool
                        statusMessage = tool.instruction
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: tool.iconName)
                            Text(tool.title)
                        }
                        .appFont(.appCaption, weight: .semibold, color: selectedTool == tool ? .white : .appPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTool == tool ? Color.appPrimary : Color.appSecondaryBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTool == tool ? Color.appPrimary : Color.appSeparator, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var colorPicker: some View {
        HStack(spacing: 10) {
            Text("Color")
                .appFont(.appCallout, weight: .semibold, color: .appTextPrimary)

            ForEach(PDFAnnotationColor.allCases) { option in
                Button {
                    selectedColor = option.color
                } label: {
                    Circle()
                        .fill(option.color)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == option.color ? Color.appTextPrimary : Color.appSeparator, lineWidth: selectedColor == option.color ? 2 : 1)
                        )
                }
                .accessibilityLabel(option.name)
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var optionsArea: some View {
        VStack(spacing: 10) {
            if selectedTool.requiresTextSelection {
                SecondaryButton(title: "Apply to Selected Text", iconName: selectedTool.iconName) {
                    applySelectedTextAnnotation()
                }
                .padding(.horizontal)
            }

            if selectedTool == .note {
                TextField("Note text", text: $noteText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }

            Text(selectedTool.instruction)
                .appFont(.appCaption, color: .appTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            TextField("Annotated PDF name", text: $fileName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var feedbackArea: some View {
        if let errorMessage {
            Text(errorMessage)
                .appFont(.appCallout, color: .appError)
                .padding(.horizontal)
        }

        if let successFile {
            Text("\(successFile.name) saved.")
                .appFont(.appCallout, weight: .semibold, color: .appSuccess)
                .padding(.horizontal)
        } else if let statusMessage {
            Text(statusMessage)
                .appFont(.appCallout, color: .appTextSecondary)
                .padding(.horizontal)
        }
    }

    private var saveArea: some View {
        PrimaryButton(
            title: Strings.PDFTools.annotationBtn,
            iconName: "square.and.arrow.down",
            isEnabled: document != nil && hasUnsavedChanges,
            isLoading: isProcessing
        ) {
            Task { await saveAnnotatedPDF() }
        }
        .padding(.horizontal)
        .padding(.bottom, 14)
    }

    private func loadPDF(from url: URL) {
        guard let pdf = PDFDocument(url: url) else {
            errorMessage = "Could not open the selected PDF."
            return
        }

        guard !pdf.isLocked else {
            errorMessage = "Unlock this PDF before annotating it."
            return
        }

        selectedUrl = url
        document = pdf
        fileName = (url.lastPathComponent as NSString).deletingPathExtension + "_annotated"
        hasUnsavedChanges = false
        successFile = nil
        errorMessage = nil
        statusMessage = selectedTool.instruction
    }

    private func applySelectedTextAnnotation() {
        guard let canvas = PDFAnnotationCanvasStore.shared.currentView else { return }
        guard canvas.applyTextAnnotation(tool: selectedTool, color: UIColor(selectedColor)) else {
            statusMessage = "Select text in the PDF first, then apply the annotation."
            return
        }

        markChanged()
        statusMessage = "\(selectedTool.title) added."
    }

    private func markChanged() {
        hasUnsavedChanges = true
        successFile = nil
        errorMessage = nil
    }

    @MainActor
    private func saveAnnotatedPDF() async {
        guard let data = document?.dataRepresentation() else {
            errorMessage = "Could not prepare the annotated PDF."
            return
        }

        isProcessing = true
        errorMessage = nil
        successFile = nil

        let trimmedName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let preferredName = trimmedName.isEmpty ? "annotated_pdf" : trimmedName

        do {
            successFile = try await pdfUseCase.saveAnnotatedPDF(data: data, preferredName: preferredName)
            hasUnsavedChanges = false
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

enum PDFAnnotationTool: String, CaseIterable, Identifiable {
    case highlight
    case underline
    case strikeThrough
    case draw
    case note

    var id: String { rawValue }

    var title: String {
        switch self {
        case .highlight: return "Highlight"
        case .underline: return "Underline"
        case .strikeThrough: return "Strike-through"
        case .draw: return "Draw"
        case .note: return "Notes"
        }
    }

    var dashboardTitle: String {
        switch self {
        case .highlight: return Strings.Dashboard.highlightText
        case .underline: return Strings.Dashboard.underlineText
        case .strikeThrough: return Strings.Dashboard.strikeThroughText
        case .draw: return Strings.Dashboard.drawOnPDF
        case .note: return Strings.Dashboard.pdfNotes
        }
    }

    var defaultColor: Color {
        switch self {
        case .draw:
            return .black
        case .highlight, .underline, .strikeThrough, .note:
            return .yellow
        }
    }

    var iconName: String {
        switch self {
        case .highlight: return "highlighter"
        case .underline: return "underline"
        case .strikeThrough: return "strikethrough"
        case .draw: return "pencil.tip"
        case .note: return "note.text"
        }
    }

    var instruction: String {
        switch self {
        case .highlight:
            return "Select text in the PDF, then tap Apply to Selected Text."
        case .underline:
            return "Select text in the PDF, then tap Apply to Selected Text."
        case .strikeThrough:
            return "Select text in the PDF, then tap Apply to Selected Text."
        case .draw:
            return "Drag directly on the PDF page to draw."
        case .note:
            return "Enter note text, then tap the PDF page to place it."
        }
    }

    var requiresTextSelection: Bool {
        self == .highlight || self == .underline || self == .strikeThrough
    }

    var pdfSubtype: PDFAnnotationSubtype {
        switch self {
        case .highlight: return .highlight
        case .underline: return .underline
        case .strikeThrough: return .strikeOut
        case .draw: return .ink
        case .note: return .text
        }
    }
}

private enum PDFAnnotationColor: String, CaseIterable, Identifiable {
    case yellow
    case green
    case blue
    case pink
    case black

    var id: String { rawValue }
    var name: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .pink: return .pink
        case .black: return .black
        }
    }
}

private struct PDFAnnotationCanvas: UIViewRepresentable {
    @Binding var document: PDFDocument?
    let selectedTool: PDFAnnotationTool
    let annotationColor: UIColor
    let noteText: String
    let onChange: () -> Void

    func makeUIView(context: Context) -> AnnotatingPDFView {
        let pdfView = AnnotatingPDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor(Color.appSecondaryBackground)
        pdfView.onAnnotationChanged = onChange
        PDFAnnotationCanvasStore.shared.currentView = pdfView
        return pdfView
    }

    func updateUIView(_ uiView: AnnotatingPDFView, context: Context) {
        if uiView.document !== document {
            uiView.document = document
        }

        uiView.activeTool = selectedTool
        uiView.annotationColor = annotationColor
        uiView.noteText = noteText
    }
}

private final class PDFAnnotationCanvasStore {
    static let shared = PDFAnnotationCanvasStore()
    weak var currentView: AnnotatingPDFView?
}

private final class AnnotatingPDFView: PDFView {
    var activeTool: PDFAnnotationTool = .highlight {
        didSet { updateGestureState() }
    }

    var annotationColor: UIColor = .yellow
    var noteText = "Note"
    var onAnnotationChanged: (() -> Void)?

    private lazy var drawGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDraw(_:)))
    private lazy var noteGesture = UITapGestureRecognizer(target: self, action: #selector(handleNote(_:)))
    private var activeDrawPage: PDFPage?
    private var activeDrawPath: UIBezierPath?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureGestures()
    }

    func applyTextAnnotation(tool: PDFAnnotationTool, color: UIColor) -> Bool {
        guard tool.requiresTextSelection, let selection = currentSelection else { return false }

        let lineSelections = selection.selectionsByLine()
        let selections = lineSelections.isEmpty ? [selection] : lineSelections
        var didAnnotate = false

        for lineSelection in selections {
            for page in lineSelection.pages {
                let bounds = lineSelection.bounds(for: page).insetBy(dx: -1, dy: -1)
                guard !bounds.isEmpty else { continue }

                let annotation = PDFAnnotation(bounds: bounds, forType: tool.pdfSubtype, withProperties: nil)
                annotation.color = tool == .highlight ? color.withAlphaComponent(0.35) : color
                page.addAnnotation(annotation)
                didAnnotate = true
            }
        }

        clearSelection()
        if didAnnotate {
            onAnnotationChanged?()
        }

        return didAnnotate
    }

    private func configureGestures() {
        drawGesture.minimumNumberOfTouches = 1
        drawGesture.maximumNumberOfTouches = 1
        drawGesture.delegate = self
        drawGesture.cancelsTouchesInView = true
        addGestureRecognizer(drawGesture)

        noteGesture.delegate = self
        noteGesture.cancelsTouchesInView = false
        addGestureRecognizer(noteGesture)

        updateGestureState()
    }

    private func updateGestureState() {
        drawGesture.isEnabled = activeTool == .draw
        noteGesture.isEnabled = activeTool == .note
        scrollView?.isScrollEnabled = activeTool != .draw
    }

    @objc private func handleDraw(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)

        switch gesture.state {
        case .began:
            guard let page = page(for: location, nearest: true) else { return }
            activeDrawPage = page
            let pagePoint = convert(location, to: page)
            let path = UIBezierPath()
            path.move(to: pagePoint)
            activeDrawPath = path
        case .changed:
            guard let page = activeDrawPage, let path = activeDrawPath else { return }
            let pagePoint = convert(location, to: page)
            path.addLine(to: pagePoint)
        case .ended, .cancelled:
            finishDrawing()
        default:
            break
        }
    }

    @objc private func handleNote(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }

        let location = gesture.location(in: self)
        guard let page = page(for: location, nearest: true) else { return }

        let pagePoint = convert(location, to: page)
        let bounds = CGRect(x: pagePoint.x - 14, y: pagePoint.y - 14, width: 28, height: 28)
        let annotation = PDFAnnotation(bounds: bounds, forType: .text, withProperties: nil)
        annotation.contents = noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Note" : noteText
        annotation.color = annotationColor
        page.addAnnotation(annotation)
        onAnnotationChanged?()
    }

    private func finishDrawing() {
        defer {
            activeDrawPage = nil
            activeDrawPath = nil
        }

        guard let page = activeDrawPage, let path = activeDrawPath else { return }
        guard !path.isEmpty else { return }

        let annotation = PDFAnnotation(bounds: page.bounds(for: .mediaBox), forType: .ink, withProperties: nil)
        annotation.color = annotationColor
        let border = PDFBorder()
        border.lineWidth = 2.5
        annotation.border = border
        annotation.add(path)
        page.addAnnotation(annotation)
        onAnnotationChanged?()
    }

    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }

    private var scrollView: UIScrollView? {
        subviews.compactMap { $0 as? UIScrollView }.first
    }
}
