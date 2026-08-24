import SwiftUI

struct SplashView: View {
    @State private var animate = false
    @State private var showNext = false

    var body: some View {
        ZStack {
            if showNext {
                OnboardingView(isCompleted: .constant(false))
                    .transition(.opacity)
            } else {
                splashContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showNext)
        .onAppear {
            startAnimation()
            navigateAfterDelay()
        }
    }

    private var splashContent: some View {
        ZStack {
            AppTheme.background
            VStack(spacing: 20) {
                Image(systemName: "pills.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .scaleEffect(animate ? 1.1 : 0.85)
                    .opacity(animate ? 1 : 0.6)
                Text("PillPal")
                    .font(.largeTitle.weight(.semibold))
            }
            .foregroundColor(AppTheme.accent)
        }
        .ignoresSafeArea()
    }

    private func startAnimation() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            animate.toggle()
        }
    }

    private func navigateAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showNext = true
            }
        }
    }
}

#Preview {
    SplashView()
}
