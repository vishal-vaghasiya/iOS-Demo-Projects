//
//  StickerPackManager.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 09/10/25.
//

import UIKit

extension Dictionary {
    func bytesSize() -> Int {
        let data: NSMutableData = NSMutableData()
        let encoder: NSKeyedArchiver = NSKeyedArchiver(forWritingWith: data)
        encoder.encode(self, forKey: "dictionary")
        encoder.finishEncoding()

        return data.length
    }
}

class StickerPackManager {

    static let queue: DispatchQueue = DispatchQueue(label: "stickerPackQueue")

    static func prepareStickerImage(fileURL: URL) throws {
        guard fileURL.pathExtension.lowercased() == "png" else {
            // Only process PNG files
            return
        }
        guard let image = UIImage(contentsOfFile: fileURL.path) else {
            return
        }
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return
        }
        UIGraphicsEndImageContext()

        guard let cgImage = resizedImage.cgImage else {
            return
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 4 * Int(size.width), space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let ctx = context else {
            return
        }
        ctx.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let cleanedCGImage = ctx.makeImage() else {
            return
        }
        let cleanedImage = UIImage(cgImage: cleanedCGImage)

        guard let pngData = cleanedImage.pngData() else {
            return
        }
        try pngData.write(to: fileURL, options: .atomic)
    }

    static func stickersJSON(contentsOfFile filename: String) throws -> [String: Any] {
        /*if let path = Bundle.main.path(forResource: filename, ofType: "json"/*"wasticker"*/) {
            let data: Data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            return try JSONSerialization.jsonObject(with: data) as! [String: Any]
        }
        throw StickerPackError.fileNotFound*/
        return DefaultManager.STICKER_PACK_JSON
    }

    /**
     *  Retrieves sticker packs from a JSON dictionary.
     *  If the processing of a certain sticker pack encounters an exception (see methods in StickerPack.swift),
     *  that sticker pack won't be returned along with the rest (eg if identifer isn't unique or stickers have
     *  invalid image dimensions)
     *
     *  - Parameter dict: JSON dictionary
     *  - Parameter completionHandler: called on the main queue
     */
    static func fetchStickerPacks(fromJSON dict: [String: Any], completionHandler: @escaping ([StickerPack]) -> Void) {
        queue.async {
            let packs: [[String: Any]] = dict["sticker_packs"] as! [[String: Any]]
            var stickerPacks: [StickerPack] = []
            var currentIdentifiers: [String: Bool] = [:]

            let iosAppStoreLink: String? = dict["ios_app_store_link"] as? String
            let androidAppStoreLink: String? = dict["android_play_store_link"] as? String
            Interoperability.iOSAppStoreLink = iosAppStoreLink != "" ? iosAppStoreLink : nil
            Interoperability.AndroidStoreLink = androidAppStoreLink != "" ? androidAppStoreLink : nil

            for pack in packs {
                let packName: String = pack["name"] as! String
                let packPublisher: String = pack["publisher"] as! String
                let packTrayImageFileName: String = pack["tray_image_file"] as! String

                var packPublisherWebsite: String? = pack["publisher_website"] as? String
                var packPrivacyPolicyWebsite: String? = pack["privacy_policy_website"] as? String
                var packLicenseAgreementWebsite: String? = pack["license_agreement_website"] as? String
                // If the strings are empty, consider them as nil
                packPublisherWebsite = packPublisherWebsite != "" ? packPublisherWebsite : nil
                packPrivacyPolicyWebsite = packPrivacyPolicyWebsite != "" ? packPrivacyPolicyWebsite : nil
                packLicenseAgreementWebsite = packLicenseAgreementWebsite != "" ? packLicenseAgreementWebsite : nil

                // Pack identifier has to be a valid string and be unique
                let packIdentifier: String? = pack["identifier"] as? String
                if packIdentifier != nil && currentIdentifiers[packIdentifier!] == nil {
                    currentIdentifiers[packIdentifier!] = true
                } else {
                    if let packIdentifier = packIdentifier {
                        fatalError("Missing identifier or a sticker pack already has the identifier \(packIdentifier).")
                    }

                    fatalError("\(packName) must have an identifier and it must be unique.")
                }

                let animatedStickerPack: Bool? = pack["animated_sticker_pack"] as? Bool

                var stickerPack: StickerPack?
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                do {
                    let fileURL = documentsDirectory.appendingPathComponent(packName).appendingPathComponent(packTrayImageFileName)
                    var filePath: String
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        filePath = fileURL.path
                    } else {
                        print("Warning: Sticker image file '\(packTrayImageFileName)' not found in Documents or bundle. Skipping this sticker.")
                        continue
                    }
                    let imageData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                    stickerPack = try StickerPack(identifier: packIdentifier!, name: packName, publisher: packPublisher, trayImagePNGData: imageData, publisherWebsite: packPublisherWebsite, privacyPolicyWebsite: packPrivacyPolicyWebsite, licenseAgreementWebsite: packLicenseAgreementWebsite)
                    /*stickerPack = try StickerPack(identifier: packIdentifier!, name: packName, publisher: packPublisher, trayImageFileName: packTrayImageFileName, animatedStickerPack: animatedStickerPack, publisherWebsite: packPublisherWebsite, privacyPolicyWebsite: packPrivacyPolicyWebsite, licenseAgreementWebsite: packLicenseAgreementWebsite)*/
                } catch StickerPackError.fileNotFound {
                    fatalError("\(packTrayImageFileName) not found.")
                } catch StickerPackError.emptyString {
                    fatalError("The name, identifier, and publisher strings can't be empty.")
                } catch StickerPackError.unsupportedImageFormat(let imageFormat) {
                    fatalError("\(packTrayImageFileName): \(imageFormat) is not a supported format.")
                } catch StickerPackError.invalidImage {
                    fatalError("Tray image file size is 0 KB.")
                } catch StickerPackError.imageTooBig(let imageFileSize, _) {
                    let roundedSize = round((Double(imageFileSize) / 1024) * 100) / 100;
                    fatalError("\(packTrayImageFileName): \(roundedSize) KB is bigger than the max tray image file size (\(Limits.MaxTrayImageFileSize / 1024) KB).")
                } catch StickerPackError.incorrectImageSize(let imageDimensions) {
                    fatalError("\(packTrayImageFileName): \(imageDimensions) is not compliant with tray dimensions requirements, \(Limits.TrayImageDimensions).")
                } catch StickerPackError.animatedImagesNotSupported {
                    fatalError("\(packTrayImageFileName) is an animated image. Animated images are not supported.")
                } catch StickerPackError.stringTooLong {
                    fatalError("Name, identifier, and publisher of sticker pack must be less than \(Limits.MaxCharLimit128) characters.")
                } catch {
                    fatalError(error.localizedDescription)
                }

                let stickers: [[String: Any]] = pack["stickers"] as! [[String: Any]]
                for sticker in stickers {
                    let emojis: [String]? = sticker["emojis"] as? [String]
                    let accessibilityText: String? = sticker["accessibility_text"] as? String

                    let filename = sticker["image_file"] as! String
                    do {
                       
                        let fileURL = documentsDirectory.appendingPathComponent(packName).appendingPathComponent(filename)
                        var filePath: String
                        if FileManager.default.fileExists(atPath: fileURL.path) {
                            filePath = fileURL.path
                        } else if let bundlePath = Bundle.main.path(forResource: filename, ofType: nil) {
                            filePath = bundlePath
                        } else {
                            print("Warning: Sticker image file '\(filename)' not found in Documents or bundle. Skipping this sticker.")
                            continue
                        }
                        let imageData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                        try stickerPack!.addSticker(
                            imageData: imageData,
                            type: .png,
                            emojis: emojis,
                            accessibilityText: accessibilityText
                        )
                    } catch StickerPackError.stickersNumOutsideAllowableRange {
                        fatalError("Sticker count outside the allowable limit (\(Limits.MaxStickersPerPack) stickers per pack).")
                    } catch StickerPackError.fileNotFound {
                        fatalError("\(filename) not found.")
                    } catch StickerPackError.unsupportedImageFormat(let imageFormat) {
                        fatalError("\(filename): \(imageFormat) is not a supported format.")
                    } catch StickerPackError.invalidImage {
                        fatalError("Image file size is 0 KB.")
                    } catch StickerPackError.imageTooBig(let imageFileSize, let animated) {
                        let roundedSize = round((Double(imageFileSize) / 1024) * 100) / 100;
                        let maxSize = animated ? Limits.MaxAnimatedStickerFileSize : Limits.MaxStaticStickerFileSize
                        fatalError("\(filename): \(roundedSize) KB is bigger than the max file size (\(maxSize / 1024) KB).")
                    } catch StickerPackError.incorrectImageSize(let imageDimensions) {
                        fatalError("\(filename): \(imageDimensions) is not compliant with sticker images dimensions, \(Limits.ImageDimensions).")
                    } catch StickerPackError.tooManyEmojis {
                        fatalError("\(filename) has too many emojis. \(Limits.MaxEmojisCount) is the maximum number.")
                    } catch StickerPackError.minFrameDurationTooShort(let minFrameDuration) {
                        let roundedDuration = round(minFrameDuration)
                        fatalError("\(filename): \(roundedDuration) ms is shorter than the min frame duration (\(Limits.MinAnimatedStickerFrameDurationMS) ms).")
                    } catch StickerPackError.totalAnimationDurationTooLong(let totalFrameDuration) {
                        let roundedDuration = round(totalFrameDuration)
                        fatalError("\(filename): \(roundedDuration) ms is longer than the max total animation duration (\(Limits.MaxAnimatedStickerTotalDurationMS) ms).")
                    } catch StickerPackError.animatedStickerPackWithStaticStickers {
                        fatalError("Animated sticker pack contains static stickers.")
                    } catch StickerPackError.staticStickerPackWithAnimatedStickers {
                        fatalError("Static sticker pack contains animated stickers.")
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }

                if stickers.count < Limits.MinStickersPerPack {
                  fatalError("Sticker count smaller that the allowable limit (\(Limits.MinStickersPerPack) stickers per pack).")
                }

                stickerPacks.append(stickerPack!)
            }

            DispatchQueue.main.async {
                completionHandler(stickerPacks)
            }
        }
    }

}
