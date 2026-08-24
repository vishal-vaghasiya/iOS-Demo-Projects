//
//  OCRService.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import Vision
import UIKit

class OCRService {
    static let shared = OCRService()
    
    private init() {}
    
    /// Extracts text from a UIImage asynchronously using the Apple Vision framework.
    func performOCR(on image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "OCRService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid image format for text recognition."])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                var recognizedText = ""
                for observation in observations {
                    // Extract the top candidate with maximum confidence
                    if let candidate = observation.topCandidates(1).first {
                        recognizedText += candidate.string + "\n"
                    }
                }
                
                continuation.resume(returning: recognizedText.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            // Set high accuracy and default configuration options
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            // Vision processing must run off the main thread
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
