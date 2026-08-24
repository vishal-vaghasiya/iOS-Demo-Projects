//
//  PlantNetService.swift
//  GreenScanAI
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import Foundation

final class PlantNetService {

    func identifyPlant(imageData: Data) async throws -> PlantModel {

        guard !APIKeys.plantNet.isEmpty else {
            throw URLError(.userAuthenticationRequired)
        }

        let url = URL(
            string: "https://my-api.plantnet.org/v2/identify/all?api-key=\(APIKeys.plantNet)"
        )!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"images\"; filename=\"plant.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        // 🔍 Debug: Print raw PlantNet response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🌱 PlantNet Raw Response:")
            print(jsonString)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode(
            PlantNetResponse.self,
            from: data
        )

        guard let bestMatch = decodedResponse.results.first else {
            throw NSError(
                domain: "PlantNet",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "No plant identified"]
            )
        }

        return PlantModel(
            commonName: bestMatch.species.commonNames?.first ?? "Unknown",
            scientificName: bestMatch.species.scientificNameWithoutAuthor,
            confidence: bestMatch.score,
            fullScientificName: bestMatch.species.scientificName,
            remainingRequests: decodedResponse.remainingIdentificationRequests
        )
    }
}
