//
//  StickerManager.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 24/10/25.
//

import Foundation
import UIKit
import ZIPFoundation
import FirebaseRemoteConfig
import Alamofire

class StickerManager {

    static let shared = StickerManager()
    private let remoteConfig = RemoteConfig.remoteConfig()
    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings
    }

    // MARK: - Public
    func fetchAndStoreStickers() {
        fetchStickerJSON()
    }

    // MARK: - Individual Stickers JSON
    private func fetchStickerJSON() {
        remoteConfig.fetchAndActivate { status, error in
            guard error == nil else {
                print("Remote Config fetch error: \(error!.localizedDescription)")
                return
            }
            let jsonData = self.remoteConfig["sticker_packs"].jsonValue as? [String:Any] ?? [:]
            DefaultManager.STICKER_PACK_JSON = jsonData
            
            let stickerData = self.remoteConfig["sticker_packs_zip"].jsonValue as? [String:Any] ?? [:]
            let stickerPacks = stickerData["sticker_packs_zip"] as? [[String: String]] ?? []
            for zipPack in stickerPacks {
                let name = zipPack["name"] ?? ""
                let url = zipPack["url"] ?? ""
                self.downloadZip(urlString: url, folderName: name)
            }
        }
    }

    // MARK: - Download ZIP using Alamofire
    private func downloadZip(urlString: String, folderName: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationZipURL = documentsURL.appendingPathComponent("\(folderName).zip")
        let folderURL = documentsURL.appendingPathComponent(folderName)
        
        if FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: folderURL.path)
                if let creationDate = attributes[.creationDate] as? Date {
                    let daysOld = Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0
                    if daysOld >= 8 {
                        print("Existing zip file is older than 8 days. Removing...")
                        try FileManager.default.removeItem(at: folderURL)
                    } else {
                        print("Zip file is recent (\(daysOld) days old), checking folder contents...")
                        do {
                            let contents = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
                            if contents.isEmpty {
                                print("Folder is empty, re-downloading zip.")
                            } else {
                                print("Folder has contents, skipping re-download.")
                                return
                            }
                        } catch {
                            print("Failed to check folder contents: \(error.localizedDescription)")
                        }
                    }
                }
            } catch {
                print("Error checking file attributes: \(error.localizedDescription)")
            }
        }
        
        let destination: DownloadRequest.Destination = { _, _ in
            if FileManager.default.fileExists(atPath: destinationZipURL.path) {
                do {
                    try FileManager.default.removeItem(at: destinationZipURL)
                } catch {
                }
            }
            return (destinationZipURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(url, to: destination).response { response in
            if let error = response.error {
                print("Failed to download zip file: \(error.localizedDescription)")
                return
            }
            
            guard let filePath = response.fileURL else {
                print("Failed to get downloaded file URL.")
                return
            }
            
            
            
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath.path)
                let fileSize = fileAttributes[.size] as? UInt64 ?? 0
                let expectedSize = response.response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
                
                if expectedSize != NSURLSessionTransferSizeUnknown && fileSize < expectedSize {
                    print("Downloaded file size is less than expected.")
                    deleteFile(filePath: filePath)
                    return
                }
                let destinationFolderURL = documentsURL
                do {
                    try FileManager.default.unzipItem(at: filePath, to: destinationFolderURL)
                    removeMacOSXFolder(in: destinationFolderURL)
                    deleteFile(filePath: filePath)
                } catch {
                    //print("Failed to unzip file: \(error.localizedDescription)")
                    removeMacOSXFolder(in: destinationFolderURL)
                    deleteFile(filePath: filePath)
                }
            } catch {
                print("Error checking downloaded file attributes: \(error.localizedDescription)")
            }
        }
        
        func deleteFile(filePath: URL){
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                print("Failed to delete zip file: \(error.localizedDescription)")
            }
        }
        
        func removeMacOSXFolder(in directory: URL) {
            let macosxFolderURL = directory.appendingPathComponent("__MACOSX")
            if FileManager.default.fileExists(atPath: macosxFolderURL.path) {
                do {
                    try FileManager.default.removeItem(at: macosxFolderURL)
                } catch {
                    print("Failed to delete __MACOSX folder: \(error.localizedDescription)")
                }
            }
        }
    }
}
