// MARK: - Imports
import SwiftUI
import PDFKit

// MARK: - UIImage Extension
/// Extension to normalize UIImage orientation for correct rendering in PDF.
extension UIImage {
    /// Returns a copy of the image rendered in `.up` orientation (removes EXIF rotation)
    func normalizedImage() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalized
    }
}

// MARK: - ImageAnnotation
/// Custom PDFAnnotation subclass for rendering signature images on PDF pages.
class ImageAnnotation: PDFAnnotation {
    /// The image to render as an annotation.
    var imageToDraw: UIImage?
    
    /// Draws the annotation image with the correct upright orientation (no flipping or mirroring).
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        guard let image = imageToDraw else {
            super.draw(with: box, in: context)
            return
        }

        context.saveGState()
        context.setAllowsAntialiasing(true)
        context.interpolationQuality = .high
        context.setAlpha(1.0)

        // ✅ Fix: draw image as-is without extra transforms so it matches original PNG orientation
        let drawRect = CGRect(origin: bounds.origin, size: bounds.size)
        if let cgImage = image.cgImage {
            context.draw(cgImage, in: drawRect)
        }

        context.restoreGState()
    }
}

// MARK: - PDFSignKitView
/// UIViewRepresentable for displaying a single PDFPage in SwiftUI.
struct PDFSignKitView: UIViewRepresentable {
    let pdfPage: PDFPage
    var onPDFViewCreated: ((PDFView) -> Void)? = nil
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        let doc = PDFDocument()
        doc.insert(pdfPage, at: 0)
        pdfView.document = doc
        DispatchQueue.main.async {
            onPDFViewCreated?(pdfView)
        }
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - DocSignView
/// Main view for displaying a PDF, handling signature selection, placement, and saving.
struct DocSignView: View {
    // PDF and UI State
    @State private var activePDFView: PDFView?
    @State private var currentPageIndex: Int = 0
    @State var pdfPages: [PDFPage] = []
    @State private var showGridView = true
    @State private var selectedSignature: UIImage? = nil
    @State private var availableSignatures: [UIImage] = []
    @State private var showSignaturePicker = false
    // Drag state for moving signatures
    @State private var draggingAnnotation: PDFAnnotation? = nil
    @State private var dragStartPoint: CGPoint = .zero
    // Signature preview and scaling
    @State private var showSignaturePreview = false
    @State private var previewSignature: UIImage? = nil
    @State private var signatureScale: CGFloat = 1.0
    @State private var isPlacingSignature = false
    @State private var isDraggingSignature = false
    
    var body: some View {
        VStack {
            // MARK: Grid View or Fullscreen View
            if showGridView {
                // Grid of PDF pages for quick navigation
                ScrollView {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 20),
                            count: UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
                        ),
                        spacing: 20
                    ) {
                        ForEach(pdfPages.indices, id: \.self) { index in
                            PDFSignKitView(pdfPage: pdfPages[index]) { _ in }
                                .frame(height: 200)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                                .simultaneousGesture(
                                    TapGesture(count: 1)
                                        .onEnded {
                                            // Single tap opens the full signing view
                                            currentPageIndex = index
                                            withAnimation(.easeInOut) {
                                                showGridView = false
                                            }
                                            print("🖋 Opened signing view for page \(index + 1)")
                                        }
                                )
                        }
                    }
                    .padding()
                }
            } else {
                // Fullscreen mode for signing a single PDF page
                ZStack {
                    if pdfPages.indices.contains(currentPageIndex) {
                        PDFSignKitView(pdfPage: pdfPages[currentPageIndex]) { pdfView in
                            self.activePDFView = pdfView
                        }
                        .id(currentPageIndex)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        // MARK: - Gesture Handling
                        // Handles both tap (for placing signatures) and drag (for moving signatures)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    handleDragChanged(value)
                                }
                                .onEnded { value in
                                    if draggingAnnotation != nil {
                                        handleDragEnded(value)
                                        draggingAnnotation = nil
                                        return
                                    }
                                    // If not dragging, treat as a tap to place signature
                                    let tapLocation = value.location
                                    guard !isPlacingSignature else { return }
                                    isPlacingSignature = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        isPlacingSignature = false
                                    }
                                    if let pdfView = activePDFView,
                                       let signature = selectedSignature {
                                        addSignatureImage(signature, at: tapLocation)
                                        print("✅ Signature placed at tap location")
                                        // Allow only one placement per signature load
                                        selectedSignature = nil
                                    }
                                }
                        )
                    } else {
                        Text("No PDF Loaded")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // MARK: Top Toolbar
                    VStack {
                        HStack {
                            Spacer()
                            // Button to select a signature from available images
                            Button("Select Sign") {
                                showSignaturePicker = true
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer()
                        
                        // MARK: Bottom Controls
                        HStack {
                            Button("← Back to Grid") {
                                showGridView = true
                            }
                            .buttonStyle(.bordered)
                            Spacer()
                            Button("Prev") {
                                if currentPageIndex > 0 {
                                    currentPageIndex -= 1
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(currentPageIndex == 0)
                            Text("\(currentPageIndex + 1)/\(pdfPages.count)")
                                .font(.subheadline)
                                .padding(.horizontal, 8)
                            Button("Next") {
                                if currentPageIndex < pdfPages.count - 1 {
                                    currentPageIndex += 1
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(currentPageIndex >= pdfPages.count - 1)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            
            Spacer()
            
            if showGridView {
                // MARK: Bottom Controls for Grid View
                HStack(spacing: 20) {
                    Button("Cancel") {
                        // Implement cancel/export logic if needed
                    }
                    .buttonStyle(.bordered)
                    Button("Save PDF") {
                        savePDFToDocuments()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            loadSignatureFromDocuments()
        }
        // MARK: - Signature Picker and Preview
        .sheet(isPresented: $showSignaturePicker) {
            SignaturePickerSheet(
                availableSignatures: availableSignatures,
                onPick: { chosenImage in
                    signatureScale = 1.0
                    previewSignature = chosenImage
                    // Ensure the picker closes before showing preview
                    showSignaturePicker = false
                    showSignaturePreview = false
                    // Add double-delay to ensure first-time image load (avoids SwiftUI sheet race)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        if previewSignature != nil {
                            withAnimation {
                                showSignaturePreview = true
                            }
                        } else {
                            print("⚠️ No preview signature found on first attempt, retrying...")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if previewSignature != nil {
                                    showSignaturePreview = true
                                    print("✅ Preview signature loaded on retry.")
                                } else {
                                    print("❌ Failed to load preview signature after retry.")
                                }
                            }
                        }
                    }
                }
            )
        }
        .sheet(isPresented: $showSignaturePreview) {
            // MARK: - Signature Preview Sheet
            VStack(spacing: 20) {
                Text("Preview Signature")
                    .font(.headline)
                if let previewImage = previewSignature {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250 * signatureScale, height: 100 * signatureScale)
                        .shadow(radius: 5)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    signatureScale = max(0.5, min(2.0, value))
                                }
                        )
                        .padding()
                } else {
                    Text("No Preview Signature found!")
                }
                HStack(spacing: 20) {
                    Button("Cancel") {
                        showSignaturePreview = false
                    }
                    .buttonStyle(.bordered)
                    Button("Apply to PDF") {
                        selectedSignature = previewSignature
                        showSignaturePreview = false
                        print("🖋 Signature ready to place on PDF. Tap to add it.")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.bottom)
            }
            .presentationDetents([.medium])
            .padding()
        }
    }
    
    // MARK: - Gesture Handling
    /// Handles drag gesture for moving a signature annotation.
    func handleDragChanged(_ value: DragGesture.Value) {
        guard let pdfView = activePDFView,
              let page = pdfView.currentPage else { return }
        let location = value.location
        // Convert to PDF page coordinates (page-space)
        let pdfPoint = pdfView.convert(location, to: page)
        
        if draggingAnnotation == nil {
            // Detect if the user tapped on an existing annotation
            if let found = page.annotations.first(where: {
                $0.bounds.contains(pdfPoint) && $0 is ImageAnnotation
            }) {
                draggingAnnotation = found
                dragStartPoint = pdfPoint
                isDraggingSignature = true
            }
        } else if let annotation = draggingAnnotation {
            // Calculate delta movement
            let dx = pdfPoint.x - dragStartPoint.x
            let dy = pdfPoint.y - dragStartPoint.y
            var newBounds = annotation.bounds
            newBounds.origin.x += dx
            newBounds.origin.y += dy
            annotation.bounds = newBounds
            dragStartPoint = pdfPoint

            // Redraw annotation during drag
            page.removeAnnotation(annotation)
            page.addAnnotation(annotation)
            pdfView.setNeedsDisplay()
        }
    }
    
    /// Called when drag gesture ends; clears dragging state.
    func handleDragEnded(_ value: DragGesture.Value) {
        draggingAnnotation = nil
    }
    
    // MARK: - Signature Management
    /// Loads all signature images from the app's Documents/Signatures directory.
    func loadSignatureFromDocuments() {
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Cannot find documents directory")
            availableSignatures = []
            return
        }
        let signaturesFolder = docsURL.appendingPathComponent("Signatures")
        if !fileManager.fileExists(atPath: signaturesFolder.path) {
            do {
                try fileManager.createDirectory(at: signaturesFolder, withIntermediateDirectories: true, attributes: nil)
                print("📁 Created Signatures folder at \(signaturesFolder.path)")
            } catch {
                print("❌ Failed to create Signatures folder: \(error)")
                availableSignatures = []
                return
            }
        }
        do {
            let files = try fileManager.contentsOfDirectory(
                at: signaturesFolder,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            )
            // Sort by modification date, newest first
            let sorted = try files.sorted {
                let date0 = try $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? Date.distantPast
                let date1 = try $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? Date.distantPast
                return date0 > date1
            }
            let images = sorted.compactMap { UIImage(contentsOfFile: $0.path) }
            availableSignatures = images
        } catch {
            print("❌ Error loading signature images from Signatures folder: \(error)")
            availableSignatures = []
        }
    }
    
    // Adds a signature image as a draggable PDF annotation so dragging works.
    func addSignatureImage(_ image: UIImage, at location: CGPoint) {
        guard let pdfView = activePDFView,
              let page = pdfView.currentPage else { return }

        // Convert tap location (view coordinates) to PDF page coordinates
        let pdfPoint = pdfView.convert(location, to: page)

        // Desired annotation size in page coordinates
        let baseWidth: CGFloat = 200
        let baseHeight: CGFloat = 80
        let imageWidth = baseWidth * signatureScale
        let imageHeight = baseHeight * signatureScale

        // Center the annotation at the tap point
        let rect = CGRect(
            x: pdfPoint.x - imageWidth / 2,
            y: pdfPoint.y - imageHeight / 2,
            width: imageWidth,
            height: imageHeight
        )

        // Normalize orientation to avoid EXIF rotation issues
        let normalized = image.normalizedImage()

        // Create ImageAnnotation and assign image
        let annotation = ImageAnnotation(bounds: rect, forType: .stamp, withProperties: nil)
        annotation.imageToDraw = normalized
        annotation.border = PDFBorder()
        annotation.border?.lineWidth = 0
        annotation.shouldDisplay = true
        annotation.shouldPrint = true

        // Add annotation to page (live, draggable)
        page.addAnnotation(annotation)

        // Update local cache and refresh PDFView
        if currentPageIndex < pdfPages.count {
            pdfPages[currentPageIndex] = page
        }
        pdfView.setNeedsDisplay()
    }
}

// MARK: - PDF Saving
extension DocSignView {
    /// Combines all PDF pages and saves the annotated PDF to the Documents directory.
    func savePDFToDocuments() {
        let newPDF = PDFDocument()
        for (i, page) in pdfPages.enumerated() {
            newPDF.insert(page, at: i)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = formatter.string(from: Date())
        let filename = "SignedDocument_\(timestamp).pdf"
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Cannot find documents directory")
            return
        }
        let saveURL = docsURL.appendingPathComponent(filename)
        if newPDF.write(to: saveURL) {
            print("✅ PDF saved to: \(saveURL.path)")
        } else {
            print("❌ Failed to save PDF")
        }
    }
}

// MARK: - Signature Picker and Preview
// (SignaturePickerSheet is used as the sheet for signature selection)

// MARK: - SignaturePickerSheet
/// Displays a sheet for selecting a signature image from available signatures.
struct SignaturePickerSheet: View {
    let availableSignatures: [UIImage]
    let onPick: (UIImage) -> Void
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(Array(availableSignatures.enumerated()), id: \.offset) { idx, img in
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .onTapGesture {
                                onPick(img)
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Signature")
        }
    }
}
