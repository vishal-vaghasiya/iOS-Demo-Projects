//
//  CoreDataBackupService.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import CoreData
internal import Foundation

@MainActor
final class CoreDataBackupService {
    static let shared = CoreDataBackupService()

    private struct BackupManifest: Codable {
        let version: Int
        let backedUpAt: Date
        let files: [BackupFile]
    }

    private struct BackupFile: Codable {
        let id: UUID
        let name: String
        let path: String
        let fileSize: Int64
        let createdAt: Date
        let fileType: String
        let isFavorite: Bool
        let sourceOperation: String
    }

    private enum BackupLocation {
        static let containerIdentifier = "iCloud.com.ag.documentscanner"
        static let folderName = "DocumentScannerBackup"
        static let filesFolderName = "Files"
        static let manifestFileName = "manifest.json"
    }

    private let fileManager = FileManager.default
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var backupTask: Task<Void, Never>?

    private init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func restoreIfNeeded() async {
        do {
            guard try fetchSavedFiles().isEmpty else { return }
            guard let manifest = try loadManifest() else { return }

            try restoreFiles(from: manifest)
            try restoreCoreData(from: manifest)
        } catch {
            print("Core Data backup restore failed:", error.localizedDescription)
        }
    }

    func scheduleBackup() {
        backupTask?.cancel()
        backupTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 750_000_000)
            guard !Task.isCancelled else { return }
            await self?.backupCurrentLibrary()
        }
    }

    func backupCurrentLibrary() async {
        do {
            _ = try await backupNow()
        } catch {
            print("Core Data backup failed:", error.localizedDescription)
        }
    }

    func backupNow() async throws -> Int {
        let savedFiles = try fetchSavedFiles()
        try writeBackup(for: savedFiles)
        return savedFiles.count
    }

    private func writeBackup(for savedFiles: [SavedFile]) throws {
        guard let backupDirectory = try backupDirectory(createIfNeeded: true) else {
            throw NSError(
                domain: "CoreDataBackupService",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey: "iCloud Documents is unavailable. Sign in to iCloud and enable iCloud Drive for this app."
                ]
            )
        }

        let filesDirectory = backupDirectory.appendingPathComponent(BackupLocation.filesFolderName, isDirectory: true)
        try fileManager.createDirectory(at: filesDirectory, withIntermediateDirectories: true)

        let backupFiles = savedFiles.map { file in
            BackupFile(
                id: file.id,
                name: file.name,
                path: file.path,
                fileSize: file.fileSize,
                createdAt: file.createdAt,
                fileType: file.fileType,
                isFavorite: file.isFavorite,
                sourceOperation: file.sourceOperation
            )
        }

        try syncBackedUpFiles(savedFiles, to: filesDirectory)

        let manifest = BackupManifest(version: 1, backedUpAt: Date(), files: backupFiles)
        let manifestData = try encoder.encode(manifest)
        try manifestData.write(
            to: backupDirectory.appendingPathComponent(BackupLocation.manifestFileName),
            options: .atomic
        )
    }

    private func syncBackedUpFiles(_ savedFiles: [SavedFile], to filesDirectory: URL) throws {
        var expectedFileNames = Set<String>()

        for file in savedFiles {
            let sourceURL = TempFileManager.shared.getFileUrl(forRelativePath: file.path)
            guard fileManager.fileExists(atPath: sourceURL.path) else { continue }

            let backupName = backupFileName(for: file)
            let destinationURL = filesDirectory.appendingPathComponent(backupName)
            expectedFileNames.insert(backupName)

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        }

        let existingFileNames = try fileManager.contentsOfDirectory(atPath: filesDirectory.path)
        for fileName in existingFileNames where !expectedFileNames.contains(fileName) {
            try? fileManager.removeItem(at: filesDirectory.appendingPathComponent(fileName))
        }
    }

    private func restoreFiles(from manifest: BackupManifest) throws {
        guard let backupDirectory = try backupDirectory(createIfNeeded: false) else { return }

        let filesDirectory = backupDirectory.appendingPathComponent(BackupLocation.filesFolderName, isDirectory: true)

        for file in manifest.files {
            let sourceURL = filesDirectory.appendingPathComponent(backupFileName(for: file))
            guard fileManager.fileExists(atPath: sourceURL.path) else { continue }

            let destinationURL = TempFileManager.shared.getFileUrl(forRelativePath: file.path)
            let destinationFolder = destinationURL.deletingLastPathComponent()
            try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true)

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        }
    }

    private func restoreCoreData(from manifest: BackupManifest) throws {
        let context = CoreDataManager.shared.viewContext

        for file in manifest.files {
            let restoredFile = SavedFile(context: context)
            restoredFile.id = file.id
            restoredFile.name = file.name
            restoredFile.path = file.path
            restoredFile.fileSize = file.fileSize
            restoredFile.createdAt = file.createdAt
            restoredFile.fileType = file.fileType
            restoredFile.isFavorite = file.isFavorite
            restoredFile.sourceOperation = file.sourceOperation
        }

        if context.hasChanges {
            try context.save()
        }
    }

    private func loadManifest() throws -> BackupManifest? {
        guard let backupDirectory = try backupDirectory(createIfNeeded: false) else { return nil }

        let manifestURL = backupDirectory.appendingPathComponent(BackupLocation.manifestFileName)
        guard fileManager.fileExists(atPath: manifestURL.path) else { return nil }

        try? fileManager.startDownloadingUbiquitousItem(at: manifestURL)

        let data = try Data(contentsOf: manifestURL)
        return try decoder.decode(BackupManifest.self, from: data)
    }

    private func fetchSavedFiles() throws -> [SavedFile] {
        let request = SavedFile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedFile.createdAt, ascending: false)]
        return try CoreDataManager.shared.viewContext.fetch(request)
    }

    private func backupDirectory(createIfNeeded: Bool) throws -> URL? {
        guard let containerURL = fileManager.url(
            forUbiquityContainerIdentifier: BackupLocation.containerIdentifier
        ) else {
            return nil
        }

        let documentsURL = containerURL.appendingPathComponent("Documents", isDirectory: true)
        let backupURL = documentsURL.appendingPathComponent(BackupLocation.folderName, isDirectory: true)

        if createIfNeeded {
            try fileManager.createDirectory(at: backupURL, withIntermediateDirectories: true)
        }

        return backupURL
    }

    private func backupFileName(for file: SavedFile) -> String {
        "\(file.id.uuidString)_\(sanitize(file.path))"
    }

    private func backupFileName(for file: BackupFile) -> String {
        "\(file.id.uuidString)_\(sanitize(file.path))"
    }

    private func sanitize(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let cleanName = name.components(separatedBy: invalidCharacters).joined(separator: "_")
        return cleanName.isEmpty ? "document" : cleanName
    }
}
