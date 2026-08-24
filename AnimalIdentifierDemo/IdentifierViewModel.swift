import Foundation
import SwiftUI
import PhotosUI

struct Prediction {
    let name: String
    let confidence: Double
}

@MainActor
final class IdentifierViewModel: ObservableObject {
    // Put your PAT in a secure place. For demo only:
    private let clarifaiPAT = "YOUR_CLARIFAI_PAT" // <<-- replace
    private let modelID = "general-image-recognition" // public general model

    @Published var uiImage: UIImage?
    @Published var isLoading = false
    @Published var results: [Prediction] = []

    // Photo picker binding
    @Published var photoItem: PhotosPickerItem?

    func loadImageFromPicker() {
        guard let item = photoItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                self.uiImage = img
            }
        }
    }

    func identify() {
        guard let uiImage = uiImage else { return }
        Task {
            await performClarifaiRequest(image: uiImage)
        }
    }

    private func performClarifaiRequest(image: UIImage) async {
        isLoading = true
        results = []
        defer { isLoading = false }

        let resized = image.resize(to: CGSize(width: 800, height: 800))
        guard let jpeg = resized.jpegData(compressionQuality: 0.8) else { return }
        let b64 = jpeg.base64EncodedString()

        guard let url = URL(string: "https://api.clarifai.com/v2/models/\(modelID)/outputs") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("Key \(clarifaiPAT)", forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "inputs": [
                [
                    "data": [
                        "image": [
                            "base64": b64
                        ]
                    ]
                ]
            ]
        ]

        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            let (data, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                print("Clarifai HTTP error:", http.statusCode, String(data: data, encoding: .utf8) ?? "")
                return
            }
            if let top = try parseClarifaiResponse(data: data) {
                self.results = top
            }
        } catch {
            print("Request error:", error.localizedDescription)
        }
    }

    private func parseClarifaiResponse(data: Data) throws -> [Prediction]? {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        guard let outputs = json?["outputs"] as? [[String: Any]],
              let first = outputs.first,
              let d = first["data"] as? [String: Any],
              let concepts = d["concepts"] as? [[String: Any]] else {
            return nil
        }
        var preds: [Prediction] = []
        for c in concepts.prefix(10) {
            if let name = c["name"] as? String,
               let value = c["value"] as? Double {
                preds.append(Prediction(name: name, confidence: value))
            }
        }
        return preds
    }
}

extension UIImage {
    func resize(to target: CGSize) -> UIImage {
        let aspect = min(target.width / size.width, target.height / size.height)
        let newSize = CGSize(width: size.width * aspect, height: size.height * aspect)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
