//
//  PlantScanViewModel.swift
//  GreenScanAI
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import SwiftUI
import Combine

@MainActor
final class PlantScanViewModel: ObservableObject {

    @Published var plant: PlantModel?
    @Published var disease: DiseaseModel?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let plantService = PlantNetService()
    private let diseaseService = KindwiseService()

    func scan(image: UIImage) {
        guard let imageData = ImageCompressor.compress(image: image) else {
            errorMessage = "Failed to process image"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let plantResult = try await plantService.identifyPlant(imageData: imageData)
                self.plant = plantResult

                let diseaseResult = try await diseaseService.detectDisease(
                    imageData: imageData,
                    plantName: plantResult.scientificName
                )
                self.disease = diseaseResult

                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
