//
//  BirdDetectionViewModel.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 28/10/25.
//

import PhotosUI
import SwiftUI

struct BirdInfo {
    let name: String
    let scientificName: String
    let description: String
    let imageURL: URL?
    let wikiURL: URL?
}

@MainActor
class BirdDetectionViewModel: ObservableObject {
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet { loadImage() }
    }
    @Published var selectedImage: UIImage?
    @Published var isLoading = false
    @Published var result: BirdInfo?
    @Published var errorMessage: String? = nil
    
    private func loadImage() {
        selectedImage = nil
        guard let item = selectedItems.first else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = image
                }
            }
        }
    }

    func identifyBird() async {
        guard let _ = selectedImage else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // 1️⃣ Upload to Nyckel API (JSON body key changed from "image" to "data" to match API requirement)
            let birdName = try await identifyUsingImagga()
            // 2️⃣ Get description from Wikimedia API
            if let info = await fetchBirdInfo(for: birdName ?? "Golden Chlorophonia") {
                result = info
            } else {
                errorMessage = "Failed to fetch bird information."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func identifyUsingImagga() async throws -> String? {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "AnimalDetection", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No image data available"])
        }

        let url = URL(string: "https://api.imagga.com/v2/tags")!  // Example endpoint
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Set your API credentials. For Imagga typically “Authorization: Basic <base64-encoded key>”
        let apiKey = "acc_6e0328035d7c42d"
        let apiSecret = "77baf045b3dbc9b40083a32b57110c5c"
        let credentials = "\(apiKey):\(apiSecret)"
        guard let credentialData = credentials.data(using: .utf8) else {
            throw URLError(.userAuthenticationRequired)
        }
        let base64Credentials = credentialData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"animal.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "No message"
            throw NSError(
                domain: "AnimalDetection",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "API error: \(httpResponse.statusCode). \(msg)"]
            )
        }

        // parse JSON response for top tag/label
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let result = json["result"] as? [String: Any],
           let tags = result["tags"] as? [[String: Any]],
           let firstTag = tags.first,
           let tag = firstTag["tag"] as? [String: Any],
           let label = tag["en"] as? String {
            return label
        } else {
            throw NSError(domain: "AnimalDetection", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to parse recognition response"])
        }
    }
    
    // MARK: - Bird Identification (Nyckel)
//    private func identifyUsingNyckel() async throws -> String? {
//        guard let image = selectedImage,
//              let imageData = image.jpegData(compressionQuality: 0.8) else {
//            throw NSError(domain: "BirdIdentifier", code: -1, userInfo: [NSLocalizedDescriptionKey: "No image data available"])
//        }
//        let token = try await fetchNyckelAccessToken()
//        guard let url = URL(string: "https://www.nyckel.com/v1/functions/bird-identifier/invoke") else {
//            throw URLError(.badURL)
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let base64Image = imageData.base64EncodedString()
//        let base64WithPrefix = "data:image/jpeg;base64," + base64Image
//        let jsonBody: [String: Any] = ["data": base64WithPrefix]
//        request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw URLError(.badServerResponse)
//        }
//        guard httpResponse.statusCode == 200 else {
//            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
//            throw NSError(domain: "NyckelBirdIdentifier", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
//        }
//
//        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//           let name = json["labelName"] as? String,
//           let confidence = json["confidence"] as? Double {
//            if confidence > 0.3 {
//                return name
//            } else {
//                throw NSError(domain: "NyckelBirdIdentifier", code: -1, userInfo: [NSLocalizedDescriptionKey: "Confidence too low: \(confidence)"])
//            }
//        } else {
//            throw NSError(domain: "NyckelBirdIdentifier", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to parse API response"])
//        }
//    }

    /// Fetches an access token from Nyckel API for authentication.
    private func fetchNyckelAccessToken() async throws -> String {
        let url = URL(string: "https://www.nyckel.com/connect/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let clientId = "yroabjo8u89vsoz4hy8y2u0ix0bb36wq"
        let clientSecret = "p62y7f2z90k4ps0jwcj8qfd4r6cb7c4nbi6lm0w1v9p1avs5zsfrno0atx713rsw"
        let bodyParams = "grant_type=client_credentials&client_id=\(clientId)&client_secret=\(clientSecret)"
        request.httpBody = bodyParams.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "NyckelAuth", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: message])
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let token = json?["access_token"] as? String {
            return token
        } else {
            throw NSError(domain: "NyckelAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not found in response"])
        }
    }

    // MARK: - Wikimedia Info Fetch & iNaturalist Combined

    private func fetchBirdInfo(for name: String) async -> BirdInfo? {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        guard let url = URL(string: "https://api.inaturalist.org/v1/search?q=\(encoded)&sources=taxa") else {
            return nil
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }

            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let results = json["results"] as? [[String: Any]],
                let first = results.first,
                let record = first["record"] as? [String: Any]
            else {
                return nil
            }

            let commonName = record["preferred_common_name"] as? String ?? "Unknown Bird"
            let scientificName = record["name"] as? String ?? "N/A"
            let wikiURLString = record["wikipedia_url"] as? String
            let wikiURL = wikiURLString != nil ? URL(string: wikiURLString!) : nil

            var imageURL: URL? = nil
            if
                let defaultPhoto = record["default_photo"] as? [String: Any],
                let medium = defaultPhoto["medium_url"] as? String {
                imageURL = URL(string: medium)
            } else if
                let taxonPhotos = record["taxon_photos"] as? [[String: Any]],
                let firstPhoto = taxonPhotos.first?["photo"] as? [String: Any],
                let medium = firstPhoto["medium_url"] as? String {
                imageURL = URL(string: medium)
            }

            var description = "Scientific name: \(scientificName)"

            // If Wikipedia URL exists, fetch additional details
            if let wikiURLString = wikiURLString,
               let pageTitle = wikiURLString.components(separatedBy: "/").last?
                   .replacingOccurrences(of: " ", with: "_") {
                let wikiSummaryURL = "https://en.wikipedia.org/api/rest_v1/page/summary/\(pageTitle)"
                if let wikiURL = URL(string: wikiSummaryURL) {
                    do {
                        let (wikiData, wikiResponse) = try await URLSession.shared.data(from: wikiURL)
                        if (wikiResponse as? HTTPURLResponse)?.statusCode == 200,
                           let wikiJson = try JSONSerialization.jsonObject(with: wikiData) as? [String: Any] {
                            if let extract = wikiJson["extract"] as? String, !extract.isEmpty {
                                description = extract
                            }
                            if imageURL == nil,
                               let imageURLString = (wikiJson["thumbnail"] as? [String: Any])?["source"] as? String {
                                imageURL = URL(string: imageURLString)
                            }
                        }
                    } catch {
                        // Ignore Wikipedia fetch errors silently
                    }
                }
            }

            let info = BirdInfo(
                name: commonName,
                scientificName: scientificName,
                description: description,
                imageURL: imageURL,
                wikiURL: wikiURL
            )

            return info
        } catch {
            return nil
        }
    }
}
