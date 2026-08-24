//
//  DocSignViewNew.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 13/11/25.
//

import SwiftUI
import PDFKit

// MARK: - Signature Storage
struct SignatureStorage {
    static private func signaturesFolderURL() -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = base.appendingPathComponent("Signatures")
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    static func loadAllSignatures() -> [UIImage] {
        let folder = signaturesFolderURL()
        let files = (try? FileManager.default.contentsOfDirectory(at: folder,
                                                                  includingPropertiesForKeys: nil)) ?? []

        return files
            .filter { $0.pathExtension.lowercased() == "png" }
            .compactMap { UIImage(contentsOfFile: $0.path) }
    }
}

// MARK: - Signature Model
struct SignatureLayer: Identifiable {
    let id = UUID()
    var image: UIImage
    var offset: CGSize
    var scale: CGFloat
    var isSelected: Bool
}

// MARK: - Load PDF
func loadAllPdfPages(pdf: PDFDocument) -> [UIImage] {
    var images: [UIImage] = []

    for index in 0 ..< pdf.pageCount {
        if let page = pdf.page(at: index) {
            let rect = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: rect.size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(rect)
                ctx.cgContext.translateBy(x: 0, y: rect.height)
                ctx.cgContext.scaleBy(x: 1, y: -1)
                page.draw(with: .mediaBox, to: ctx.cgContext)
            }
            images.append(img)
        }
    }
    return images
}

// MARK: - Inline Page View
struct PDFPageInlineView: View {

    let pageIndex: Int
    @Binding var pageImage: UIImage
    @Binding var isEditing: Bool

    @State private var signatures: [SignatureLayer] = []
    @GestureState private var dragState: CGSize = .zero
    @State private var renderedImageSize: CGSize = .zero
    @State private var storedSignatures: [UIImage] = []
    @State private var imageSize: CGSize = .zero
    @State private var imageFrame: CGRect = .zero

    var body: some View {
        VStack(alignment: .center) {

            ZStack {
                Image(uiImage: pageImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ImageFrameKey.self, value: geo.frame(in: .local))
                        }
                    )
                    .onPreferenceChange(ImageFrameKey.self) { frame in
                        imageFrame = frame
                        imageSize = frame.size
                    }
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.20), radius: 12, x: 0, y: 6)   // bottom shadow
                    .shadow(color: Color.white.opacity(0.5), radius: 4, x: -2, y: -2)   // top highlight
                    .glassEffect()
                
                if isEditing {
                    ForEach($signatures) { $sign in
                        let aspect = sign.image.size.height / sign.image.size.width
                        let displayWidth = 150 * sign.scale
                        let displayHeight = displayWidth * aspect

                        Image(uiImage: sign.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: displayWidth, height: displayHeight)
                            .border(sign.isSelected ? Color.blue : Color.clear, width: 2)
                            .position(
                                x: imageSize.width / 2 + sign.offset.width + dragState.width,
                                y: imageSize.height / 2 + sign.offset.height + dragState.height
                            )
                            .onTapGesture {
                                for i in signatures.indices { signatures[i].isSelected = false }
                                sign.isSelected = true
                            }
                            .highPriorityGesture(
                                DragGesture()
                                    .updating($dragState) { value, state, _ in
                                        if sign.isSelected {
                                            let proposedX = sign.offset.width + value.translation.width
                                            let proposedY = sign.offset.height + value.translation.height

                                            let aspect = sign.image.size.height / sign.image.size.width
                                            let displayWidth = 150 * sign.scale
                                            let displayHeight = displayWidth * aspect

                                            let halfSigW = displayWidth / 2
                                            let halfSigH = displayHeight / 2

                                            // BEST OPTION: precise center-based PDF boundaries
                                            let halfW = imageSize.width / 2
                                            let halfH = imageSize.height / 2

                                            let minX = -halfW + halfSigW + 5
                                            let maxX =  halfW - halfSigW - 5
                                            let minY = -halfH + halfSigH + 5
                                            let maxY =  halfH - halfSigH - 5

                                            let clampedX = min(max(proposedX, minX), maxX)
                                            let clampedY = min(max(proposedY, minY), maxY)

                                            state = CGSize(width: clampedX - sign.offset.width,
                                                           height: clampedY - sign.offset.height)
                                        }
                                    }
                                    .onEnded { value in
                                        if sign.isSelected {

                                            // Proposed new position
                                            let newX = sign.offset.width + value.translation.width
                                            let newY = sign.offset.height + value.translation.height

                                            let aspect = sign.image.size.height / sign.image.size.width
                                            let displayWidth = 150 * sign.scale
                                            let displayHeight = displayWidth * aspect

                                            let halfSigW = displayWidth / 2
                                            let halfSigH = displayHeight / 2

                                            let halfW = imageSize.width / 2
                                            let halfH = imageSize.height / 2

                                            let minX = -halfW + halfSigW + 5
                                            let maxX =  halfW - halfSigW - 5
                                            let minY = -halfH + halfSigH + 5
                                            let maxY =  halfH - halfSigH - 5

                                            sign.offset.width = min(max(newX, minX), maxX)
                                            sign.offset.height = min(max(newY, minY), maxY)
                                        }
                                    }
                            )
                            .highPriorityGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        if sign.isSelected {
                                            sign.scale = value
                                        }
                                    }
                            )
                    }
                }
            }
            .padding(.vertical, 20)

            if isEditing {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.fixed(80))], spacing: 5) {
                        ForEach(Array(storedSignatures.reversed().enumerated()), id: \.offset) { index, img in
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 60)
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(5)
                                .shadow(radius: 1)
                                .onTapGesture {
                                    addSignature(img)
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 100)

                Slider(value: Binding(
                    get: {
                        signatures.first(where: { $0.isSelected })?.scale ?? 1.0
                    },
                    set: { newValue in
                        if let index = signatures.firstIndex(where: { $0.isSelected }) {
                            signatures[index].scale = newValue
                        }
                    }
                ), in: 0.2...3.0)
                .padding(.horizontal)

                HStack {
                    Button(action: {
                        signatures.removeAll { $0.isSelected }
                    }) {
                        Text("Remove Selected")
                            .padding()
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                    .glassEffect()
                    
                    Button(action: {
                        if let newImage = mergeSignatureLayers() {
                            pageImage = newImage
                            signatures.removeAll()
                        }
                    }) {
                        Text("Apply to Page")
                            .padding()
                            .cornerRadius(10)
                    }
                    .glassEffect()
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
        }
        .padding(.horizontal)
        .onChange(of: isEditing) { newValue in
            if newValue == true {
                storedSignatures = SignatureStorage.loadAllSignatures()
            }
        }
    }

    func addSignature(_ img: UIImage) {
        for i in signatures.indices { signatures[i].isSelected = false }
        signatures.append(SignatureLayer(image: img, offset: .zero, scale: 1.0, isSelected: true))
    }

    func mergeSignatureLayers() -> UIImage? {
        let displaySize = imageSize   // use real displayed PDF size for correct mapping

        let renderer = UIGraphicsImageRenderer(size: pageImage.size)
        return renderer.image { ctx in

            pageImage.draw(in: CGRect(origin: .zero, size: pageImage.size))

            let scaleX = pageImage.size.width / displaySize.width
            let scaleY = pageImage.size.height / displaySize.height

            for sign in signatures {

                let baseWidth = 150 * sign.scale
                let aspect = sign.image.size.height / sign.image.size.width
                let baseHeight = baseWidth * aspect

                let signatureWidth = baseWidth * scaleX
                let signatureHeight = baseHeight * scaleY

                let cx = (imageSize.width / 2) + sign.offset.width
                let cy = (imageSize.height / 2) + sign.offset.height

                let realX = (cx * scaleX) - (signatureWidth / 2)
                let realY = (cy * scaleY) - (signatureHeight / 2)

                let rect = CGRect(x: realX, y: realY, width: signatureWidth, height: signatureHeight)
                sign.image.draw(in: rect)
            }
        }
    }
}

// MARK: - Main View
struct DocSignViewNew: View {

    let pdfDocument: PDFDocument = PDFDocument(
        url: Bundle.main.url(forResource: "sample", withExtension: "pdf")!
    )!

    @State private var allPages: [UIImage] = []
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            TabView {
                ForEach(allPages.indices, id: \.self) { index in
                    PDFPageInlineView(
                        pageIndex: index,
                        pageImage: $allPages[index],
                        isEditing: $isEditing
                    )
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .navigationTitle("PDF Editor")
            .toolbar {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
                .glassEffect()
            }
            .onAppear {
                allPages = loadAllPdfPages(pdf: pdfDocument)
            }
        }
    }
}

struct ImageFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

#Preview {
    DocSignViewNew()
}
