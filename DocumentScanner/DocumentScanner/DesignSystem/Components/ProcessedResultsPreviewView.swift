//
//  ProcessedResultsPreviewView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 16/06/26.
//

import QuickLook
import SwiftUI
internal import CoreData

struct ProcessedResultsPreviewView: View {
    let title: String
    let defaultFolderName: String
    let operationIcon: String
    let onDone: () -> Void

    @Binding var results: [ProcessedFileResult]

    @State private var previewURL: URL?
    @State private var shareURLs: SharePayload?
    @State private var savedFiles: [SavedFile] = []
    @State private var errorMessage: String?
    @State private var isSaving = false

    private let filesUseCase = ManageFilesUseCase()

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                resultList
                feedbackArea
                actionBar
            }
            .padding(.vertical)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $previewURL) { url in
            QuickLookPreview(url: url)
        }
        .sheet(item: $shareURLs) { payload in
            ShareSheet(activityItems: payload.urls.map { $0 as Any })
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: operationIcon)
                .font(.system(size: 40))
                .foregroundColor(.appPrimary)

            Text("Preview Output")
                .appFont(.appTitle3, weight: .bold, color: .appTextPrimary)

            Text(results.count == 1 ? "Review, share, save, or delete this file." : "Review, share, save, or delete these files. Saving will place them inside a folder.")
                .appFont(.appCallout, color: .appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
        .padding(.horizontal)
    }

    private var resultList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Generated Files (\(results.count))")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

            ForEach(results) { result in
                resultRow(result)
            }
        }
        .cardStyle()
        .padding(.horizontal)
    }

    private func resultRow(_ result: ProcessedFileResult) -> some View {
        HStack(spacing: 12) {
            Button {
                previewURL = result.url
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: iconName(for: result.fileType))
                        .font(.system(size: 22))
                        .foregroundColor(color(for: result.fileType))
                        .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(result.displayName)
                            .appFont(.appCallout, weight: .semibold, color: .appTextPrimary)
                            .lineLimit(1)
                        Text(ByteCountFormatter.string(fromByteCount: result.fileSize, countStyle: .file))
                            .appFont(.appCaption, color: .appTextSecondary)
                    }

                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Button {
                shareURLs = SharePayload(urls: [result.url])
            } label: {
                Image(systemName: Images.System.share)
                    .frame(width: 32, height: 32)
            }
            .foregroundColor(.appPrimary)

            Button(role: .destructive) {
                delete(result)
            } label: {
                Image(systemName: Images.System.delete)
                    .frame(width: 32, height: 32)
            }
            .foregroundColor(.appError)
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var feedbackArea: some View {
        if let errorMessage {
            Text(errorMessage)
                .appFont(.appCallout, color: .appError)
                .padding(.horizontal)
        }

        if !savedFiles.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("Saved \(savedFiles.count) File\(savedFiles.count == 1 ? "" : "s")", systemImage: Images.System.success)
                    .appFont(.appHeadline, weight: .bold, color: .appSuccess)

                if savedFiles.count > 1 {
                    Text("Folder: \(defaultFolderName)")
                        .appFont(.appCaption, color: .appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
            .padding(.horizontal)
        }
    }

    private var actionBar: some View {
        VStack(spacing: 12) {
            if isSaving {
                LoadingView(message: "Saving files...")
                    .frame(height: 90)
            } else {
                PrimaryButton(
                    title: savedFiles.isEmpty ? "Save to Files" : "Done",
                    iconName: savedFiles.isEmpty ? Images.System.save : Images.System.success,
                    isEnabled: !results.isEmpty
                ) {
                    if savedFiles.isEmpty {
                        saveResults()
                    } else {
                        onDone()
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        shareURLs = SharePayload(urls: results.map(\.url))
                    } label: {
                        labelButton(title: "Share", iconName: Images.System.share)
                    }
                    .disabled(results.isEmpty)

                    Button(role: .destructive) {
                        deleteAll()
                    } label: {
                        labelButton(title: "Delete", iconName: Images.System.delete)
                    }
                    .disabled(results.isEmpty)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
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

    private func saveResults() {
        isSaving = true
        errorMessage = nil

        do {
            savedFiles = try filesUseCase.saveProcessedResults(
                results,
                preferredFolderName: results.count > 1 ? defaultFolderName : nil
            )
            results = savedFiles.map { file in
                ProcessedFileResult(
                    url: TempFileManager.shared.getFileUrl(forRelativePath: file.path),
                    name: file.name,
                    fileType: file.fileType,
                    fileSize: file.fileSize,
                    sourceOperation: file.sourceOperation
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    private func delete(_ result: ProcessedFileResult) {
        if let savedFile = savedFile(for: result) {
            try? filesUseCase.deleteFile(file: savedFile)
            savedFiles.removeAll { $0.objectID == savedFile.objectID }
        } else {
            try? FileManager.default.removeItem(at: result.url)
        }
        results.removeAll { $0.id == result.id }
        if results.isEmpty {
            onDone()
        }
    }

    private func deleteAll() {
        if savedFiles.isEmpty {
            for result in results {
                try? FileManager.default.removeItem(at: result.url)
            }
        } else {
            for file in savedFiles {
                try? filesUseCase.deleteFile(file: file)
            }
            savedFiles.removeAll()
        }
        results.removeAll()
        onDone()
    }

    private func savedFile(for result: ProcessedFileResult) -> SavedFile? {
        savedFiles.first { file in
            TempFileManager.shared.getFileUrl(forRelativePath: file.path).standardizedFileURL == result.url.standardizedFileURL
        }
    }

    private func iconName(for fileType: String) -> String {
        switch fileType.lowercased() {
        case "pdf":
            return "doc.text.fill"
        case "png", "jpg", "jpeg", "heic", "webp", "gif":
            return "photo.fill"
        default:
            return "doc.fill"
        }
    }

    private func color(for fileType: String) -> Color {
        switch fileType.lowercased() {
        case "pdf":
            return .appError
        case "png", "jpg", "jpeg", "heic", "webp", "gif":
            return .appPrimary
        default:
            return .appTextSecondary
        }
    }
}

private struct SharePayload: Identifiable {
    let id = UUID()
    let urls: [URL]
}
