//
//  PlantDetectionViewModel.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 28/10/25.
//

import SwiftUI
import PhotosUI

struct PlantInfo {
    let name: String
    let scientificName: String
    let description: String
    let imageURL: URL?
    let wikiURL: URL?
}

@MainActor
class PlantDetectionViewModel: ObservableObject {
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet { loadImages() }
    }
    @Published var selectedImages: [UIImage] = []
    @Published var result: PlantInfo?
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let plantNetAPIKey = "2b10b2TGnZWq0Z6Jf4ebyNL5U"
    
    private func loadImages() {
        selectedImages.removeAll()
        for item in selectedItems {
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
    
    func identifyPlant() async {
        guard !selectedImages.isEmpty else {
            errorMessage = "Please select at least one image."
            return
        }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            let plantName = try await identifyUsingPlantNet()
            if let info = await fetchPlantInfo(for: plantName) {
                result = info
            } else {
                errorMessage = "Failed to fetch plant information."
            }
        } catch {
            errorMessage = "Plant identification failed: \(error.localizedDescription)"
        }
    }
    
    private func identifyUsingPlantNet() async throws -> String {
        guard let url = URL(string: "https://my-api.plantnet.org/v2/identify/all?api-key=\(plantNetAPIKey)") else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid PlantNet API URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        for (index, image) in selectedImages.prefix(4).enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body as Data
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API error: \(httpResponse.statusCode)"])
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let species = results.first?["species"] as? [String: Any],
              let scientificName = species["scientificNameWithoutAuthor"] as? String else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        return scientificName
    }
    
    private func fetchPlantInfo(for name: String) async -> PlantInfo? {
        // 1️⃣ Fetch from iNaturalist
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

            let commonName = record["preferred_common_name"] as? String ?? "Unknown Plant"
            let scientificName = record["name"] as? String ?? "N/A"
            let wikiURLString = record["wikipedia_url"] as? String
            let wikiURL = wikiURLString != nil ? URL(string: wikiURLString!) : nil

            var imageURL: URL? = nil
            if let defaultPhoto = record["default_photo"] as? [String: Any],
               let medium = defaultPhoto["medium_url"] as? String {
                imageURL = URL(string: medium)
            } else if let taxonPhotos = record["taxon_photos"] as? [[String: Any]],
                      let firstPhoto = taxonPhotos.first?["photo"] as? [String: Any],
                      let medium = firstPhoto["medium_url"] as? String {
                imageURL = URL(string: medium)
            }

            var description = "Scientific name: \(scientificName)"

            // 2️⃣ If Wikipedia URL exists, enrich with extra info
            if let wikiURLString = wikiURLString,
               let pageTitle = wikiURLString.components(separatedBy: "/").last?.replacingOccurrences(of: " ", with: "_"),
               let wikiSummaryURL = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(pageTitle)") {
                do {
                    let (wikiData, wikiResponse) = try await URLSession.shared.data(from: wikiSummaryURL)
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

            // 3️⃣ Combine both sources
            let info = PlantInfo(
                name: commonName.isEmpty ? scientificName : commonName,
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
    
    /*
     private func fetchPlantInfo(for name: String) async -> PlantInfo? {
         guard let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(query)") else {
             return nil
         }
         
         do {
             let (data, _) = try await URLSession.shared.data(from: url)
             if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let title = json["title"] as? String,
                let extract = json["extract"] as? String {
                 let imageURL = (json["thumbnail"] as? [String: Any])?["source"] as? String
                 return PlantInfo(
                     name: title,
                     description: extract,
                     imageURL: imageURL != nil ? URL(string: imageURL!) : nil
                 )
             }
         } catch {
             print("Wikimedia Error:", error)
         }
         return nil
     }
     */
}
