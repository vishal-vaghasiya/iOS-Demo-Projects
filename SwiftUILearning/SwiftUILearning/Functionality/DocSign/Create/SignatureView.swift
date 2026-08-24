import SwiftUI
import PencilKit

// MARK: - Signature View (Main UI)
struct SignatureView: View {
    @StateObject private var viewModel = SignatureViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("✍️ Create Your Digital Signature")
                .font(.headline)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .center)

            // Signature Canvas
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .background(Color.white.opacity(0.001)) // Keeps tap detection
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4)

                SignatureCanvasView(canvasView: viewModel.canvasView)
                    .cornerRadius(12)
                    .padding(4)
            }
            .frame(height: 250)

            // Action Buttons
            HStack(spacing: 40) {
                Button(action: viewModel.clearCanvas) {
                    Label("Clear", systemImage: "trash")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.red)
                }

                Button(action: viewModel.saveSignature) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 10)

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertTitle),
                  message: Text(viewModel.alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    SignatureView()
}
