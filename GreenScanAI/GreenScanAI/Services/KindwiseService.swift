//
//  KindwiseService.swift
//  GreenScanAI
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import Foundation

final class KindwiseService {

    func detectDisease(
        imageData: Data,
        plantName: String
    ) async throws -> DiseaseModel {

        let url = URL(string: "https://api.kindwise.com/v1/health")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIKeys.kindwise)", forHTTPHeaderField: "Authorization")

        // Demo response
        return DiseaseModel(
            name: "Leaf Spot",
            confidence: 0.88,
            treatment: "Use fungicide and avoid overwatering."
        )
    }
}
