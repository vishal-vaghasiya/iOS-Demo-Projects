//
//  SelectDocView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 05/11/25.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct SelectDocView: View {
    @State private var showPicker = false
    @State private var selectedPDF: PDFDocument?
    @State private var navigateToDocSign = false
    @State private var pdfPages: [PDFPage] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Select Document")
                    .font(.title)
                    .bold()

                Button("📂 Select PDF from Files") {
                    showPicker = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                NavigationLink(destination: SignatureView()) {
                    Text("✍️ Create Signature")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                NavigationLink(
                    destination: Group {
                        if !pdfPages.isEmpty {
                            DocSignView(pdfPages: pdfPages)
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: $navigateToDocSign
                ) {
                    EmptyView()
                }

                Spacer()
            }
            .padding()
            .fileImporter(
                isPresented: $showPicker,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                do {
                    guard let pickedURL = try result.get().first else { return }
                    print(pickedURL)
                    // ✅ Start accessing the secured file
                    guard pickedURL.startAccessingSecurityScopedResource() else {
                        print("❌ Could not access selected file")
                        return
                    }
                    defer { pickedURL.stopAccessingSecurityScopedResource() }

                    if let doc = PDFDocument(url: pickedURL) {
                        var pages: [PDFPage] = []
                        for i in 0..<doc.pageCount {
                            if let page = doc.page(at: i) {
                                pages.append(page)
                            }
                        }
                        self.pdfPages = pages
                        self.navigateToDocSign = true
                        print("✅ Loaded \(pages.count) pages from \(pickedURL.lastPathComponent)")
                    } else {
                        print("⚠️ Unable to open PDF at URL:", pickedURL)
                    }
                } catch {
                    print("❌ Error picking PDF:", error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    SelectDocView()
}
