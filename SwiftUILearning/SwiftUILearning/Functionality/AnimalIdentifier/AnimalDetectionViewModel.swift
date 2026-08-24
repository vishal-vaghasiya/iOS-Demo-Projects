//
//  AnimalDetectionViewModel.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 29/10/25.
//

import PhotosUI
import SwiftUI

// MARK: - Model
struct AnimalInfo {
    let name: String
    let scientificName: String
    let description: String
    let imageURL: URL?
    let wikiURL: URL?
}

// MARK: - ViewModel
@MainActor
class AnimalDetectionViewModel: ObservableObject {
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet { loadImage() }
    }
    @Published var selectedImage: UIImage?
    @Published var isLoading = false
    @Published var result: AnimalInfo?
    @Published var errorMessage: String? = nil

    // MARK: - Image Picker Handling
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

    // MARK: - Main Animal Detection Flow
    func identifyAnimal() async {
        guard let _ = selectedImage else {
            errorMessage = "Please select an image before identifying."
            return
        }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            if let detectedName = try await identifyUsingImagga() {
                if let info = await fetchAnimalInfo(for: detectedName) {
                    result = info
                } else {
                    errorMessage = "No details found for \(detectedName)."
                }
            } else {
                errorMessage = "No animal detected in the image."
            }
        } catch {
            errorMessage = "Detection failed: \(error.localizedDescription)"
        }
    }

    // MARK: - DeepAI Image Recognition
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

    // MARK: - Fetch Animal Info (iNaturalist + Wikipedia)
    private func fetchAnimalInfo(for name: String) async -> AnimalInfo? {
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

            let commonName = record["preferred_common_name"] as? String ?? name
            let scientificName = record["name"] as? String ?? "Unknown"
            let wikiURLString = record["wikipedia_url"] as? String
            let wikiURL = wikiURLString != nil ? URL(string: wikiURLString!) : nil

            var imageURL: URL? = nil
            if
                let defaultPhoto = record["default_photo"] as? [String: Any],
                let medium = defaultPhoto["medium_url"] as? String {
                imageURL = URL(string: medium)
            }

            var description = "Scientific name: \(scientificName)"

            // MARK: - Wikipedia Summary
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
                    }
                }
            }

            return AnimalInfo(
                name: commonName,
                scientificName: scientificName,
                description: description,
                imageURL: imageURL,
                wikiURL: wikiURL
            )

        } catch {
            return nil
        }
    }
}
