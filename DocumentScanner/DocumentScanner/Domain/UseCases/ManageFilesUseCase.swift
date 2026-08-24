//
//  ManageFilesUseCase.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Foundation
internal import CoreData

class ManageFilesUseCase {
    private let repository: FileRepositoryProtocol
    
    init(repository: FileRepositoryProtocol = FileRepository()) {
        self.repository = repository
    }
    
    func fetchRecentFiles(limit: Int = 5) throws -> [SavedFile] {
        let all = try repository.fetchAllFiles()
        return Array(all.prefix(limit))
    }
    
    func fetchAllFiles() throws -> [SavedFile] {
        return try repository.fetchAllFiles()
    }
    
    func fetchFavoriteFiles() throws -> [SavedFile] {
        return try repository.fetchFavoriteFiles()
    }
    
    func toggleFavorite(file: SavedFile) throws {
        try repository.toggleFavorite(file: file)
        scheduleBackup()
    }
    
    func renameFile(file: SavedFile, newName: String) throws {
        // First rename actual file on disk
        let newPath = try TempFileManager.shared.renameFile(relativePath: file.path, newName: newName)
        
        // Then update DB
        try repository.renameFile(file: file, newName: (newName as NSString).deletingPathExtension)
        file.path = newPath
        try CoreDataManager.shared.viewContext.save()
        scheduleBackup()
    }
    
    func deleteFile(file: SavedFile) throws {
        let relativePath = file.path

        // Remove from disk
        try TempFileManager.shared.deleteFile(relativePath: relativePath)
        
        // Remove from DB
        try repository.deleteFile(file: file)
        scheduleBackup()
    }

    func saveProcessedResults(_ results: [ProcessedFileResult], preferredFolderName: String?) throws -> [SavedFile] {
        guard !results.isEmpty else { return [] }

        let folderName = results.count > 1 ? preferredFolderName : nil
        var savedFiles: [SavedFile] = []
        savedFiles.reserveCapacity(results.count)

        for result in results {
            let fullName = result.displayName
            let (relativePath, absoluteUrl) = try TempFileManager.shared.saveFileToDocuments(
                fromTempUrl: result.url,
                preferredName: fullName,
                folderName: folderName
            )
            let attributes = try FileManager.default.attributesOfItem(atPath: absoluteUrl.path)
            let size = attributes[.size] as? Int64 ?? result.fileSize
            let savedFile = try repository.saveFile(
                name: result.name,
                path: relativePath,
                fileSize: size,
                fileType: result.fileType,
                sourceOperation: result.sourceOperation
            )
            savedFiles.append(savedFile)
        }

        scheduleBackup()
        return savedFiles
    }

    func createFolder(named name: String) throws {
        _ = try TempFileManager.shared.createFolder(named: name)
    }

    func listFolders() -> [String] {
        TempFileManager.shared.listFolders()
    }

    func renameFolder(path: String, newName: String) throws {
        let newPath = try TempFileManager.shared.renameFolder(relativePath: path, newName: newName)
        try repository.updateFolderPath(oldPath: path, newPath: newPath)
        scheduleBackup()
    }

    func moveFile(_ file: SavedFile, toFolder folderName: String?) throws {
        let newPath = try TempFileManager.shared.moveFile(relativePath: file.path, toFolder: folderName)
        try repository.updatePath(file: file, newPath: newPath)
        scheduleBackup()
    }

    private func scheduleBackup() {
        Task { @MainActor in
            CoreDataBackupService.shared.scheduleBackup()
        }
    }
}
