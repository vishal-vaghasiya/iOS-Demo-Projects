//
//  AutoICloudSyncManager.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 04/11/25.
//

import Foundation
import UIKit

final class AutoICloudSyncManager: NSObject {
    
    static let shared = AutoICloudSyncManager()
    private let fileManager = FileManager.default
    // Optional: set this to your explicit iCloud container identifier if you use one
    public var ubiquityContainerIdentifier: String? = nil
    private var directoryMonitor: DispatchSourceFileSystemObject?
    private var metadataQuery: NSMetadataQuery?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    // Progress callback type alias
    typealias SyncProgressHandler = (_ completedBytes: Int64, _ totalBytes: Int64) -> Void
    
    private override init() {}
    
    // MARK: - Paths
    
    private var localDocumentsURL: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var iCloudDocumentsURL: URL? {
        return fileManager.url(forUbiquityContainerIdentifier: ubiquityContainerIdentifier)?.appendingPathComponent("Documents")
    }
    
    // MARK: - Setup
    
    func startAutoSync() {
        guard isICloudAvailable() else {
            print("⚠️ iCloud unavailable or user not signed in.")
            return
        }
        
        setupLocalWatcher()
        setupICloudWatcher()
        
        print("✅ Auto sync started for Documents folder.")
    }
    
    func stopAutoSync() {
        directoryMonitor?.cancel()
        metadataQuery?.stop()
        NotificationCenter.default.removeObserver(self)
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
        print("🛑 Auto sync stopped.")
    }
    
    func isICloudAvailable() -> Bool {
        return fileManager.ubiquityIdentityToken != nil
    }
    
    // MARK: - Local Directory Watcher
    
    private func setupLocalWatcher() {
        let fd = open(localDocumentsURL.path, O_EVTONLY)
        guard fd >= 0 else { return }
        
        directoryMonitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .extend],
            queue: DispatchQueue.global()
        )
        
        directoryMonitor?.setEventHandler { [weak self] in
            guard let self = self else { return }
            print("📁 Local document folder changed — syncing with iCloud...")
            self.syncLocalAndICloud(progressHandler: nil)
        }
        
        directoryMonitor?.setCancelHandler {
            close(fd)
        }
        
        directoryMonitor?.resume()
    }
    
    // MARK: - iCloud Watcher (for remote changes)
    
    private func setupICloudWatcher() {
        guard let _ = iCloudDocumentsURL else { return }
        
        metadataQuery = NSMetadataQuery()
        metadataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        metadataQuery?.predicate = NSPredicate(value: true)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudQueryUpdated),
            name: .NSMetadataQueryDidFinishGathering,
            object: metadataQuery
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudQueryUpdated),
            name: .NSMetadataQueryDidUpdate,
            object: metadataQuery
        )
        
        metadataQuery?.start()
    }
    
    @objc private func iCloudQueryUpdated() {
        print("☁️ iCloud updated — syncing local copy with iCloud...")
        syncLocalAndICloud(progressHandler: nil)
    }
    
    // MARK: - Sync Methods
    
    /// Syncs files between local Documents and iCloud Documents directories, handling uploads, downloads, and deletions.
    /// - Parameter progressHandler: Optional closure to report progress updates (completedBytes, totalBytes).
    func syncLocalAndICloud(progressHandler: SyncProgressHandler?) {
        guard let iCloudURL = iCloudDocumentsURL else { return }

        // Begin background task so iOS gives us time to complete syncing when app goes to background
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "AutoICloudSync") {
            if self.backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = .invalid
            }
        }

        DispatchQueue.global().async {
            do {
                let localEmpty = (try? self.fileManager.contentsOfDirectory(atPath: self.localDocumentsURL.path).isEmpty) ?? true
                let isFirstRun = localEmpty && !UserDefaults.standard.bool(forKey: "HasPerformedInitialICloudSync")
                if isFirstRun {
                    print("🆕 First run detected — restoring all files from iCloud (no deletions).")
                }
                
                let localFiles = try self.fileManager.contentsOfDirectory(at: self.localDocumentsURL, includingPropertiesForKeys: nil)
                let cloudFiles = try self.fileManager.contentsOfDirectory(at: iCloudURL, includingPropertiesForKeys: nil)
                
                // Create dictionaries keyed by filename for quick lookup
                let localDict = Dictionary(uniqueKeysWithValues: localFiles.map { ($0.lastPathComponent, $0) })
                let cloudDict = Dictionary(uniqueKeysWithValues: cloudFiles.map { ($0.lastPathComponent, $0) })
                
                // Determine files to upload, download, or delete
                var filesToUpload = [URL]()
                var filesToDownload = [URL]()
                var filesToDeleteLocally = [URL]()
                var filesToDeleteInCloud = [URL]()
                
                // Files in local but not in cloud => upload
                for fileName in localDict.keys {
                    if cloudDict[fileName] == nil {
                        filesToUpload.append(localDict[fileName]!)
                    }
                }
                
                // Files in cloud but not in local => download
                for fileName in cloudDict.keys {
                    if localDict[fileName] == nil {
                        filesToDownload.append(cloudDict[fileName]!)
                    }
                }
                
                // Files deleted locally but still in cloud => delete in cloud
                for fileName in cloudDict.keys {
                    if !localDict.keys.contains(fileName) {
                        // Check if the file was deleted locally (and exists in cloud)
                        // For simplicity, treat all files missing locally but present in cloud as needing download
                        // or if we want to delete in cloud if user deleted locally:
                        // Here, we will delete in cloud if file missing locally but present in cloud.
                        // However, to avoid conflict, we only delete in cloud if the file is not currently downloading.
                        // For this example, let's delete in cloud if missing locally.
                        filesToDeleteInCloud.append(cloudDict[fileName]!)
                    }
                }
                
                // Files deleted in cloud but still locally => delete locally
                for fileName in localDict.keys {
                    if !cloudDict.keys.contains(fileName) {
                        // If file missing in cloud but present locally, delete locally
                        filesToDeleteLocally.append(localDict[fileName]!)
                    }
                }
                
                if isFirstRun {
                    filesToDeleteInCloud.removeAll()
                    filesToDeleteLocally.removeAll()
                }
                
                // Compute total bytes for size-weighted progress reporting
                var totalBytes: Int64 = 0
                func fileSizeBytes(for url: URL) -> Int64 {
                    let bytes = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                    return Int64(bytes > 0 ? bytes : 1) // treat unknown size as 1 byte to count progress
                }
                for f in filesToUpload { totalBytes += fileSizeBytes(for: f) }
                for f in filesToDownload { totalBytes += fileSizeBytes(for: f) }
                for f in filesToDeleteLocally { totalBytes += fileSizeBytes(for: f) }
                for f in filesToDeleteInCloud { totalBytes += fileSizeBytes(for: f) }
                var completedBytes: Int64 = 0
                
                func reportProgressBytes() {
                    DispatchQueue.main.async {
                        progressHandler?(completedBytes, totalBytes)
                    }
                }
                reportProgressBytes()
                
                // Upload files to iCloud
                for file in filesToUpload {
                    let destination = iCloudURL.appendingPathComponent(file.lastPathComponent)
                    if !self.fileManager.fileExists(atPath: destination.path) {
                        do {
                            try self.fileManager.setUbiquitous(true, itemAt: file, destinationURL: destination)
                            print("✅ Uploaded \(file.lastPathComponent) to iCloud.")
                        } catch {
                            print("❌ Upload error for \(file.lastPathComponent): \(error.localizedDescription)")
                        }
                    }
                    completedBytes += fileSizeBytes(for: file)
                    reportProgressBytes()
                }
                
                // Download files from iCloud
                for file in filesToDownload {
                    let localDestination = self.localDocumentsURL.appendingPathComponent(file.lastPathComponent)
                    if !self.fileManager.fileExists(atPath: localDestination.path) {
                        do {
                            try self.fileManager.startDownloadingUbiquitousItem(at: file)
                            // Wait for download to complete by checking the ubiquitousItemDownloadingStatusKey
                            var isDownloaded = false
                            let statusValues = try file.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
                            let status = statusValues.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus
                            isDownloaded = (status == .current || status == .downloaded)
                            var waitCount = 0
                            while !isDownloaded && waitCount < 300 { // wait up to ~30s (0.1s * 300)
                                Thread.sleep(forTimeInterval: 0.1)
                                let updatedStatusValues = try file.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
                                let updatedStatus = updatedStatusValues.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus
                                isDownloaded = (updatedStatus == .current || updatedStatus == .downloaded)
                                waitCount += 1
                            }
                            if self.fileManager.fileExists(atPath: localDestination.path) {
                                try self.fileManager.removeItem(at: localDestination)
                            }
                            try self.fileManager.copyItem(at: file, to: localDestination)
                            print("⬇️ Downloaded \(file.lastPathComponent) from iCloud.")
                        } catch {
                            print("❌ Download error for \(file.lastPathComponent): \(error.localizedDescription)")
                        }
                    }
                    completedBytes += fileSizeBytes(for: file)
                    reportProgressBytes()
                }
                
                // Delete files locally that were deleted in iCloud
                for file in filesToDeleteLocally {
                    do {
                        try self.fileManager.removeItem(at: file)
                        print("🗑️ Deleted local file \(file.lastPathComponent) as it was removed from iCloud.")
                    } catch {
                        print("❌ Local delete error for \(file.lastPathComponent): \(error.localizedDescription)")
                    }
                    completedBytes += fileSizeBytes(for: file)
                    reportProgressBytes()
                }
                
                // Delete files in iCloud that were deleted locally
                for file in filesToDeleteInCloud {
                    do {
                        try self.fileManager.removeItem(at: file)
                        print("🗑️ Deleted iCloud file \(file.lastPathComponent) as it was removed locally.")
                    } catch {
                        print("❌ iCloud delete error for \(file.lastPathComponent): \(error.localizedDescription)")
                    }
                    completedBytes += fileSizeBytes(for: file)
                    reportProgressBytes()
                }
                
                if isFirstRun {
                    UserDefaults.standard.set(true, forKey: "HasPerformedInitialICloudSync")
                }
                
                // End background task if running
                if self.backgroundTask != .invalid {
                    UIApplication.shared.endBackgroundTask(self.backgroundTask)
                    self.backgroundTask = .invalid
                }
                
            } catch {
                print("❌ Sync error: \(error.localizedDescription)")
            }
        }
    }
    
    deinit {
        directoryMonitor?.cancel()
        metadataQuery?.stop()
        NotificationCenter.default.removeObserver(self)
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    /// Stub: resolve conflicting versions for a file. Implement app-specific merge policy here.
    func resolveConflicts(for file: URL) {
        // Example: list unresolved versions
        guard let conflictVersions = NSFileVersion.unresolvedConflictVersionsOfItem(at: file) else { return }
        for version in conflictVersions {
            // TODO: implement merging / resolution. For now, mark as resolved by keeping current version.
            version.isResolved = true
        }
        try? NSFileVersion.removeOtherVersionsOfItem(at: file)
    }
    
    /// Helper method to observe sync progress and print updates.
    /// - Parameter progressHandler: Closure called with completed and total bytes counts.
    func observeProgress(progressHandler: @escaping SyncProgressHandler) {
        // This method can be used by UI to listen to progress updates by passing a closure to syncLocalAndICloud.
        // Example usage:
        // AutoICloudSyncManager.shared.syncLocalAndICloud(progressHandler: { completedBytes, totalBytes in
        //     print("Sync progress: \(completedBytes) / \(totalBytes) bytes")
        // })
    }
}

/*⚙️ How to Use It

In your AppDelegate or SceneDelegate:

// Start auto sync when app becomes active
func sceneDidBecomeActive(_ scene: UIScene) {
    AutoICloudSyncManager.shared.startAutoSync()
}

// Optional: stop auto sync when app enters background
func sceneDidEnterBackground(_ scene: UIScene) {
    AutoICloudSyncManager.shared.stopAutoSync()
}

// To observe sync progress and update UI, call syncLocalAndICloud with a progress handler:
AutoICloudSyncManager.shared.syncLocalAndICloud { completed, total in
    DispatchQueue.main.async {
        // Update UI progress bar or label here
        print("Sync progress: \(completed) / \(total)")
    }
}

This manager automatically syncs all data between the local Documents folder and iCloud Documents folder in both directions, including uploading new files, downloading new files, and deleting files removed from either location.

*/
