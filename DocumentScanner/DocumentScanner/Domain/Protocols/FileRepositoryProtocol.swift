//
//  FileRepositoryProtocol.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Foundation

protocol FileRepositoryProtocol {
    /// Saves a newly generated file's metadata to local persistent database.
    func saveFile(name: String, path: String, fileSize: Int64, fileType: String, sourceOperation: String) throws -> SavedFile
    
    /// Fetches all saved files.
    func fetchAllFiles() throws -> [SavedFile]
    
    /// Fetches only the favorite files.
    func fetchFavoriteFiles() throws -> [SavedFile]
    
    /// Toggles the favorite flag of a file.
    func toggleFavorite(file: SavedFile) throws
    
    /// Renames a file in Core Data.
    func renameFile(file: SavedFile, newName: String) throws

    /// Updates a file's relative path in Core Data.
    func updatePath(file: SavedFile, newPath: String) throws

    /// Updates all files inside a renamed folder.
    func updateFolderPath(oldPath: String, newPath: String) throws
    
    /// Deletes a file from Core Data.
    func deleteFile(file: SavedFile) throws
}
