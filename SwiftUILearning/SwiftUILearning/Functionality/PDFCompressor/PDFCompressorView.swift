//
//  PDFCompressorView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 27/10/25.
//

import SwiftUI

import UniformTypeIdentifiers
import PDFKit

struct PDFCompressorView: View {
    @State private var selectedURLs: [URL] = []
    @State private var compressedPDFs: [(original: URL, compressed: URL, originalSize: Int, compressedSize: Int)] = []
    @State private var showPreview = false
    @State private var isCompressing = false
    @State private var pdfPickerDelegate: PDFPickerDelegate?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("PDF Compressor")
                    .font(.title)
                    .bold()
                    .padding(.top)

                Button(action: selectPDFs) {
                    Label("Select PDFs", systemImage: "doc.on.doc")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                if isCompressing {
                    ProgressView("Compressing PDFs...")
                        .padding()
                }

                Button(action: compressPDFs) {
                    Label("Compress Selected PDFs", systemImage: "arrow.down.circle")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedURLs.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedURLs.isEmpty)
                .padding(.horizontal)

                NavigationLink(
                    destination: PDFPreviewScreen(compressedPDFs: compressedPDFs),
                    isActive: $showPreview
                ) {
                    EmptyView()
                }
                .hidden()

                Spacer()
            }
            .padding()
            .navigationTitle("PDF Compressor")
        }
    }

    // MARK: - File Selection
    func selectPDFs() {
        let panel = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        panel.allowsMultipleSelection = true

        let delegate = PDFPickerDelegate { urls in
            self.selectedURLs = urls
        }
        self.pdfPickerDelegate = delegate
        panel.delegate = delegate

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(panel, animated: true)
        }
    }

    // MARK: - PDF Compression
    func compressPDFs() {
        guard !selectedURLs.isEmpty else { return }
        isCompressing = true
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [(URL, URL, Int, Int)] = []

            for url in selectedURLs {
                if let compressedURL = compressPDF(inputURL: url) {
                    let originalSize = (try? Data(contentsOf: url).count) ?? 0
                    let compressedSize = (try? Data(contentsOf: compressedURL).count) ?? 0
                    results.append((url, compressedURL, originalSize, compressedSize))
                }
            }

            DispatchQueue.main.async {
                self.compressedPDFs = results
                self.isCompressing = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.showPreview = true
                }
            }
        }
    }

    func compressPDF(inputURL: URL) -> URL? {
        // Copy PDF (simulate compression but keep quality)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
        guard let pdfDoc = PDFDocument(url: inputURL) else { return nil }
        pdfDoc.write(to: outputURL)
        return outputURL
    }
}

// MARK: - PDFPickerDelegate
class PDFPickerDelegate: NSObject, UIDocumentPickerDelegate {
    var completion: ([URL]) -> Void
    init(completion: @escaping ([URL]) -> Void) {
        self.completion = completion
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        completion(urls)
    }
}

#Preview {
    PDFCompressorView()
}
