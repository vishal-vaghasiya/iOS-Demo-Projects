//
//  AppRouter.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Combine
import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    enum Route: Hashable {
        case createPdf
        case mergePdf
        case splitPdf
        case compressPdf
        case pdfSecurity
        case editPdf
        case addSignature
        case addPageNumbers
        case annotatePdf
        case pdfSummary
        case extractKeyPoints
        case generateNotes
        case questionAnswering
        case highlightText
        case underlineText
        case strikeThroughText
        case drawOnPDF
        case pdfNotes
        case duplicatePages
        case cropPdf
        case reversePages
        case pdfToLongImage
        case extractPages
        case deletePages
        case rearrangePages
        case rotatePages
        case addTextWatermark
        case addLogoWatermark
        case scanDoc
        case scanId
        case scanPassport
        case scanReceipt
        case scanBusinessCard
        case imageToText
        case scanToText
        case compressImage
        case resizeImage
        case convertImage
        case editImage
        case convertToHEIC
        case convertToWebP
        case convertToJPG
        case convertToPNG
        case convertToGIF
        case webpToJpg
        case webpToPng
        case jpgToWebp
        case pngToWebp
        case gifToImages
        case imagesToGif
        case removeMetadata
        case privacyCleaner
        case convertLivePhotos
        case extractVideoFrame
        case zipExport
        case cloudBackup
    }

    @Published var dashboardPath = NavigationPath()

    func push(_ route: Route) {
        dashboardPath.append(route)
    }

    func pop() {
        guard !dashboardPath.isEmpty else { return }
        dashboardPath.removeLast()
    }

    func popToRoot() {
        dashboardPath.removeLast(dashboardPath.count)
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .createPdf:
            PDFCreateView()
        case .mergePdf:
            PDFMergeView()
        case .splitPdf:
            PDFSplitView()
        case .compressPdf:
            PDFCompressView()
        case .pdfSecurity:
            PDFSecurityView()
        case .editPdf:
            PDFEditView()
        case .addSignature:
            AddSignatureView()
        case .addPageNumbers:
            PDFPageNumbersView()
        case .annotatePdf:
            PDFAnnotationView()
        case .pdfSummary:
            PDFSummaryView()
        case .extractKeyPoints:
            PDFKeyPointsView()
        case .generateNotes:
            PDFNotesView()
        case .questionAnswering:
            PDFQuestionAnsweringView()
        case .highlightText:
            PDFAnnotationView(initialTool: .highlight)
        case .underlineText:
            PDFAnnotationView(initialTool: .underline)
        case .strikeThroughText:
            PDFAnnotationView(initialTool: .strikeThrough)
        case .drawOnPDF:
            PDFAnnotationView(initialTool: .draw)
        case .pdfNotes:
            PDFAnnotationView(initialTool: .note)
        case .duplicatePages:
            PDFDuplicatePagesView()
        case .cropPdf:
            PDFCropView()
        case .reversePages:
            PDFReversePagesView()
        case .pdfToLongImage:
            PDFToLongImageView()
        case .extractPages:
            PDFExtractPagesView()
        case .deletePages:
            PDFDeletePagesView()
        case .rearrangePages:
            PDFRearrangePagesView()
        case .rotatePages:
            PDFRotatePagesView()
        case .addTextWatermark:
            AddTextWatermarkView()
        case .addLogoWatermark:
            AddLogoWatermarkView()
        case .scanDoc:
            DocumentScannerView(scanType: .document)
        case .scanId:
            DocumentScannerView(scanType: .idCard)
        case .scanPassport:
            DocumentScannerView(scanType: .passport)
        case .scanReceipt:
            DocumentScannerView(scanType: .receipt)
        case .scanBusinessCard:
            DocumentScannerView(scanType: .businessCard)
        case .imageToText:
            OCRView(startWithCamera: false)
        case .scanToText:
            OCRView(startWithCamera: true)
        case .compressImage:
            ImageCompressView()
        case .resizeImage:
            ImageResizeView()
        case .convertImage:
            ImageConvertView()
        case .editImage:
            ImageEditView()
        case .convertToHEIC:
            ConvertToHEICView()
        case .convertToWebP:
            ConvertToWebPView()
        case .convertToJPG:
            ConvertToJPGView()
        case .convertToPNG:
            ConvertToPNGView()
        case .convertToGIF:
            ConvertToGIFView()
        case .webpToJpg:
            WebPToJPGView()
        case .webpToPng:
            WebPToPNGView()
        case .jpgToWebp:
            JPGToWebPView()
        case .pngToWebp:
            PNGToWebPView()
        case .gifToImages:
            GIFToImagesView()
        case .imagesToGif:
            ImagesToGIFView()
        case .removeMetadata:
            RemoveMetadataView()
        case .privacyCleaner:
            PrivacyCleanerView()
        case .convertLivePhotos:
            ConvertLivePhotosView()
        case .extractVideoFrame:
            ExtractVideoFrameView()
        case .zipExport:
            ZIPExportView()
        case .cloudBackup:
            CloudBackupView()
        }
    }
}
