//
//  SAM2Segmentation.swift (Now using YOLO)
//  WoundAI
//

import UIKit
import CoreML

final class SAM2Segmentation {

    private let model: yolov8n_seg

    init() {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        model = try! yolov8n_seg(configuration: config)
    }

    func predict(image: UIImage) throws -> UIImage {

        guard let resized = image.resize(to: CGSize(width: 640, height: 640)),
              let buffer = resized.toCVPixelBuffer() else {
            throw NSError(domain: "Image conversion failed", code: -1)
        }

        let output = try model.prediction(image: buffer)

        // ⚠️ IMPORTANT: Confirm output name in yolov8n_seg.swift
        let maskArray = output.var_1050

        return maskArray.toMaskImage(threshold: 0.5) ?? image
    }
}
