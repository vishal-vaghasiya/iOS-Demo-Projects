//
//  ImageCompressor.swift
//  GreenScanAI
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import UIKit

enum ImageCompressor {

    static func compress(
        image: UIImage,
        maxDimension: CGFloat = 1024,
        compressionQuality: CGFloat = 0.7
    ) -> Data? {

        let size = image.size
        let ratio = min(
            maxDimension / size.width,
            maxDimension / size.height,
            1
        )

        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return resizedImage.jpegData(compressionQuality: compressionQuality)
    }
}
