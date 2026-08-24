//
//  AnimalIdentifierService.swift
//  AnimalIdentifierDemo
//
//  Created by Vishal on 2025-08-18.
//

import Foundation
import UIKit

// MARK: - IdentifyResult Model
struct IdentifyResult {
    let label: String
    let confidence: Double
    let shortDescription: String?
    let fullDescription: String?
    let scientificName: String?
    let taxonomy: [String: String]?
    let wikiImageURL: String?   // Wikipedia/Wikidata image URL
}

// MARK: - AnimalIdentifierService
class AnimalIdentifierService {
    
    // MARK: - Public API
    func identifyAnimal(image: UIImage, completion: @escaping (IdentifyResult?) -> Void) {
        // Step 1: Detect label with Google Vision (stubbed for now)
        detectAnimalLabel(image: image) { label, confidence in
            guard let label = label else {
                completion(nil)
                return
            }
            
            // Step 2: Fetch description + taxonomy + image from Wikipedia
            self.fetchWikipediaInfo(for: label) { shortDesc, fullDesc, sciName, taxonomy, wikiImageURL in
                let result = IdentifyResult(
                    label: label,
                    confidence: confidence ?? 0.0,
                    shortDescription: shortDesc,
                    fullDescription: fullDesc,
                    scientificName: sciName,
                    taxonomy: taxonomy,
                    wikiImageURL: wikiImageURL
                )
                completion(result)
            }
        }
    }
    
    // MARK: - Google Vision API (stub for demo)
    private func detectAnimalLabel(image: UIImage, completion: @escaping (String?, Double?) -> Void) {
        // TODO: Replace with real Vision API call
        // For demo, pretend every image is a Tiger
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion("Tiger", 0.945)
        }
    }
    
    // MARK: - Wikipedia API
    private func fetchWikipediaInfo(
        for query: String,
        completion: @escaping (String?, String?, String?, [String:String]?, String?) -> Void
    ) {
        
        let urlStr = "https://en.wikipedia.org/api/rest_v1/page/summary/\(query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
        
        guard let url = URL(string: urlStr) else {
            completion(nil, nil, nil, nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(nil, nil, nil, nil, nil)
                return
            }
            
            let shortDesc = json["description"] as? String
            let fullDesc = json["extract"] as? String
            let wikiImageURL = (json["thumbnail"] as? [String: Any])?["source"] as? String
            
            // 🐯 Example: enrich with mock taxonomy (extend with Wikidata for real data)
            let sciName = query == "Tiger" ? "Panthera tigris" : nil
            let taxonomy: [String:String]? = query == "Tiger" ? [
                "Kingdom": "Animalia",
                "Phylum": "Chordata",
                "Class": "Mammalia",
                "Order": "Carnivora",
                "Family": "Felidae",
                "Genus": "Panthera",
                "Species": "Panthera tigris"
            ] : nil
            
            completion(shortDesc, fullDesc, sciName, taxonomy, wikiImageURL)
        }.resume()
    }
}
