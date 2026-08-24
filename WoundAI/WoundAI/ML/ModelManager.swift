//
//  ModelManager.swift
//  WoundAI
//
//  Created by Vishal Vaghasiya on 17/04/26.
//

import UIKit

final class ModelManager {
    static let shared = ModelManager()

    private let segmenter = SAM2Segmentation()
    private let classifier = TissueClassifier()

    func segment(image: UIImage) async throws -> UIImage {
        return try segmenter.predict(image: image)
    }

    func classify(patch: UIImage) throws -> String {
        return try classifier.predict(image: patch)
    }
}
