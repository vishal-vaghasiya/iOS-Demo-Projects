import SwiftUI
import PencilKit

// MARK: - PencilKit Canvas Wrapper
struct SignatureCanvasView: UIViewRepresentable {
    let canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
