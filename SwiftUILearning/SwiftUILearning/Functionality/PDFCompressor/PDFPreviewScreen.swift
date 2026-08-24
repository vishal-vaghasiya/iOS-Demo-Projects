//
//  PDFPreviewScreen.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 27/10/25.
//
import SwiftUI

import UniformTypeIdentifiers
import PDFKit

// MARK: - PDF Preview Screen
struct PDFPreviewScreen: View {
    @Environment(\.dismiss) private var dismiss
    var compressedPDFs: [(original: URL, compressed: URL, originalSize: Int, compressedSize: Int)]

    var body: some View {
        TabView {
            ForEach(compressedPDFs, id: \.compressed) { item in
                VStack(spacing: 10) {
                    GeometryReader { geometry in
                        PDFKitView(url: item.compressed)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                    }
                    .frame(height: 500)

                    Text("Before: \(formatSize(item.originalSize))  →  After: \(formatSize(item.compressedSize))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                .padding()
                .onTapGesture {
                    showSinglePDF(item.compressed)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())

        HStack(spacing: 20) {
            Button(action: saveToDocuments) {
                Label("Save", systemImage: "folder")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: shareAll) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: { dismiss() }) {
                Label("Home", systemImage: "house.fill")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }

    func saveToDocuments() {
        for item in compressedPDFs {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destURL = documentsURL.appendingPathComponent(item.compressed.lastPathComponent)
            try? FileManager.default.copyItem(at: item.compressed, to: destURL)
        }
        dismiss()
    }

    func shareAll() {
        let urls = compressedPDFs.map { $0.compressed }
        let activityVC = UIActivityViewController(activityItems: urls, applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }

    func showSinglePDF(_ url: URL) {
        let pdfVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(pdfVC, animated: true)
        }
    }

    func formatSize(_ size: Int) -> String {
        let bytes = Double(size)
        if bytes < 1024 {
            return String(format: "%.0f Bytes", bytes)
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", bytes / 1024)
        } else if bytes < 1024 * 1024 * 1024 {
            return String(format: "%.2f MB", bytes / (1024 * 1024))
        } else {
            return String(format: "%.2f GB", bytes / (1024 * 1024 * 1024))
        }
    }
}

// MARK: - PDFKit View
struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}



