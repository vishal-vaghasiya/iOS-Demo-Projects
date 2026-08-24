//
//  TempFileManager.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Foundation
import UIKit

class TempFileManager {
    static let shared = TempFileManager()
    
    private let fileManager = FileManager.default
    
    private var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var tempDirectory: URL {
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(AppConstants.tempDirectoryName)
        try? fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true, attributes: nil)
        return tempURL
    }
    
    private init() {
        cleanupTempDirectory()
    }
    
    /// Returns the absolute path for a filename stored in the documents directory.
    func getFileUrl(forRelativePath relativePath: String) -> URL {
        return documentsDirectory.appendingPathComponent(relativePath)
    }
    
    /// Generates a unique URL in the temp directory.
    func getTempUrl(extension ext: String) -> URL {
        let uniqueName = "\(UUID().uuidString).\(ext)"
        return tempDirectory.appendingPathComponent(uniqueName)
    }
    
    /// Saves a file from a temp URL to the documents folder, returning the relative path.
    func saveFileToDocuments(fromTempUrl tempUrl: URL, preferredName: String, folderName: String? = nil) throws -> (relativePath: String, absoluteUrl: URL) {
        let sanitizedName = sanitizeFileName(preferredName)
        let folderPath = sanitizedFolderPath(folderName)
        let baseDirectory = try documentsDirectoryForFolder(folderPath)
        var targetUrl = baseDirectory.appendingPathComponent(sanitizedName)
        
        // Handle name collisions
        let baseName = (sanitizedName as NSString).deletingPathExtension
        let ext = (sanitizedName as NSString).pathExtension
        var counter = 1
        while fileManager.fileExists(atPath: targetUrl.path) {
            let collisionName = "\(baseName)_\(counter).\(ext)"
            targetUrl = baseDirectory.appendingPathComponent(collisionName)
            counter += 1
        }
        
        try fileManager.moveItem(at: tempUrl, to: targetUrl)
        return (relativePath(for: targetUrl), targetUrl)
    }
    
    /// Saves raw Data directly to the documents directory, returning the relative path and absolute URL.
    func saveRawDataToDocuments(data: Data, preferredName: String) throws -> (relativePath: String, absoluteUrl: URL) {
        let tempUrl = getTempUrl(extension: (preferredName as NSString).pathExtension)
        try data.write(to: tempUrl, options: .atomic)
        return try saveFileToDocuments(fromTempUrl: tempUrl, preferredName: preferredName)
    }
    
    /// Renames a file in the documents directory.
    func renameFile(relativePath: String, newName: String) throws -> String {
        let currentUrl = getFileUrl(forRelativePath: relativePath)
        let ext = (relativePath as NSString).pathExtension
        var sanitizedName = sanitizeFileName(newName)
        if (sanitizedName as NSString).pathExtension != ext {
            sanitizedName = "\(sanitizedName).\(ext)"
        }
        
        let currentFolder = (relativePath as NSString).deletingLastPathComponent
        let baseDirectory = try documentsDirectoryForFolder(currentFolder == "." ? nil : currentFolder)
        let targetUrl = baseDirectory.appendingPathComponent(sanitizedName)
        if fileManager.fileExists(atPath: targetUrl.path) {
            throw NSError(domain: "TempFileManager", code: 409, userInfo: [NSLocalizedDescriptionKey: "A file with that name already exists."])
        }
        
        try fileManager.moveItem(at: currentUrl, to: targetUrl)
        return self.relativePath(for: targetUrl)
    }

    func createFolder(named name: String) throws -> String {
        let folderPath = sanitizedFolderPath(name)
        guard let folderPath, !folderPath.isEmpty else {
            throw NSError(domain: "TempFileManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Enter a folder name."])
        }

        let folderUrl = documentsDirectory.appendingPathComponent(folderPath, isDirectory: true)
        if fileManager.fileExists(atPath: folderUrl.path) {
            throw NSError(domain: "TempFileManager", code: 409, userInfo: [NSLocalizedDescriptionKey: "A folder with that name already exists."])
        }

        try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        return folderPath
    }

    func listFolders() -> [String] {
        guard let enumerator = fileManager.enumerator(
            at: documentsDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var folders: [String] = []
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: [.isDirectoryKey]),
                  values.isDirectory == true else {
                continue
            }
            folders.append(relativePath(for: url))
        }

        return folders.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    func renameFolder(relativePath: String, newName: String) throws -> String {
        let currentPath = sanitizedFolderPath(relativePath) ?? relativePath
        let newPath = try createFolderNameForRename(currentPath: currentPath, newName: newName)
        let currentUrl = documentsDirectory.appendingPathComponent(currentPath, isDirectory: true)
        let targetUrl = documentsDirectory.appendingPathComponent(newPath, isDirectory: true)

        guard fileManager.fileExists(atPath: currentUrl.path) else {
            throw NSError(domain: "TempFileManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Folder not found."])
        }

        if fileManager.fileExists(atPath: targetUrl.path) {
            throw NSError(domain: "TempFileManager", code: 409, userInfo: [NSLocalizedDescriptionKey: "A folder with that name already exists."])
        }

        try fileManager.moveItem(at: currentUrl, to: targetUrl)
        return newPath
    }

    func moveFile(relativePath: String, toFolder folderName: String?) throws -> String {
        let currentUrl = getFileUrl(forRelativePath: relativePath)
        let targetDirectory = try documentsDirectoryForFolder(sanitizedFolderPath(folderName))
        var targetUrl = targetDirectory.appendingPathComponent(currentUrl.lastPathComponent)

        if currentUrl.standardizedFileURL == targetUrl.standardizedFileURL {
            return relativePath
        }

        let baseName = (targetUrl.lastPathComponent as NSString).deletingPathExtension
        let ext = (targetUrl.lastPathComponent as NSString).pathExtension
        var counter = 1
        while fileManager.fileExists(atPath: targetUrl.path) {
            targetUrl = targetDirectory.appendingPathComponent("\(baseName)_\(counter).\(ext)")
            counter += 1
        }

        try fileManager.moveItem(at: currentUrl, to: targetUrl)
        cleanupEmptyParentFolder(for: currentUrl)
        return self.relativePath(for: targetUrl)
    }
    
    /// Deletes a file in the documents directory.
    func deleteFile(relativePath: String) throws {
        let fileUrl = getFileUrl(forRelativePath: relativePath)
        if fileManager.fileExists(atPath: fileUrl.path) {
            try fileManager.removeItem(at: fileUrl)
        }
    }
    
    /// Completely empties the temporary directory.
    func cleanupTempDirectory() {
        let tempPath = tempDirectory.path
        guard let files = try? fileManager.contentsOfDirectory(atPath: tempPath) else { return }
        for file in files {
            let fileUrl = tempDirectory.appendingPathComponent(file)
            try? fileManager.removeItem(at: fileUrl)
        }
    }
    
    /// Helper to sanitize filenames, removing invalid characters.
    func sanitizeDisplayName(_ name: String) -> String {
        sanitizeFileName(name)
    }

    private func sanitizeFileName(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let cleanName = name.components(separatedBy: invalidCharacters).joined(separator: "_")
        return cleanName.isEmpty ? "document_\(UUID().uuidString.prefix(6))" : cleanName
    }

    private func sanitizedFolderPath(_ folderName: String?) -> String? {
        guard let folderName else { return nil }
        let trimmed = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "." else { return nil }

        return trimmed
            .split(separator: "/")
            .map { sanitizeFileName(String($0)) }
            .joined(separator: "/")
    }

    private func documentsDirectoryForFolder(_ folderPath: String?) throws -> URL {
        guard let folderPath, !folderPath.isEmpty else { return documentsDirectory }

        let directory = documentsDirectory.appendingPathComponent(folderPath, isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        return directory
    }

    private func relativePath(for url: URL) -> String {
        let absolutePath = url.standardizedFileURL.path
        let documentsPath = documentsDirectory.standardizedFileURL.path
        guard absolutePath.hasPrefix(documentsPath) else { return url.lastPathComponent }

        return String(absolutePath.dropFirst(documentsPath.count + 1))
    }

    private func createFolderNameForRename(currentPath: String, newName: String) throws -> String {
        let parent = (currentPath as NSString).deletingLastPathComponent
        let folderName = sanitizeFileName(newName)
        guard !folderName.isEmpty else {
            throw NSError(domain: "TempFileManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Enter a folder name."])
        }

        return parent == "." || parent.isEmpty ? folderName : "\(parent)/\(folderName)"
    }

    private func cleanupEmptyParentFolder(for fileUrl: URL) {
        let parent = fileUrl.deletingLastPathComponent()
        guard parent.standardizedFileURL != documentsDirectory.standardizedFileURL else { return }

        if let contents = try? fileManager.contentsOfDirectory(atPath: parent.path), contents.isEmpty {
            try? fileManager.removeItem(at: parent)
        }
    }
}
