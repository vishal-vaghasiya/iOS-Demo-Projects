//
//  PDFKitView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 05/11/25.
//

//import SwiftUI
//import PDFKit
//
//struct PDFSignKitView: UIViewRepresentable {
//    let pdfPage: PDFPage
//    var onPDFViewCreated: ((PDFView) -> Void)? = nil
//
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.autoScales = true
//
//        let doc = PDFDocument()
//        doc.insert(pdfPage, at: 0)
//        pdfView.document = doc
//
//        DispatchQueue.main.async {
//            onPDFViewCreated?(pdfView)
//        }
//        return pdfView
//    }
//
//    func updateUIView(_ uiView: PDFView, context: Context) {}
//}
