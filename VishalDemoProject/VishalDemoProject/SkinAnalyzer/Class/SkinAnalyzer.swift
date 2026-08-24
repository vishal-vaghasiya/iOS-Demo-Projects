//
//  SkinAnalyzer.swift
//  VishalDemoProject
//
//  Created by Nexios Technologies on 14/07/25.
//

import UIKit
import Vision
import CoreML

class SkinAnalyzer {
    private let model: VNCoreMLModel

    init() throws {
        let skinModel = try SkinClassifier27(configuration: MLModelConfiguration()).model
        //let skinModel = try best(configuration: MLModelConfiguration()).model
        self.model = try VNCoreMLModel(for: skinModel)
    }

    func classify(image: UIImage, completion: @escaping ([(String, Float)]) -> Void) {
        guard let buffer = image.pixelBuffer(width: 224, height: 224) else {
            completion([])
            return
        }

        let request = VNCoreMLRequest(model: self.model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                completion([])
                return
            }

            let top = results.prefix(3).map { ($0.identifier, $0.confidence) }
            completion(top)
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [:])
        DispatchQueue.global().async {
            try? handler.perform([request])
        }
    }
}
