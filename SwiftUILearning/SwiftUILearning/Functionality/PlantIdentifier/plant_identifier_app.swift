// PlantIdentifierApp.swift
// SwiftUI app to identify plants and diseases from an image using Plant.id API

import SwiftUI
import Combine

// MARK: - Model
struct PlantIdentificationResult: Codable {
    let suggestions: [Suggestion]
    struct Suggestion: Codable {
        let plantName: String
        let probability: Double
        let plantDetails: PlantDetails
        let diseases: [Disease]?
    }
    struct PlantDetails: Codable {
        let commonNames: [String]?
        let wikiDescription: Description?
        struct Description: Codable {
            let value: String?
        }
    }
    struct Disease: Codable {
        let name: String
        let description: String
        let treatment: String?
    }
}

// MARK: - ViewModel
class PlantIdentifierManager: ObservableObject {
    @Published var result: PlantIdentificationResult?
    @Published var isLoading = false
    @Published var error: String?

    private let apiKey = "YOUR_API_KEY"
    private let apiURL = "https://api.plant.id/v2/identify"

    func identifyPlant(from image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() else {
            self.error = "Invalid image"
            return
        }

        let payload: [String: Any] = [
            "images": [imageData],
            "modifiers": ["crops_fast", "similar_images"],
            "plant_language": "en",
            "plant_details": ["common_names", "url", "wiki_description"],
            "disease_details": ["description", "treatment"]
        ]

        guard let requestData = try? JSONSerialization.data(withJSONObject: payload) else {
            self.error = "Payload error"
            return
        }

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Api-Key")
        request.httpBody = requestData

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                guard let data = data else {
                    self.error = "No data received"
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(PlantIdentificationResult.self, from: data)
                    self.result = decoded
                } catch {
                    self.error = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// MARK: - SwiftUI View
struct PlantIdentifierView: View {
    @StateObject var manager = PlantIdentifierManager()
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                }
                
                Button("Select Image") {
                    showImagePicker = true
                }
                .padding()

                if manager.isLoading {
                    ProgressView("Identifying...")
                } else if let result = manager.result {
                    List(result.suggestions, id: \.plantName) { suggestion in
                        Section(header: Text(suggestion.plantName)) {
                            if let desc = suggestion.plantDetails.wikiDescription?.value {
                                Text(desc)
                            }
                            if let diseases = suggestion.diseases {
                                ForEach(diseases, id: \.name) { disease in
                                    VStack(alignment: .leading) {
                                        Text("\(disease.name)").bold()
                                        Text(disease.description)
                                        if let treatment = disease.treatment {
                                            Text("Treatment: \(treatment)")
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else if let error = manager.error {
                    Text("Error: \(error)").foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage) { image in
                    manager.identifyPlant(from: image)
                }
            }
            .navigationTitle("Plant Identifier")
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let completion: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.completion(image)
            }
            picker.dismiss(animated: true)
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
