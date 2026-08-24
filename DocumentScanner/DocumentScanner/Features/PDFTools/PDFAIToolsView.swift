//
//  PDFAIToolsView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
import UniformTypeIdentifiers

extension PDFAIToolMode {
    var title: String {
        switch self {
        case .summary:
            return Strings.PDFAI.summaryTitle
        case .keyPoints:
            return Strings.PDFAI.keyPointsTitle
        case .notes:
            return Strings.PDFAI.notesTitle
        case .questionAnswering:
            return Strings.PDFAI.questionAnsweringTitle
        }
    }

    var description: String {
        switch self {
        case .summary:
            return Strings.PDFAI.summaryDescription
        case .keyPoints:
            return Strings.PDFAI.keyPointsDescription
        case .notes:
            return Strings.PDFAI.notesDescription
        case .questionAnswering:
            return Strings.PDFAI.questionAnsweringDescription
        }
    }

    var iconName: String {
        switch self {
        case .summary:
            return Images.System.pdfSummary
        case .keyPoints:
            return Images.System.extractKeyPoints
        case .notes:
            return Images.System.generateNotes
        case .questionAnswering:
            return Images.System.questionAnswering
        }
    }

    var defaultFileName: String {
        switch self {
        case .summary:
            return "pdf_summary"
        case .keyPoints:
            return "pdf_key_points"
        case .notes:
            return "pdf_notes"
        case .questionAnswering:
            return "pdf_answer"
        }
    }

    var buttonTitle: String {
        switch self {
        case .summary:
            return Strings.PDFAI.summaryButton
        case .keyPoints:
            return Strings.PDFAI.keyPointsButton
        case .notes:
            return Strings.PDFAI.notesButton
        case .questionAnswering:
            return Strings.PDFAI.questionAnsweringButton
        }
    }
}

struct PDFSummaryView: View {
    var body: some View { PDFAIToolsView(mode: .summary) }
}

struct PDFKeyPointsView: View {
    var body: some View { PDFAIToolsView(mode: .keyPoints) }
}

struct PDFNotesView: View {
    var body: some View { PDFAIToolsView(mode: .notes) }
}

struct PDFQuestionAnsweringView: View {
    var body: some View { PDFAIToolsView(mode: .questionAnswering) }
}

struct PDFAIToolsView: View {
    @Environment(\.presentationMode) private var presentationMode

    private let mode: PDFAIToolMode
    private let useCase = PDFAIUseCase()

    @State private var selectedURLs: [URL] = []
    @State private var showDocumentPicker = false
    @State private var fileName = ""
    @State private var question = ""
    @State private var isProcessing = false
    @State private var outputText = ""
    @State private var successFile: SavedFile?
    @State private var errorMessage: String?

    init(mode: PDFAIToolMode) {
        self.mode = mode
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedURL == nil {
                emptyState
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 22) {
                        fileSummary
                        configurationArea
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
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            )
        }
    }

    private var emptyState: some View {
        Button(action: { showDocumentPicker = true }) {
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

    private var fileSummary: some View {
        HStack(spacing: 10) {
            Image(systemName: mode.iconName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.appPrimary)

            VStack(alignment: .leading, spacing: 3) {
                Text(selectedURL?.lastPathComponent ?? "")
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                    .lineLimit(1)
                Text(mode.description)
                    .appFont(.appCaption, color: .appTextSecondary)
                    .lineLimit(2)
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

    @ViewBuilder
    private var configurationArea: some View {
        if mode == .questionAnswering {
            VStack(alignment: .leading, spacing: 8) {
                Text(Strings.PDFAI.question)
                    .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                TextField(Strings.PDFAI.questionPlaceholder, text: $question, axis: .vertical)
                    .lineLimit(3...5)
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
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: Images.System.success)
                        .foregroundColor(.appSuccess)
                    Text("Saved \(successFile.name).\(successFile.fileType)")
                        .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                }

                if !outputText.isEmpty {
                    Text(outputText)
                        .appFont(.appCaption, color: .appTextSecondary)
                        .lineLimit(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                LoadingView(message: Strings.PDFAI.processing)
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: mode.buttonTitle,
                    iconName: mode.iconName,
                    isEnabled: canProcess
                ) {
                    Task { await processPDF() }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private var selectedURL: URL? {
        selectedURLs.first
    }

    private var canProcess: Bool {
        guard selectedURL != nil else { return false }
        if mode == .questionAnswering {
            return !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    @MainActor
    private func processPDF() async {
        guard let selectedURL else { return }

        isProcessing = true
        errorMessage = nil
        successFile = nil
        outputText = ""

        let baseName = fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? mode.defaultFileName : fileName

        do {
            let result = try await useCase.processPDF(
                url: selectedURL,
                mode: mode,
                question: question,
                preferredName: baseName
            )
            successFile = result.file
            outputText = result.text
            selectedURLs.removeAll()
            fileName = ""
            dismissAfterSuccessfulSave()
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    private func dismissAfterSuccessfulSave() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_100_000_000)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
