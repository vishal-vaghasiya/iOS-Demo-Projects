//
//  MetadataToolsView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
import UniformTypeIdentifiers

enum MetadataToolMode {
    case removeMetadata
    case privacyCleaner

    var cleaningMode: MetadataCleaningMode {
        switch self {
        case .removeMetadata:
            return .removeMetadata
        case .privacyCleaner:
            return .privacyCleaner
        }
    }

    var title: String {
        switch self {
        case .removeMetadata:
            return Strings.MetadataTools.removeTitle
        case .privacyCleaner:
            return Strings.MetadataTools.privacyTitle
        }
    }

    var description: String {
        switch self {
        case .removeMetadata:
            return Strings.MetadataTools.removeDescription
        case .privacyCleaner:
            return Strings.MetadataTools.privacyDescription
        }
    }

    var iconName: String {
        switch self {
        case .removeMetadata:
            return Images.System.removeMetadata
        case .privacyCleaner:
            return Images.System.privacyCleaner
        }
    }

    var defaultFileName: String {
        switch self {
        case .removeMetadata:
            return "metadata_removed"
        case .privacyCleaner:
            return "privacy_cleaned"
        }
    }

    var buttonTitle: String {
        switch self {
        case .removeMetadata:
            return Strings.MetadataTools.removeButton
        case .privacyCleaner:
            return Strings.MetadataTools.privacyButton
        }
    }
}

struct RemoveMetadataView: View {
    var body: some View {
        MetadataToolsView(mode: .removeMetadata)
    }
}

struct PrivacyCleanerView: View {
    var body: some View {
        MetadataToolsView(mode: .privacyCleaner)
    }
}

struct MetadataToolsView: View {
    @Environment(\.presentationMode) private var presentationMode

    private let mode: MetadataToolMode
    private let useCase = MetadataToolsUseCase()

    @State private var selectedURLs: [URL] = []
    @State private var fileName = ""
    @State private var showDocumentPicker = false
    @State private var isProcessing = false
    @State private var successFiles: [SavedFile] = []
    @State private var errorMessage: String?

    init(mode: MetadataToolMode) {
        self.mode = mode
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedURLs.isEmpty {
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
                allowedContentTypes: [.pdf, .image],
                allowsMultipleSelection: true
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

    private var selectionSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Selected Files (\(selectedURLs.count))")
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                Spacer()

                Button("Add More") {
                    showDocumentPicker = true
                }
                .appFont(.appCallout, weight: .semibold, color: .appPrimary)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(selectedURLs, id: \.self) { url in
                    HStack(spacing: 8) {
                        Image(systemName: fileIconName(for: url))
                            .foregroundColor(.appPrimary)

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
                LoadingView(message: Strings.MetadataTools.processing)
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: mode.buttonTitle,
                    iconName: mode.iconName,
                    isEnabled: !selectedURLs.isEmpty
                ) {
                    Task { await cleanFiles() }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    @MainActor
    private func cleanFiles() async {
        isProcessing = true
        errorMessage = nil
        successFiles.removeAll()

        let baseName = fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? mode.defaultFileName : fileName

        do {
            successFiles = try await useCase.cleanFiles(urls: selectedURLs, mode: mode.cleaningMode, preferredName: baseName)
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
            try? await Task.sleep(nanoseconds: 800_000_000)
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func fileIconName(for url: URL) -> String {
        url.pathExtension.lowercased() == "pdf" ? Images.System.docText : "photo"
    }
}
