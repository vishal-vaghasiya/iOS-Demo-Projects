
//# Plant Disease Detection iOS Swift Implementation Examples
//
//## 1. Plant.id API Integration (Swift)
//
//### API Service Class

struct PlantIdentificationResponse: Codable {
    let access_token: String
    let secret: String
    let result: IdentificationResult
}

struct IdentificationResult: Codable {
    let is_plant: PlantProbability
    let is_healthy: HealthStatus
    let classification: Classification
    let disease: DiseaseDetection?
}

struct PlantProbability: Codable {
    let binary: Bool
    let probability: Double
}

struct HealthStatus: Codable {
    let binary: Bool
    let probability: Double
}

struct Classification: Codable {
    let suggestions: [PlantSuggestion]
}

struct DiseaseDetection: Codable {
    let suggestions: [DiseaseSuggestion]
}

struct PlantSuggestion: Codable {
    let name: String
    let probability: Double
    let details: PlantDetails?
}

struct DiseaseSuggestion: Codable {
    let name: String
    let probability: Double
    let details: DiseaseDetails?
}

struct PlantDetails: Codable {
    let common_names: [String]?
    let url: String?
    let description: String?
}

struct DiseaseDetails: Codable {
    let description: String?
    let treatment: String?
    let classification: String?
}

import Foundation
import UIKit

class PlantDiseaseAPIService {
    private let baseURL = "https://api.plant.id/v3/identification"
    private let apiKey = "YOUR_API_KEY_HERE"

    enum APIError: Error {
        case invalidURL
        case noData
        case decodingError
    }

    // MARK: - Data Models
    struct PlantIdentificationRequest: Codable {
        let images: [String]
        let plant_details: [String]
        let disease_details: [String]
        let latitude: Double?
        let longitude: Double?

        init(base64Images: [String], latitude: Double? = nil, longitude: Double? = nil) {
            self.images = base64Images
            self.plant_details = ["common_names", "url", "description"]
            self.disease_details = ["description", "treatment", "classification"]
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    // MARK: - API Methods
    func identifyPlantDisease(image: UIImage, completion: @escaping (Result<PlantIdentificationResponse, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(APIError.noData))
            return
        }

        let base64String = imageData.base64EncodedString()
        let requestBody = PlantIdentificationRequest(base64Images: [base64String])

        guard let url = URL(string: baseURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Api-Key")

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let result = try JSONDecoder().decode(PlantIdentificationResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(APIError.decodingError))
            }
        }.resume()
    }
}

//### View Controller Implementation

//```swift
import UIKit
import AVFoundation

class PlantDiseaseViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var treatmentTextView: UITextView!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let apiService = PlantDiseaseAPIService()
    private let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupImagePicker()
    }

    private func setupUI() {
        title = "Plant Disease Detector"
        resultLabel.text = "Take a photo to identify plant diseases"
        treatmentTextView.text = ""
        activityIndicator.hidesWhenStopped = true
    }

    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }

    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        showImagePickerOptions()
    }

    private func showImagePickerOptions() {
        let alert = UIAlertController(title: "Select Image", message: "Choose a source", preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true)
            })
        }

        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func analyzeImage(_ image: UIImage) {
        activityIndicator.startAnimating()
        resultLabel.text = "Analyzing image..."

        apiService.identifyPlantDisease(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.handleAPIResponse(result)
            }
        }
    }

    private func handleAPIResponse(_ result: Result<PlantIdentificationResponse, Error>) {
        switch result {
        case .success(let response):
            displayResults(response.result)
        case .failure(let error):
            showError(error)
        }
    }

    private func displayResults(_ result: IdentificationResult) {
        if !result.is_plant.binary {
            resultLabel.text = "This doesn't appear to be a plant"
            return
        }

        if result.is_healthy.binary {
            resultLabel.text = "Plant appears healthy!"
            confidenceLabel.text = ""//"Confidence: {String(format: "%.1f", result.is_healthy.probability * 100)}%"
            treatmentTextView.text = "No treatment needed - your plant looks great!"
        } else {
            // Display disease information
            if let disease = result.disease?.suggestions.first {
                resultLabel.text = "Disease detected: {disease.name}"
                confidenceLabel.text = ""//"Confidence: {String(format: "%.1f", disease.probability * 100)}%"

                var treatmentText = ""
                if let description = disease.details?.description {
                    treatmentText += "Description:\n{description}\n\n"
                }
                if let treatment = disease.details?.treatment {
                    treatmentText += "Treatment:\n{treatment}"
                }
                treatmentTextView.text = treatmentText
            }
        }

        // Also show plant identification if available
        if let plant = result.classification.suggestions.first {
            resultLabel.text! += "\nPlant: {plant.name}"
        }
    }

    private func showError(_ error: Error) {
        resultLabel.text = "Error: {error.localizedDescription}"
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PlantDiseaseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            imageView.image = image
            analyzeImage(image)
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

//## 2. Crop.health API Integration (Alternative)

class CropHealthAPIService {
    private let baseURL = "https://crop.kindwise.com/api/v1/identification"
    private let apiKey = "YOUR_CROP_HEALTH_API_KEY"

    struct CropIdentificationRequest: Codable {
        let images: [String]
        let modifiers: [String] = ["crops_fast", "similar_images"]
        let plant_details: [String] = ["common_names", "url"]
    }

    struct CropHealthResponse: Codable {
        let access_token: String
        let result: CropResult
    }

    struct CropResult: Codable {
        let classification: CropClassification
        let is_healthy: HealthProbability
        let disease: CropDisease?
    }

    struct CropClassification: Codable {
        let suggestions: [CropSuggestion]
    }

    struct CropSuggestion: Codable {
        let name: String
        let probability: Double
        let details: CropDetails?
    }

    struct CropDetails: Codable {
        let common_names: [String]?
        let url: String?
    }

    struct HealthProbability: Codable {
        let binary: Bool
        let probability: Double
    }

    struct CropDisease: Codable {
        let suggestions: [DiseaseInfo]
    }

    struct DiseaseInfo: Codable {
        let name: String
        let probability: Double
        let details: DiseaseDescription?
    }

    struct DiseaseDescription: Codable {
        let description: String?
        let treatment: String?
        let common_names: [String]?
    }

    func identifyCropDisease(image: UIImage, completion: @escaping (Result<CropHealthResponse, Error>) -> Void) {
        // Implementation similar to Plant.id but using crop.health endpoint
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(PlantDiseaseAPIService.APIError.noData))
            return
        }

        let base64String = imageData.base64EncodedString()
        let requestBody = CropIdentificationRequest(images: [base64String])

        guard let url = URL(string: baseURL) else {
            completion(.failure(PlantDiseaseAPIService.APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Api-Key")

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(PlantDiseaseAPIService.APIError.noData))
                return
            }

            do {
                let result = try JSONDecoder().decode(CropHealthResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(PlantDiseaseAPIService.APIError.decodingError))
            }
        }.resume()
    }
}

//## 3. Usage Guidelines

//### Camera Permissions (Info.plist)
/*
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos of plants for disease detection</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to analyze plant images</string>
*/

/*### Best Practices
 1. Always compress images before sending to API (0.7-0.8 quality)
 2. Handle network errors gracefully
 3. Show loading indicators during API calls
 4. Cache results when appropriate
 5. Implement offline mode with Core ML for basic detection
 6. Add proper error handling and user feedback
 
 ### Performance Optimization
 - Resize images to optimal size (usually 1024x1024 max)
 - Use background queues for API calls
 - Implement request timeout handling
 - Consider batch processing for multiple images
 */
