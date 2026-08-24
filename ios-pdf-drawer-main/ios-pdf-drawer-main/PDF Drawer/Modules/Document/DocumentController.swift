//
//  DocumentController.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit
import PDFKit

class DocumentController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var pdfView: NonSelectablePDFView!
    @IBOutlet weak var thumbnailView: PDFThumbnailView!
    @IBOutlet weak var thumbnailShape: UIView!
    @IBOutlet weak var currentPageLabel: UILabel!
    
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var handButton: UIButton!
    @IBOutlet weak var UndoButton: UIButton!
    @IBOutlet var zoomButtons: [UIButton]!
    @IBOutlet weak var sizeSlider: UISlider!
    
    
    // MARK: - Peoperties
    var shouldUpdatePDFScrollPosition = true
    let pdfDrawer = PDFDrawer()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupThumbnail()
        setupPDF()
        loadPDF()
        setupDrawer()
        setupPencilColor()
        setActiveZoomButton()
        setupSizeSlider()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldUpdatePDFScrollPosition {
            fixPDFViewScrollPosition()
        }
    }
    
    private func fixPDFViewScrollPosition() {
        if let page = pdfView.document?.page(at: 0) {
            pdfView.go(to: PDFDestination(page: page, at: CGPoint(x: 0, y: page.bounds(for: pdfView.displayBox).size.height)))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldUpdatePDFScrollPosition = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pdfView.autoScales = true
    }
    
    
    // MARK: - Methods
    func setupThumbnail() {
        thumbnailView.pdfView = pdfView
        thumbnailView.thumbnailSize = CGSize(width: 100, height: 100)
        thumbnailView.layoutMode = .vertical
        thumbnailView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        thumbnailView.backgroundColor = UIColor(white: 0.9, alpha: 0.4)
        thumbnailShape.layer.borderWidth = 1.5
        thumbnailShape.layer.borderColor = UIColor.appBorder.cgColor
        thumbnailShape.layer.cornerRadius = 20
        
        thumbnailShape.backgroundColor = UIColor(white: 0.9, alpha: 0.4)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePageChange(_:)), name: .PDFViewPageChanged, object: pdfView)
    }
    
    @objc func handlePageChange(_ notification: Notification) {
        let currentPage = pdfView.currentPage?.pageRef?.pageNumber ?? 0
        let totalPages = pdfView.document?.pageCount ?? 0
        
        currentPageLabel.text = "\(currentPage)  /  \(totalPages)"
    }
    
    func setupPDF() {
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        pdfView.autoScales = true
        pdfView.backgroundColor = .appCell
    }
    
    func setupDrawer() {
        let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
        pdfView.addGestureRecognizer(pdfDrawingGestureRecognizer)
        pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
        pdfDrawer.pdfView = pdfView
    }
    
    func setupSizeSlider() {
        sizeSlider.addTarget(self, action: #selector(valueChangedOfSlider(slider:)), for: .valueChanged)
    }
    
    @objc func valueChangedOfSlider(slider: UISlider) {
        guard let page = thumbnailView.pdfView?.currentPage else { return }
        let size: CGFloat = CGFloat(slider.value * 600)
        
        pdfDrawer.resizeLastAnnotation(bySize: size < 150 ? 150 : size, on: page)
    }
    
    // MARK: - Actions
    @IBAction func handButtonClicked(_ sender: Any?) {
        setActiveButton(handButton)
        pdfDrawer.drawingTool = .hand
        setActiveZoomButton()
    }
    
    @IBAction func undoButtonClicked(_ sender: Any) {
        guard let page = thumbnailView.pdfView?.currentPage else { return }
        pdfDrawer.removeLastAnnotation(page: page)
        setActiveZoomButton()
    }
    
    @IBAction func zoomButtonClicked(_ sender: UIButton) {
        sizeSlider.isHidden.toggle()
    }
    
    @IBAction func signatureButtonClicked(_ sender: Any) {
        let vc = SignatureController()
        vc.didPickSignatureHandler = { [weak self] signature in
            guard let self = self else { return }
            
            self.drawSignature(base64String: signature)
            
        }
        presentViewModally(vc)
    }
    
    
    @IBAction func saveSignatureButtonClicked(_ sender: Any) {
        exportDocumentAsFile()
    }
    
}
