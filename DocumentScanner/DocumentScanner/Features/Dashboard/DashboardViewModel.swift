//
//  DashboardViewModel.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
internal import Combine
internal import CoreData

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var recentFiles: [SavedFile] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let filesUseCase: ManageFilesUseCase
    
    init() {
        self.filesUseCase = ManageFilesUseCase()
    }
    
    func loadRecentFiles() {
        isLoading = true
        errorMessage = nil
        do {
            recentFiles = try filesUseCase.fetchRecentFiles(limit: 5)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func toggleFavorite(file: SavedFile) {
        do {
            try filesUseCase.toggleFavorite(file: file)
            loadRecentFiles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func renameFile(file: SavedFile, newName: String) {
        do {
            try filesUseCase.renameFile(file: file, newName: newName)
            loadRecentFiles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteFile(file: SavedFile) {
        let fileObjectID = file.objectID
        let previousFiles = recentFiles
        recentFiles.removeAll { $0.objectID == fileObjectID }

        do {
            try filesUseCase.deleteFile(file: file)
            loadRecentFiles()
        } catch {
            recentFiles = previousFiles
            errorMessage = error.localizedDescription
        }
    }
}
