//
//  PlantModel.swift
//  GreenScanAI
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

struct PlantModel {
    let commonName: String
    let scientificName: String
    let confidence: Double

    // Optional metadata from PlantNet
    let fullScientificName: String?
    let remainingRequests: Int?
}
