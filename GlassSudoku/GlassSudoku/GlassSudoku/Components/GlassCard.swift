import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    var opacity: Double = 1.0
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.35), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
            .opacity(opacity)
    }
}

#Preview {
    ZStack {
        Color.indigo.ignoresSafeArea()
        GlassCard {
            Text("Hello Glass")
                .foregroundStyle(.white)
        }
    }
}
