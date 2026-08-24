//
//  DashboardView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct DashboardView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject private var router: AppRouter
    @State private var toolSearchText = ""
    @State private var selectedToolFilter: ToolFilter = .all

    var body: some View {
        VStack(spacing: 0) {
            toolFinder
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(filteredSections) { section in
                        sectionView(section)
                    }

                    if filteredSections.isEmpty {
                        EmptyStateView(
                            title: "No tools found",
                            description: "Try searching with another tool name or switch the filter.",
                            iconName: Images.System.search,
                            style: .empty
                        )
                        .padding(.top, 48)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .buttonStyle(.plain)
    }

    private var toolFinder: some View {
        VStack(spacing: 12) {
            SearchBar(text: $toolSearchText, placeholder: "Search tools...")

            Picker("Tool Type", selection: $selectedToolFilter) {
                ForEach(ToolFilter.allCases) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(Color.appCardBackground)
    }

    private var filteredSections: [ToolSection] {
        let query = toolSearchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return allSections.compactMap { section in
            let tools = section.tools.filter { tool in
                let matchesFilter = selectedToolFilter.category.map { tool.category == $0 } ?? true
                let matchesSearch = query.isEmpty
                    || tool.title.localizedCaseInsensitiveContains(query)
                    || tool.description.localizedCaseInsensitiveContains(query)
                    || section.title.localizedCaseInsensitiveContains(query)
                return matchesFilter && matchesSearch
            }

            return tools.isEmpty ? nil : ToolSection(title: section.title, tools: tools)
        }
    }

    private func sectionView(_ section: ToolSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: section.title)

            VStack(spacing: 12) {
                ForEach(section.tools) { tool in
                    Button(action: { router.push(tool.route) }) {
                        ToolCard(
                            title: tool.title,
                            description: tool.description,
                            iconName: tool.iconName,
                            tintColor: tool.tintColor
                        )
                    }
                }
            }
        }
    }

    private var allSections: [ToolSection] {
        [
            ToolSection(title: Strings.Dashboard.pdfSection, tools: [
                .init(title: Strings.Dashboard.createPdf, description: Strings.Dashboard.createPdfDesc, iconName: Images.System.createPdf, tintColor: .appPrimary, route: .createPdf, category: .pdf),
                .init(title: Strings.Dashboard.mergePdf, description: Strings.Dashboard.mergePdfDesc, iconName: Images.System.mergePdf, tintColor: .appPrimary, route: .mergePdf, category: .pdf),
                .init(title: Strings.Dashboard.splitPdf, description: Strings.Dashboard.splitPdfDesc, iconName: Images.System.splitPdf, tintColor: .appPrimary, route: .splitPdf, category: .pdf),
                .init(title: Strings.Dashboard.compressPdf, description: Strings.Dashboard.compressPdfDesc, iconName: Images.System.compressPdf, tintColor: .appPrimary, route: .compressPdf, category: .pdf),
                .init(title: Strings.Dashboard.pdfSecurity, description: Strings.Dashboard.pdfSecurityDesc, iconName: Images.System.protectPdf, tintColor: .appPrimary, route: .pdfSecurity, category: .pdf),
                .init(title: Strings.Dashboard.addSignature, description: Strings.Dashboard.addSignatureDesc, iconName: Images.System.signature, tintColor: .appPrimary, route: .addSignature, category: .pdf),
                .init(title: Strings.Dashboard.addPageNumbers, description: Strings.Dashboard.addPageNumbersDesc, iconName: Images.System.pageNumbers, tintColor: .appPrimary, route: .addPageNumbers, category: .pdf),
                .init(title: Strings.Dashboard.extractPages, description: Strings.Dashboard.extractPagesDesc, iconName: Images.System.extractPages, tintColor: .appPrimary, route: .extractPages, category: .pdf),
                .init(title: Strings.Dashboard.deletePages, description: Strings.Dashboard.deletePagesDesc, iconName: Images.System.deletePages, tintColor: .appPrimary, route: .deletePages, category: .pdf),
                .init(title: Strings.Dashboard.rearrangePages, description: Strings.Dashboard.rearrangePagesDesc, iconName: Images.System.rearrangePages, tintColor: .appPrimary, route: .rearrangePages, category: .pdf),
                .init(title: Strings.Dashboard.rotatePages, description: Strings.Dashboard.rotatePagesDesc, iconName: Images.System.rotatePages, tintColor: .appPrimary, route: .rotatePages, category: .pdf)
            ]),
            ToolSection(title: Strings.Dashboard.pdfAISection, tools: [
                .init(title: Strings.Dashboard.pdfSummary, description: Strings.Dashboard.pdfSummaryDesc, iconName: Images.System.pdfSummary, tintColor: .appPrimary, route: .pdfSummary, category: .pdf),
                .init(title: Strings.Dashboard.extractKeyPoints, description: Strings.Dashboard.extractKeyPointsDesc, iconName: Images.System.extractKeyPoints, tintColor: .appPrimary, route: .extractKeyPoints, category: .pdf),
                .init(title: Strings.Dashboard.generateNotes, description: Strings.Dashboard.generateNotesDesc, iconName: Images.System.generateNotes, tintColor: .appPrimary, route: .generateNotes, category: .pdf),
                .init(title: Strings.Dashboard.questionAnswering, description: Strings.Dashboard.questionAnsweringDesc, iconName: Images.System.questionAnswering, tintColor: .appPrimary, route: .questionAnswering, category: .pdf)
            ]),
            ToolSection(title: Strings.Dashboard.pdfAnnotationSection, tools: [
                .init(title: Strings.Dashboard.highlightText, description: Strings.Dashboard.highlightTextDesc, iconName: Images.System.highlightText, tintColor: .appPrimary, route: .highlightText, category: .pdf),
                .init(title: Strings.Dashboard.underlineText, description: Strings.Dashboard.underlineTextDesc, iconName: Images.System.underlineText, tintColor: .appPrimary, route: .underlineText, category: .pdf),
                .init(title: Strings.Dashboard.strikeThroughText, description: Strings.Dashboard.strikeThroughTextDesc, iconName: Images.System.strikeThroughText, tintColor: .appPrimary, route: .strikeThroughText, category: .pdf),
                .init(title: Strings.Dashboard.drawOnPDF, description: Strings.Dashboard.drawOnPDFDesc, iconName: Images.System.drawOnPDF, tintColor: .appPrimary, route: .drawOnPDF, category: .pdf),
                .init(title: Strings.Dashboard.pdfNotes, description: Strings.Dashboard.pdfNotesDesc, iconName: Images.System.pdfNotes, tintColor: .appPrimary, route: .pdfNotes, category: .pdf)
            ]),
            ToolSection(title: Strings.Dashboard.pdfOrganizationSection, tools: [
                .init(title: Strings.Dashboard.duplicatePages, description: Strings.Dashboard.duplicatePagesDesc, iconName: Images.System.duplicatePages, tintColor: .appPrimary, route: .duplicatePages, category: .pdf),
                .init(title: Strings.Dashboard.cropPdf, description: Strings.Dashboard.cropPdfDesc, iconName: Images.System.cropPdf, tintColor: .appPrimary, route: .cropPdf, category: .pdf),
                .init(title: Strings.Dashboard.reversePages, description: Strings.Dashboard.reversePagesDesc, iconName: Images.System.reversePages, tintColor: .appPrimary, route: .reversePages, category: .pdf),
                .init(title: Strings.Dashboard.pdfToLongImage, description: Strings.Dashboard.pdfToLongImageDesc, iconName: Images.System.pdfToLongImage, tintColor: .appPrimary, route: .pdfToLongImage, category: .pdf)
            ]),
            ToolSection(title: Strings.Dashboard.watermarkSection, tools: [
                .init(title: Strings.Dashboard.addTextWatermark, description: Strings.Dashboard.addTextWatermarkDesc, iconName: Images.System.textWatermark, tintColor: .appPrimary, route: .addTextWatermark, category: .pdf),
                .init(title: Strings.Dashboard.addLogoWatermark, description: Strings.Dashboard.addLogoWatermarkDesc, iconName: Images.System.logoWatermark, tintColor: .appPrimary, route: .addLogoWatermark, category: .pdf)
            ]),
            ToolSection(title: Strings.Dashboard.imageSection, tools: [
                .init(title: Strings.Dashboard.compressImage, description: Strings.Dashboard.compressImageDesc, iconName: Images.System.compressImage, tintColor: .appSecondary, route: .compressImage, category: .image),
                .init(title: Strings.Dashboard.resizeImage, description: Strings.Dashboard.resizeImageDesc, iconName: Images.System.resizeImage, tintColor: .appSecondary, route: .resizeImage, category: .image),
                .init(title: Strings.Dashboard.convertImage, description: Strings.Dashboard.convertImageDesc, iconName: Images.System.convertImage, tintColor: .appSecondary, route: .convertImage, category: .image),
                .init(title: Strings.ImageTools.editTitle, description: "Crop, rotate, flip, and adjust photos", iconName: Images.System.editImage, tintColor: .appSecondary, route: .editImage, category: .image)
            ]),
            ToolSection(title: Strings.Dashboard.additionalConversionsSection, tools: [
                .init(title: Strings.Dashboard.convertToHEIC, description: Strings.Dashboard.convertToHEICDesc, iconName: Images.System.imageFormatConvert, tintColor: .appSecondary, route: .convertToHEIC, category: .image),
                .init(title: Strings.Dashboard.convertToWebP, description: Strings.Dashboard.convertToWebPDesc, iconName: Images.System.imageFormatConvert, tintColor: .appSecondary, route: .convertToWebP, category: .image),
                .init(title: Strings.Dashboard.convertToJPG, description: Strings.Dashboard.convertToJPGDesc, iconName: Images.System.imageFormatConvert, tintColor: .appSecondary, route: .convertToJPG, category: .image),
                .init(title: Strings.Dashboard.convertToPNG, description: Strings.Dashboard.convertToPNGDesc, iconName: Images.System.imageFormatConvert, tintColor: .appSecondary, route: .convertToPNG, category: .image),
                .init(title: Strings.Dashboard.convertToGIF, description: Strings.Dashboard.convertToGIFDesc, iconName: Images.System.imagesToGif, tintColor: .appSecondary, route: .convertToGIF, category: .image)
            ]),
            ToolSection(title: Strings.Dashboard.scannerSection, tools: [
                .init(title: Strings.Dashboard.scanDoc, description: Strings.Dashboard.scanDocDesc, iconName: Images.System.scanDoc, tintColor: .appSuccess, route: .scanDoc, category: .other),
                .init(title: Strings.Dashboard.scanId, description: Strings.Dashboard.scanIdDesc, iconName: Images.System.scanId, tintColor: .appSuccess, route: .scanId, category: .other),
                .init(title: Strings.Dashboard.scanPassport, description: Strings.Dashboard.scanPassportDesc, iconName: Images.System.scanPassport, tintColor: .appSuccess, route: .scanPassport, category: .other),
                .init(title: Strings.Dashboard.scanReceipt, description: Strings.Dashboard.scanReceiptDesc, iconName: Images.System.scanReceipt, tintColor: .appSuccess, route: .scanReceipt, category: .other),
                .init(title: Strings.Dashboard.scanBusinessCard, description: Strings.Dashboard.scanBusinessCardDesc, iconName: Images.System.scanBusinessCard, tintColor: .appSuccess, route: .scanBusinessCard, category: .other)
            ]),
            ToolSection(title: Strings.Dashboard.ocrSection, tools: [
                .init(title: Strings.Dashboard.imageToText, description: Strings.Dashboard.imageToTextDesc, iconName: Images.System.imageToText, tintColor: .appWarning, route: .imageToText, category: .other),
                .init(title: Strings.Dashboard.scanToText, description: Strings.Dashboard.scanToTextDesc, iconName: Images.System.scanToText, tintColor: .appWarning, route: .scanToText, category: .other)
            ]),
            ToolSection(title: Strings.Dashboard.metadataSection, tools: [
                .init(title: Strings.Dashboard.removeMetadata, description: Strings.Dashboard.removeMetadataDesc, iconName: Images.System.removeMetadata, tintColor: .appWarning, route: .removeMetadata, category: .other),
                .init(title: Strings.Dashboard.privacyCleaner, description: Strings.Dashboard.privacyCleanerDesc, iconName: Images.System.privacyCleaner, tintColor: .appWarning, route: .privacyCleaner, category: .other)
            ]),
            ToolSection(title: Strings.Dashboard.utilitiesSection, tools: [
                .init(title: Strings.Dashboard.convertLivePhotos, description: Strings.Dashboard.convertLivePhotosDesc, iconName: Images.System.convertLivePhotos, tintColor: .appPrimary, route: .convertLivePhotos, category: .other),
                .init(title: Strings.Dashboard.extractVideoFrame, description: Strings.Dashboard.extractVideoFrameDesc, iconName: Images.System.extractVideoFrame, tintColor: .appPrimary, route: .extractVideoFrame, category: .other)
            ]),
            ToolSection(title: Strings.Dashboard.exportSection, tools: [
                .init(title: Strings.Dashboard.zipExport, description: Strings.Dashboard.zipExportDesc, iconName: Images.System.zipExport, tintColor: .appPrimary, route: .zipExport, category: .other),
                .init(title: Strings.Dashboard.cloudBackup, description: Strings.Dashboard.cloudBackupDesc, iconName: Images.System.cloudBackup, tintColor: .appPrimary, route: .cloudBackup, category: .other)
            ])
        ]
    }
}

private enum ToolCategory {
    case pdf
    case image
    case other
}

private enum ToolFilter: String, CaseIterable, Identifiable {
    case all
    case pdf
    case image
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .pdf: return "PDF"
        case .image: return "Image"
        case .other: return "Other"
        }
    }

    var category: ToolCategory? {
        switch self {
        case .all: return nil
        case .pdf: return .pdf
        case .image: return .image
        case .other: return .other
        }
    }
}

private struct ToolSection: Identifiable {
    let id = UUID()
    let title: String
    let tools: [ToolDefinition]
}

private struct ToolDefinition: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let tintColor: Color
    let route: AppRouter.Route
    let category: ToolCategory
}

// Help sheet share representable
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}
