//
//  TissueClassifier.swift
//  WoundAI
//
//  Created by Vishal Vaghasiya on 17/04/26.
//

import CoreML
import UIKit

final class TissueClassifier {

    private let model: efficientnet_b4

    init() {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        model = try! efficientnet_b4(configuration: config)
    }

    func predict(image: UIImage) throws -> String {
        guard let resized = image.resize(to: CGSize(width: 224, height: 224)),
              let buffer = resized.toCVPixelBuffer() else {
            throw NSError(domain: "Conversion failed", code: -1)
        }

        let output = try model.prediction(image: buffer)
        let probs = output.var_2241

        let index = argmax(probs)
        print(index)
        let labels = [
            "granulation",
            "slough",
            "eschar",
            "epithelialization",
            "necrotic",
            "maceration"
        ]

        // Safety check to avoid index out of range
        if index < labels.count {
            return labels[index]
        } else {
            return "unknown"
        }
    }
    private func argmax(_ multiArray: MLMultiArray) -> Int {
        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(multiArray.dataPointer))

        var maxIndex = 0
        var maxValue = ptr[0]

        for i in 1..<multiArray.count {
            if ptr[i] > maxValue {
                maxValue = ptr[i]
                maxIndex = i
            }
        }

        return maxIndex
    }
}
