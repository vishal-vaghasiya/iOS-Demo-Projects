//
//  ImageContentModerator.swift
//  VishalDemoProject
//
//  Created by Nexios Technologies on 30/12/25.
//

import UIKit
import Vision

final class ImageContentModerator {

    enum Decision {
        case allow
        case warn(message: String)
        case block(message: String)
    }

    // MARK: - Public API
    func analyze(
        image: UIImage,
        watchBrand: String,
        completion: @escaping (Decision) -> Void
    ) {

        guard let cgImage = image.cgImage else {
            completion(.allow)
            return
        }

        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let self = self else { return }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let extractedText = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ")

            let decision = self.evaluate(
                text: extractedText,
                watchBrand: watchBrand
            )
            completion(decision)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    // MARK: - Rule Engine
    private func contactSignalCount(text: String) -> Int {

        let normalized = text
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()

        if isWarrantyCard(text: normalized) {
            return 0
        }

        let patterns = [
            "\\+[1-9][0-9]{6,14}",        // International phone numbers (+countrycode)
            "(?<!\\d)[0-9]{10}(?!\\d)",  // Strict 10-digit phone only (not part of longer serial/model)
            "[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}", // Email
            "whatsapp",
            "instagram",
            "facebook"
        ]

        return patterns.filter {
            normalized.range(of: $0, options: .regularExpression) != nil
        }.count
    }

    private func containsDisallowedCompanyName(
        text: String,
        allowedBrand: String
    ) -> Bool {

        let normalizedText = text.lowercased()
        let allowed = allowedBrand.lowercased()

        // Allow watch brand text and official brand-owned domains (including subdomains)
        let normalizedBrand = allowed
            .replacingOccurrences(of: " ", with: "")
            .lowercased()

        if normalizedText.contains(allowed) ||
           normalizedText.contains(normalizedBrand) ||
           normalizedText.contains("\(normalizedBrand).com") {
            return false
        }

        // Warranty / service cards should not be treated as company promotion
        if isWarrantyCard(text: normalizedText) {
            return false
        }

        let businessKeywords = [
            "ltd",
            "llc",
            "pvt",
            "private",
            "company",
            "co.",
            "world",
            "hub",
            "store",
            "shop",
            "platform",
            "solutions",
            "services",
            "marketing"
        ]

        return businessKeywords.contains {
            normalizedText.contains($0)
        }
    }

    private func evaluate(
        text: String,
        watchBrand: String
    ) -> Decision {

        let lowerText = text.lowercased()
        let contactCount = contactSignalCount(text: lowerText)

        // 1️⃣ Multiple contact signals → Visiting card → BLOCK
        if contactCount >= 2 {
            return .block(
                message: "Images containing personal or business contact information are not allowed."
            )
        }

        // 2️⃣ Disallowed company / brand name (not the watch brand)
        if containsDisallowedCompanyName(
            text: lowerText,
            allowedBrand: watchBrand
        ) {
            return .block(
                message: "Only the watch brand information is allowed in images."
            )
        }

        // 3️⃣ Warranty card → ALLOW
        if isWarrantyCard(text: lowerText) {
            return .allow
        }

        // 4️⃣ Single weak contact signal → WARN
        if contactCount == 1 {
            return .warn(
                message: "Please ensure the image does not contain personal contact details."
            )
        }

        // 5️⃣ Default → ALLOW
        return .allow
    }

    // MARK: - Warranty Detection
    private func isWarrantyCard(text: String) -> Bool {
        let warrantyKeywords = [
            "warranty",
            "guarantee",
            "serial",
            "model",
            "reference",
            "ref no",
            "purchase date",
            "valid till",
            "invoice",
            "year warranty",
            "international warranty"
        ]

        return warrantyKeywords.contains { text.contains($0) }
    }

    // MARK: - Visiting Card Detection
    private func isVisitingCard(text: String) -> Bool {

        let normalized = text
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()

        let strongPatterns = [
            "\\+[1-9][0-9]{6,14}",        // International phone numbers
            "[0-9]{10}",                 // Local numbers
            "[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}", // Email
            "whatsapp",
            "callme",
            "contact",
            "instagram",
            "facebook"
        ]

        return strongPatterns.contains {
            normalized.range(of: $0, options: .regularExpression) != nil
        }
    }

    // MARK: - Weak Signals (Optional Warning)
    private func containsWeakContactHints(text: String) -> Bool {
        let weakKeywords = [
            "phone",
            "mobile",
            "reach us",
            "dm"
        ]

        return weakKeywords.contains { text.contains($0) }
    }
}
