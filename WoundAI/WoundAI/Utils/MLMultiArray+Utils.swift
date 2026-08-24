//
//  MLMultiArray+Utils.swift
//  WoundAI
//
//  Created by Vishal Vaghasiya on 17/04/26.
//

import Foundation
import CoreML
import UIKit

extension MLMultiArray {

    // MARK: - Shape Helpers

    var height: Int {
        return shape.count >= 2 ? shape[shape.count - 2].intValue : 0
    }

    var width: Int {
        return shape.count >= 1 ? shape.last!.intValue : 0
    }

    var channels: Int {
        return shape.count == 3 ? shape[0].intValue : 1
    }

    // MARK: - Index Access

    func value(atChannel c: Int = 0, x: Int, y: Int) -> Double {
        switch dataType {
        case .float32:
            let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(dataPointer))
            let index = offset(c: c, x: x, y: y)
            return Double(ptr[index])
        case .double:
            let ptr = UnsafeMutablePointer<Double>(OpaquePointer(dataPointer))
            let index = offset(c: c, x: x, y: y)
            return ptr[index]
        default:
            return 0
        }
    }

    private func offset(c: Int, x: Int, y: Int) -> Int {
        if shape.count == 3 {
            let h = height
            let w = width
            return c * h * w + y * w + x
        } else {
            return y * width + x
        }
    }

    // MARK: - Normalize (0...1)

    func normalized() -> [Float] {
        let count = self.count
        var result = [Float](repeating: 0, count: count)

        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(dataPointer))

        var minVal: Float = .greatestFiniteMagnitude
        var maxVal: Float = -.greatestFiniteMagnitude

        for i in 0..<count {
            let v = ptr[i]
            minVal = min(minVal, v)
            maxVal = max(maxVal, v)
        }

        let range = maxVal - minVal == 0 ? 1 : maxVal - minVal

        for i in 0..<count {
            result[i] = (ptr[i] - minVal) / range
        }

        return result
    }

    // MARK: - Convert to UIImage (Mask)

    func toMaskImage(threshold: Float = 0.5) -> UIImage? {
        let w = width
        let h = height

        guard w > 0, h > 0 else { return nil }

        var pixels = [UInt8](repeating: 0, count: w * h)

        for y in 0..<h {
            for x in 0..<w {
                let value = Float(self.value(atChannel: 0, x: x, y: y))
                let binary: UInt8 = value > threshold ? 255 : 0
                pixels[y * w + x] = binary
            }
        }

        return Self.createGrayscaleImage(width: w, height: h, pixels: pixels)
    }

    // MARK: - Heatmap (Optional)

    func toHeatmapImage() -> UIImage? {
        let w = width
        let h = height

        let normalizedValues = normalized()

        var pixels = [UInt8](repeating: 0, count: w * h * 4)

        for i in 0..<(w * h) {
            let value = normalizedValues[i]

            let r = UInt8(value * 255)
            let g: UInt8 = 0
            let b = UInt8((1 - value) * 255)

            pixels[i * 4 + 0] = r
            pixels[i * 4 + 1] = g
            pixels[i * 4 + 2] = b
            pixels[i * 4 + 3] = 255
        }

        return Self.createRGBAImage(width: w, height: h, pixels: pixels)
    }

    // MARK: - Image Builders

    private static func createGrayscaleImage(width: Int, height: Int, pixels: [UInt8]) -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceGray()

        guard let context = CGContext(
            data: UnsafeMutableRawPointer(mutating: pixels),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: 0
        ),
        let cgImage = context.makeImage() else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    private static func createRGBAImage(width: Int, height: Int, pixels: [UInt8]) -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: UnsafeMutableRawPointer(mutating: pixels),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ),
        let cgImage = context.makeImage() else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
