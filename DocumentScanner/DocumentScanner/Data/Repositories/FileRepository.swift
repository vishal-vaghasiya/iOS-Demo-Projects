//
//  FileRepository.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import CoreData
internal import Foundation

class FileRepository: FileRepositoryProtocol {
    private let manager: CoreDataManager
    
    init(manager: CoreDataManager = .shared) {
        self.manager = manager
    }
    
    func saveFile(name: String, path: String, fileSize: Int64, fileType: String, sourceOperation: String) throws -> SavedFile {
        let context = manager.viewContext
        let savedFile = SavedFile(context: context)
        savedFile.id = UUID()
        savedFile.name = name
        savedFile.path = path
        savedFile.fileSize = fileSize
        savedFile.createdAt = Date()
        savedFile.fileType = fileType
        savedFile.isFavorite = false
        savedFile.sourceOperation = sourceOperation
        
        try context.save()
        Task { @MainActor in
            CoreDataBackupService.shared.scheduleBackup()
        }
        return savedFile
    }
    
    func fetchAllFiles() throws -> [SavedFile] {
        let request = SavedFile.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \SavedFile.createdAt, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        return try manager.viewContext.fetch(request)
    }
    
    func fetchFavoriteFiles() throws -> [SavedFile] {
        let request = SavedFile.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        let sortDescriptor = NSSortDescriptor(keyPath: \SavedFile.createdAt, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        return try manager.viewContext.fetch(request)
    }
    
    func toggleFavorite(file: SavedFile) throws {
        file.isFavorite.toggle()
        try manager.viewContext.save()
    }
    
    func renameFile(file: SavedFile, newName: String) throws {
        file.name = newName
        try manager.viewContext.save()
    }

    func updatePath(file: SavedFile, newPath: String) throws {
        file.path = newPath
        try manager.viewContext.save()
    }

    func updateFolderPath(oldPath: String, newPath: String) throws {
        let request = SavedFile.fetchRequest()
        request.predicate = NSPredicate(format: "path BEGINSWITH %@", "\(oldPath)/")
        let files = try manager.viewContext.fetch(request)

        for file in files {
            if file.path == oldPath {
                file.path = newPath
            } else if file.path.hasPrefix("\(oldPath)/") {
                file.path = "\(newPath)\(file.path.dropFirst(oldPath.count))"
            }
        }

        try manager.viewContext.save()
    }
    
    func deleteFile(file: SavedFile) throws {
        manager.viewContext.delete(file)
        try manager.viewContext.save()
    }
}
