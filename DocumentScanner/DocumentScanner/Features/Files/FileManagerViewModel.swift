//
//  FileManagerViewModel.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
internal import Combine
internal import CoreData

struct FileDateSection: Identifiable {
    let id: Date
    let title: String
    let files: [SavedFile]
}

struct FileFolder: Identifiable, Hashable {
    let path: String?
    let name: String

    var id: String { path ?? "__all__" }
}

@MainActor
class FileManagerViewModel: ObservableObject {
    @Published var files: [SavedFile] = []
    @Published var searchText = ""
    @Published var showFavoritesOnly = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var selectedFolder: FileFolder = FileFolder(path: nil, name: "All Files")
    
    private let filesUseCase: ManageFilesUseCase
    
    init(filesUseCase: ManageFilesUseCase = ManageFilesUseCase()) {
        self.filesUseCase = filesUseCase
    }
    
    func loadFiles() {
        isLoading = true
        errorMessage = nil
        do {
            if showFavoritesOnly {
                files = try filesUseCase.fetchFavoriteFiles()
            } else {
                files = try filesUseCase.fetchAllFiles()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    var filteredFiles: [SavedFile] {
        let folderFiltered = files.filter { file in
            guard let selectedPath = selectedFolder.path else { return true }
            return file.folderPath == selectedPath
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return folderFiltered }

        return folderFiltered.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.fileType.localizedCaseInsensitiveContains(query)
                || $0.sourceOperation.localizedCaseInsensitiveContains(query)
                || $0.folderDisplayName.localizedCaseInsensitiveContains(query)
        }
    }

    var folders: [FileFolder] {
        let storedFolders = Set(files.compactMap(\.folderPath))
        let diskFolders = Set(filesUseCase.listFolders())
        let folderPaths = storedFolders.union(diskFolders).sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }

        return [FileFolder(path: nil, name: "All Files")] + folderPaths.map {
            FileFolder(path: $0, name: URL(fileURLWithPath: $0).lastPathComponent)
        }
    }

    var dateSections: [FileDateSection] {
        let calendar = Calendar.current
        let groupedFiles = Dictionary(grouping: filteredFiles) { file in
            calendar.startOfDay(for: file.createdAt)
        }

        return groupedFiles.keys.sorted(by: >).map { day in
            let sectionFiles = (groupedFiles[day] ?? []).sorted { $0.createdAt > $1.createdAt }
            return FileDateSection(
                id: day,
                title: sectionTitle(for: day, calendar: calendar),
                files: sectionFiles
            )
        }
    }
    
    func toggleFavorite(file: SavedFile) {
        do {
            try filesUseCase.toggleFavorite(file: file)
            loadFiles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func renameFile(file: SavedFile, newName: String) {
        do {
            try filesUseCase.renameFile(file: file, newName: newName)
            loadFiles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createFolder(named name: String) {
        do {
            try filesUseCase.createFolder(named: name)
            loadFiles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func renameSelectedFolder(to newName: String) {
        guard let path = selectedFolder.path else { return }

        do {
            try filesUseCase.renameFolder(path: path, newName: newName)
            selectedFolder = FileFolder(path: nil, name: "All Files")
            loadFiles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func moveFile(_ file: SavedFile, to folder: FileFolder) {
        do {
            try filesUseCase.moveFile(file, toFolder: folder.path)
            loadFiles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func moveFiles(_ filesToMove: [SavedFile], to folder: FileFolder) {
        do {
            for file in filesToMove {
                try filesUseCase.moveFile(file, toFolder: folder.path)
            }
            loadFiles()
        } catch {
            errorMessage = error.localizedDescription
            loadFiles()
        }
    }
    
    func deleteFile(file: SavedFile) {
        let fileObjectID = file.objectID
        let previousFiles = files
        files.removeAll { $0.objectID == fileObjectID }

        do {
            try filesUseCase.deleteFile(file: file)
            loadFiles()
        } catch {
            files = previousFiles
            errorMessage = error.localizedDescription
        }
    }

    func deleteFiles(_ filesToDelete: [SavedFile]) {
        let fileObjectIDs = Set(filesToDelete.map(\.objectID))
        let previousFiles = files
        files.removeAll { fileObjectIDs.contains($0.objectID) }

        do {
            for file in filesToDelete {
                try filesUseCase.deleteFile(file: file)
            }
            loadFiles()
        } catch {
            files = previousFiles
            errorMessage = error.localizedDescription
            loadFiles()
        }
    }

    private func sectionTitle(for day: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(day) {
            return Strings.Files.today
        }

        if calendar.isDateInYesterday(day) {
            return Strings.Files.yesterday
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: day)
    }
}
