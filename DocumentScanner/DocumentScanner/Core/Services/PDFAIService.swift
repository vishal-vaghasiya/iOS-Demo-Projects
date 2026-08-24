//
//  PDFAIService.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Foundation
import PDFKit

enum PDFAIToolMode {
    case summary
    case keyPoints
    case notes
    case questionAnswering

    var operationName: String {
        switch self {
        case .summary:
            return "PDF Summary"
        case .keyPoints:
            return "Extract Key Points"
        case .notes:
            return "Generate Notes"
        case .questionAnswering:
            return "Question Answering"
        }
    }
}

struct PDFAIResult {
    let text: String
    let operationName: String
}

final class PDFAIService {
    static let shared = PDFAIService()

    private let stopWords: Set<String> = [
        "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "has", "have", "in", "is", "it",
        "its", "of", "on", "or", "that", "the", "this", "to", "was", "were", "will", "with", "you", "your"
    ]

    private init() {}

    func processPDF(url: URL, mode: PDFAIToolMode, question: String?) async throws -> PDFAIResult {
        let text = try await extractText(from: url)

        guard !text.isEmpty else {
            throw aiError("No selectable text was found in this PDF.")
        }

        let output: String
        switch mode {
        case .summary:
            output = generateSummary(from: text)
        case .keyPoints:
            output = extractKeyPoints(from: text)
        case .notes:
            output = generateNotes(from: text)
        case .questionAnswering:
            let trimmedQuestion = question?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !trimmedQuestion.isEmpty else {
                throw aiError("Enter a question before running Question Answering.")
            }
            output = answer(question: trimmedQuestion, from: text)
        }

        return PDFAIResult(text: output, operationName: mode.operationName)
    }

    private func extractText(from url: URL) async throws -> String {
        try await Task.detached(priority: .userInitiated) {
            guard let document = PDFDocument(url: url) else {
                throw self.aiError("Could not open the selected PDF.")
            }

            guard !document.isLocked else {
                throw self.aiError("Unlock this PDF before using PDF AI tools.")
            }

            var pageTexts: [String] = []
            pageTexts.reserveCapacity(document.pageCount)

            for index in 0..<document.pageCount {
                guard let page = document.page(at: index),
                      let pageText = page.string?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !pageText.isEmpty else {
                    continue
                }
                pageTexts.append("Page \(index + 1)\n\(pageText)")
            }

            return pageTexts.joined(separator: "\n\n")
        }.value
    }

    private func generateSummary(from text: String) -> String {
        let ranked = rankedSentences(from: text, limit: 6)
        let summary = ranked.map(\.sentence).joined(separator: "\n\n")

        return """
        PDF Summary

        \(summary)
        """
    }

    private func extractKeyPoints(from text: String) -> String {
        let ranked = rankedSentences(from: text, limit: 10)
        let bullets = ranked.map { "- \($0.sentence)" }.joined(separator: "\n")

        return """
        Extracted Key Points

        \(bullets)
        """
    }

    private func generateNotes(from text: String) -> String {
        let summary = rankedSentences(from: text, limit: 4).map(\.sentence)
        let keyPoints = rankedSentences(from: text, limit: 8).map { "- \($0.sentence)" }
        let keywords = topKeywords(in: text, limit: 12).joined(separator: ", ")

        return """
        Generated Notes

        Overview
        \(summary.joined(separator: "\n\n"))

        Key Ideas
        \(keyPoints.joined(separator: "\n"))

        Important Terms
        \(keywords)

        Review Prompts
        - What is the main purpose of this document?
        - Which details support the key ideas above?
        - What actions, decisions, or follow-ups are implied by the document?
        """
    }

    private func answer(question: String, from text: String) -> String {
        let questionKeywords = Set(keywords(in: question))
        let candidates = paragraphs(from: text).map { paragraph in
            (paragraph: paragraph, score: score(paragraph, using: questionKeywords))
        }
        .sorted { $0.score > $1.score }

        let strongest = candidates.prefix(3).filter { $0.score > 0 }
        guard !strongest.isEmpty else {
            return """
            Question
            \(question)

            Answer
            I could not find a direct answer in the selectable PDF text.
            """
        }

        let answerText = strongest.map { $0.paragraph }.joined(separator: "\n\n")
        return """
        Question
        \(question)

        Answer
        \(answerText)
        """
    }

    private func rankedSentences(from text: String, limit: Int) -> [(sentence: String, score: Int)] {
        let allSentences = sentences(from: text)
        let keywordCounts = frequencyMap(for: text)

        return allSentences.map { sentence in
            (sentence: sentence, score: score(sentence, using: Set(keywordCounts.keys)))
        }
        .sorted {
            let lhsFrequency = sentenceFrequency($0.sentence, keywordCounts: keywordCounts)
            let rhsFrequency = sentenceFrequency($1.sentence, keywordCounts: keywordCounts)
            return lhsFrequency == rhsFrequency ? $0.sentence.count > $1.sentence.count : lhsFrequency > rhsFrequency
        }
        .prefix(limit)
        .map { $0 }
    }

    private func sentenceFrequency(_ sentence: String, keywordCounts: [String: Int]) -> Int {
        keywords(in: sentence).reduce(0) { total, word in
            total + (keywordCounts[word] ?? 0)
        }
    }

    private func score(_ text: String, using keywords: Set<String>) -> Int {
        self.keywords(in: text).reduce(0) { total, word in
            total + (keywords.contains(word) ? 1 : 0)
        }
    }

    private func topKeywords(in text: String, limit: Int) -> [String] {
        frequencyMap(for: text)
            .sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
            .prefix(limit)
            .map(\.key)
    }

    private func frequencyMap(for text: String) -> [String: Int] {
        keywords(in: text).reduce(into: [:]) { counts, word in
            counts[word, default: 0] += 1
        }
    }

    private func keywords(in text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 && !stopWords.contains($0) && Int($0) == nil }
    }

    private func sentences(from text: String) -> [String] {
        text.replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 35 }
            .map { $0 + "." }
    }

    private func paragraphs(from text: String) -> [String] {
        text.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 25 }
    }

    private func aiError(_ message: String) -> NSError {
        NSError(domain: "PDFAIService", code: 400, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
