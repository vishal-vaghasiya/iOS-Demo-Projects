import Foundation

// MARK: - Root Response
struct PlantNetResponse: Codable {
    let bestMatch: String?
    let results: [PlantNetResult]
    let remainingIdentificationRequests: Int?
}

// MARK: - Result
struct PlantNetResult: Codable {
    let score: Double
    let species: PlantNetSpecies
}

// MARK: - Species
struct PlantNetSpecies: Codable {
    let scientificNameWithoutAuthor: String
    let scientificNameAuthorship: String?
    let scientificName: String?
    let commonNames: [String]?
}
