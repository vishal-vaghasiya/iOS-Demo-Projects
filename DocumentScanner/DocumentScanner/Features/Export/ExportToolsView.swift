//
//  ExportToolsView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
internal import Combine
internal import CoreData

struct ZIPExportView: View {
    @Environment(\.presentationMode) var presentationMode

    @StateObject private var viewModel = ExportToolsViewModel()
    @State private var zipToShare: URL? = nil

    var body: some View {
        ExportToolLayout(
            title: Strings.Export.zipTitle,
            iconName: Images.System.zipExport,
            description: "Package every saved document, image, and OCR text file into one ZIP archive.",
            files: viewModel.files,
            allowsFileSelection: true,
            selectedFileIDs: viewModel.selectedFileIDs,
            isProcessing: viewModel.isProcessing,
            statusMessage: viewModel.statusMessage,
            errorMessage: viewModel.errorMessage,
            actionTitle: Strings.Export.zipButton,
            actionIcon: Images.System.zipExport,
            action: {
                Task {
                    if let url = await viewModel.createZipExport() {
                        zipToShare = url
                    }
                }
            },
            selectAllAction: {
                viewModel.selectAllFiles()
            },
            clearSelectionAction: {
                viewModel.clearSelection()
            },
            toggleFileAction: { file in
                viewModel.toggleFileSelection(file)
            }
        )
        .onAppear { viewModel.loadFiles() }
        .sheet(item: $zipToShare) { url in
            ShareSheet(activityItems: [url])
        }
    }
}

struct CloudBackupView: View {
    @Environment(\.presentationMode) var presentationMode

    @StateObject private var viewModel = ExportToolsViewModel()

    var body: some View {
        ExportToolLayout(
            title: Strings.Export.cloudTitle,
            iconName: Images.System.cloudBackup,
            description: "Back up saved files and Core Data metadata to iCloud Drive for automatic restore after reinstall.",
            files: viewModel.files,
            allowsFileSelection: false,
            selectedFileIDs: [],
            isProcessing: viewModel.isProcessing,
            statusMessage: viewModel.statusMessage,
            errorMessage: viewModel.errorMessage,
            actionTitle: Strings.Export.cloudButton,
            actionIcon: Images.System.cloudBackup,
            action: {
                Task {
                    await viewModel.backupToiCloudDocuments()
                }
            },
            selectAllAction: {},
            clearSelectionAction: {},
            toggleFileAction: { _ in }
        )
        .onAppear { viewModel.loadFiles() }
    }
}

@MainActor
final class ExportToolsViewModel: ObservableObject {
    @Published var files: [SavedFile] = []
    @Published var selectedFileIDs = Set<UUID>()
    @Published var isProcessing = false
    @Published var statusMessage: String? = nil
    @Published var errorMessage: String? = nil

    private let filesUseCase = ManageFilesUseCase()
    private let exportService = ExportService.shared

    var descriptors: [ExportFileDescriptor] {
        files.map { file in
            let fileURL = TempFileManager.shared.getFileUrl(forRelativePath: file.path)
            return ExportFileDescriptor(
                id: file.id,
                name: file.name,
                fileName: file.path,
                fileType: file.fileType,
                fileSize: file.fileSize,
                createdAt: file.createdAt,
                sourceOperation: file.sourceOperation,
                isFavorite: file.isFavorite,
                fileURL: fileURL
            )
        }
    }

    var selectedDescriptors: [ExportFileDescriptor] {
        descriptors.filter { selectedFileIDs.contains($0.id) }
    }

    func loadFiles() {
        do {
            files = try filesUseCase.fetchAllFiles()
            selectedFileIDs = Set(files.map(\.id))
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectAllFiles() {
        selectedFileIDs = Set(files.map(\.id))
        errorMessage = nil
        statusMessage = nil
    }

    func clearSelection() {
        selectedFileIDs.removeAll()
        errorMessage = nil
        statusMessage = nil
    }

    func toggleFileSelection(_ file: SavedFile) {
        if selectedFileIDs.contains(file.id) {
            selectedFileIDs.remove(file.id)
        } else {
            selectedFileIDs.insert(file.id)
        }
        errorMessage = nil
        statusMessage = nil
    }

    func createZipExport() async -> URL? {
        guard !selectedFileIDs.isEmpty else {
            errorMessage = "Select at least one file to export."
            statusMessage = nil
            return nil
        }

        isProcessing = true
        errorMessage = nil
        statusMessage = nil

        do {
            let url = try await exportService.createZipArchive(files: selectedDescriptors)
            statusMessage = "ZIP export is ready to share."
            isProcessing = false
            return url
        } catch {
            errorMessage = error.localizedDescription
            isProcessing = false
            return nil
        }
    }

    func backupToiCloudDocuments() async {
        isProcessing = true
        errorMessage = nil
        statusMessage = nil

        do {
            let backedUpCount = try await CoreDataBackupService.shared.backupNow()
            statusMessage = "\(backedUpCount) files backed up for automatic restore."
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }
}

private struct ExportToolLayout: View {
    let title: String
    let iconName: String
    let description: String
    let files: [SavedFile]
    let allowsFileSelection: Bool
    let selectedFileIDs: Set<UUID>
    let isProcessing: Bool
    let statusMessage: String?
    let errorMessage: String?
    let actionTitle: String
    let actionIcon: String
    let action: () -> Void
    let selectAllAction: () -> Void
    let clearSelectionAction: () -> Void
    let toggleFileAction: (SavedFile) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                header
                fileSummary
                feedbackArea
                actionArea
            }
            .padding(.top)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(.appPrimary)

            Text(title)
                .appFont(.appTitle3, weight: .bold, color: .appTextPrimary)

            Text(description)
                .appFont(.appBody, color: .appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
        .padding(.horizontal)
    }

    private var fileSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(summaryTitle, systemImage: Images.System.filesTab)
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                Spacer()

                Text(ByteCountFormatter.string(fromByteCount: selectedSize, countStyle: .file))
                    .appFont(.appFootnote, weight: .semibold, color: .appTextSecondary)
            }

            if files.isEmpty {
                Text("No saved files are available yet.")
                    .appFont(.appCallout, color: .appTextSecondary)
            } else {
                if allowsFileSelection {
                    HStack(spacing: 12) {
                        Button("Select All") {
                            selectAllAction()
                        }
                        .appFont(.appFootnote, weight: .semibold, color: .appPrimary)

                        Button("Remove All") {
                            clearSelectionAction()
                        }
                        .appFont(.appFootnote, weight: .semibold, color: .appTextSecondary)

                        Spacer()
                    }
                }

                VStack(spacing: 8) {
                    ForEach(visibleFiles, id: \.objectID) { file in
                        Button {
                            if allowsFileSelection {
                                toggleFileAction(file)
                            }
                        } label: {
                            HStack {
                                Image(systemName: iconName(for: file))
                                    .foregroundColor(color(for: file))

                                Text(file.name)
                                    .appFont(.appCallout, weight: .semibold, color: .appTextPrimary)
                                    .lineLimit(1)

                                Spacer()

                                Text(file.fileType.uppercased())
                                    .appFont(.appCaption, weight: .bold, color: .appTextSecondary)
                            }
                        }
                        .disabled(!allowsFileSelection)
                        .buttonStyle(PlainButtonStyle())
                    }

                    if !allowsFileSelection && files.count > 5 {
                        Text("+ \(files.count - 5) more")
                            .appFont(.appCaption, color: .appTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
        .padding(.horizontal)
    }

    @ViewBuilder
    private var feedbackArea: some View {
        if let errorMessage {
            Text(errorMessage)
                .appFont(.appCallout, color: .appError)
                .padding(.horizontal)
        }

        if let statusMessage {
            Text(statusMessage)
                .appFont(.appCallout, weight: .semibold, color: .appSuccess)
                .padding(.horizontal)
        }
    }

    private var actionArea: some View {
        Group {
            if isProcessing {
                LoadingView(message: Strings.Export.processing)
                    .frame(height: 120)
            } else {
                PrimaryButton(
                    title: actionTitle,
                    iconName: actionIcon,
                    isEnabled: isActionEnabled,
                    action: action
                )
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private var selectedFiles: [SavedFile] {
        files.filter { selectedFileIDs.contains($0.id) }
    }

    private var visibleFiles: [SavedFile] {
        allowsFileSelection ? files : Array(files.prefix(5))
    }

    private var selectedSize: Int64 {
        let sizedFiles = allowsFileSelection ? selectedFiles : files
        return sizedFiles.reduce(Int64(0)) { $0 + $1.fileSize }
    }

    private var summaryTitle: String {
        if allowsFileSelection {
            return "\(selectedFileIDs.count) of \(files.count) Selected"
        }
        return "\(files.count) Files"
    }

    private var isActionEnabled: Bool {
        allowsFileSelection ? !selectedFileIDs.isEmpty : !files.isEmpty
    }

    private func iconName(for file: SavedFile) -> String {
        guard allowsFileSelection else { return "doc.text" }
        return selectedFileIDs.contains(file.id) ? "checkmark.circle.fill" : "circle"
    }

    private func color(for file: SavedFile) -> Color {
        guard allowsFileSelection else { return .appPrimary }
        return selectedFileIDs.contains(file.id) ? .appPrimary : .appTextSecondary
    }
}

#Preview {
    NavigationView {
        ZIPExportView()
    }
}
