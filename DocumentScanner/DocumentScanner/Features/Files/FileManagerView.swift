//
//  FileManagerView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
import QuickLook
internal import CoreData

struct FileManagerView: View {
    @StateObject private var viewModel = FileManagerViewModel()
    
    // File Action State
    @State private var fileToRename: SavedFile? = nil
    @State private var renameText = ""
    @State private var showRenameAlert = false
    @State private var fileToShare: URL? = nil
    @State private var previewURL: URL? = nil
    @State private var folderNameText = ""
    @State private var showCreateFolderAlert = false
    @State private var showRenameFolderAlert = false
    @State private var selectedFileIDs: Set<NSManagedObjectID> = []
    @State private var showBulkMoveDialog = false
    @State private var showBulkDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar & Filter Toggle Panel
            VStack(spacing: 12) {
                SearchBar(text: $viewModel.searchText, placeholder: Strings.Files.searchPlaceholder)
                
                HStack {
                    Toggle(isOn: $viewModel.showFavoritesOnly) {
                        Label(Strings.Files.favoriteOnly, systemImage: Images.System.favoriteFill)
                            .appFont(.appCallout, weight: .semibold, color: viewModel.showFavoritesOnly ? .appWarning : .appTextSecondary)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .appWarning))
                    .onChange(of: viewModel.showFavoritesOnly) { _ in
                        viewModel.loadFiles()
                    }
                    
                    Spacer()

                    Button {
                        folderNameText = ""
                        showCreateFolderAlert = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .frame(width: 32, height: 32)
                    }
                    .foregroundColor(.appPrimary)
                }

                folderStrip
            }
            .padding()
            .background(Color.appCardBackground)
            
            Divider()
            
            // List / Explorer area
            ZStack(alignment: .bottom) {
                fileListContent
                    .background(Color.appBackground.ignoresSafeArea())

                if isSelectionMode {
                    bulkActionBar
                }
            }
        }
        .navigationTitle(Strings.Files.title)
        .onAppear {
            viewModel.loadFiles()
        }
        .sheet(item: $fileToShare) { url in
            ShareSheet(activityItems: [url])
        }
        .sheet(item: $previewURL) { url in
            QuickLookPreview(url: url)
        }
        .alert(Strings.Files.renameTitle, isPresented: $showRenameAlert) {
            TextField("", text: $renameText)
            Button(Strings.General.cancel, role: .cancel) { fileToRename = nil }
            Button(Strings.General.save) {
                if let file = fileToRename, !renameText.trimmingCharacters(in: .whitespaces).isEmpty {
                    viewModel.renameFile(file: file, newName: renameText)
                }
                fileToRename = nil
            }
        }
        .alert("New Folder", isPresented: $showCreateFolderAlert) {
            TextField("Folder name", text: $folderNameText)
            Button(Strings.General.cancel, role: .cancel) {}
            Button(Strings.General.save) {
                let trimmed = folderNameText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    viewModel.createFolder(named: trimmed)
                }
            }
        }
        .alert("Rename Folder", isPresented: $showRenameFolderAlert) {
            TextField("Folder name", text: $folderNameText)
            Button(Strings.General.cancel, role: .cancel) {}
            Button(Strings.General.save) {
                let trimmed = folderNameText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    viewModel.renameSelectedFolder(to: trimmed)
                }
            }
        }
        .alert("Delete Selected Files?", isPresented: $showBulkDeleteAlert) {
            Button(Strings.General.cancel, role: .cancel) {}
            Button(Strings.General.delete, role: .destructive) {
                deleteSelectedFiles()
            }
        } message: {
            Text("This will permanently delete \(selectedFileIDs.count) selected file\(selectedFileIDs.count == 1 ? "" : "s").")
        }
        .confirmationDialog("Move Selected Files", isPresented: $showBulkMoveDialog, titleVisibility: .visible) {
            ForEach(viewModel.folders) { folder in
                Button(folder.name) {
                    moveSelectedFiles(to: folder)
                }
            }
            Button(Strings.General.cancel, role: .cancel) {}
        }
    }

    private var isSelectionMode: Bool {
        !selectedFileIDs.isEmpty
    }

    private var selectedFiles: [SavedFile] {
        viewModel.files.filter { selectedFileIDs.contains($0.objectID) }
    }

    private var folderStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Folders")
                    .appFont(.appCaption, weight: .bold, color: .appTextSecondary)
                    .textCase(.uppercase)
                Spacer()
                if viewModel.selectedFolder.path != nil {
                    Button("Rename") {
                        folderNameText = viewModel.selectedFolder.name
                        showRenameFolderAlert = true
                    }
                    .appFont(.appCaption, weight: .semibold, color: .appPrimary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.folders) { folder in
                        Button {
                            viewModel.selectedFolder = folder
                            selectedFileIDs.removeAll()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: folder.path == nil ? "tray.full" : "folder")
                                Text(folder.name)
                                    .lineLimit(1)
                            }
                            .appFont(.appCaption, weight: .semibold, color: viewModel.selectedFolder == folder ? .white : .appTextPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedFolder == folder ? Color.appPrimary : Color.appSecondaryBackground)
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var fileListContent: some View {
        if viewModel.isLoading {
            ScrollView {
                SkeletonListView(count: 4)
                    .padding(.top)
            }
        } else if viewModel.filteredFiles.isEmpty {
            EmptyStateView(
                title: viewModel.searchText.isEmpty ? Strings.Files.emptyState : "No matches",
                description: viewModel.searchText.isEmpty ? "All PDF, OCR and image operations will show up here." : "No files match your search criteria. Try a different query.",
                iconName: Images.System.emptyState,
                style: .empty
            )
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    ForEach(viewModel.dateSections) { section in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(section.title)
                                .appFont(.appFootnote, weight: .semibold, color: .appTextSecondary)
                                .textCase(.uppercase)
                                .padding(.horizontal)

                            LazyVStack(spacing: 10) {
                                ForEach(section.files, id: \.objectID) { file in
                                    fileCard(for: file)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
                .padding(.bottom, isSelectionMode ? 92 : 0)
            }
            .refreshable {
                viewModel.loadFiles()
            }
        }
    }

    private func fileCard(for file: SavedFile) -> some View {
        FileCard(
            file: file,
            onOpen: {
                previewURL = TempFileManager.shared.getFileUrl(forRelativePath: file.path)
            },
            onRename: {
                fileToRename = file
                renameText = file.name
                showRenameAlert = true
            },
            onDelete: {
                let fileObjectID = file.objectID
                let filePath = file.path
                let fileName = URL(fileURLWithPath: filePath).lastPathComponent

                if fileToRename?.objectID == fileObjectID {
                    fileToRename = nil
                }

                if let previewURL,
                   previewURL.lastPathComponent == fileName {
                    self.previewURL = nil
                }

                fileToShare = nil
                viewModel.deleteFile(file: file)
            },
            onToggleFavorite: {
                viewModel.toggleFavorite(file: file)
            },
            onShare: {
                fileToShare = TempFileManager.shared.getFileUrl(forRelativePath: file.path)
            },
            isSelectionMode: isSelectionMode,
            isSelected: selectedFileIDs.contains(file.objectID),
            onLongPress: {
                selectedFileIDs.insert(file.objectID)
            },
            onSelectionToggle: {
                toggleSelection(for: file)
            },
            moveMenu: AnyView(moveMenu(for: file))
        )
    }

    private var bulkActionBar: some View {
        VStack(spacing: 10) {
            HStack {
                Text("\(selectedFileIDs.count) selected")
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                Spacer()

                Button("Cancel") {
                    selectedFileIDs.removeAll()
                }
                .appFont(.appCallout, weight: .semibold, color: .appPrimary)
            }

            HStack(spacing: 12) {
                Button {
                    showBulkMoveDialog = true
                } label: {
                    bulkButton(title: "Move", iconName: "folder")
                }

                Button(role: .destructive) {
                    showBulkDeleteAlert = true
                } label: {
                    bulkButton(title: Strings.General.delete, iconName: Images.System.delete)
                }
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .overlay(Rectangle().fill(Color.appSeparator).frame(height: 1), alignment: .top)
    }

    private func bulkButton(title: String, iconName: String) -> some View {
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

    private func toggleSelection(for file: SavedFile) {
        if selectedFileIDs.contains(file.objectID) {
            selectedFileIDs.remove(file.objectID)
        } else {
            selectedFileIDs.insert(file.objectID)
        }
    }

    private func moveSelectedFiles(to folder: FileFolder) {
        let files = selectedFiles
        guard !files.isEmpty else { return }
        viewModel.moveFiles(files, to: folder)
        selectedFileIDs.removeAll()
    }

    private func deleteSelectedFiles() {
        let files = selectedFiles
        guard !files.isEmpty else { return }
        viewModel.deleteFiles(files)
        selectedFileIDs.removeAll()
    }

    private func moveMenu(for file: SavedFile) -> some View {
        Menu {
            ForEach(viewModel.folders) { folder in
                Button {
                    viewModel.moveFile(file, to: folder)
                } label: {
                    Label(folder.name, systemImage: folder.path == nil ? "tray.full" : "folder")
                }
                .disabled(file.folderPath == folder.path)
            }
        } label: {
            Label("Move To", systemImage: "folder")
        }
    }
}

#Preview {
    NavigationView {
        FileManagerView()
    }
}


struct QuickLookPreview: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    let url: URL
}

extension QuickLookPreview {
    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: context.coordinator,
            action: #selector(Coordinator.closePreview)
        )
        return UINavigationController(rootViewController: controller)
    }
    func updateUIViewController(_ controller: UINavigationController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(url: url, dismiss: dismiss) }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        let dismiss: DismissAction

        init(url: URL, dismiss: DismissAction) {
            self.url = url
            self.dismiss = dismiss
        }

        @objc func closePreview() {
            dismiss()
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}
