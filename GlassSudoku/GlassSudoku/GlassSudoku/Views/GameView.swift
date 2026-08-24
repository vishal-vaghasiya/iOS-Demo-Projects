import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showDifficultyPicker = true
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            // ── Premium background ────────────────────────────────────────────
            PremiumBackground()
                .ignoresSafeArea()

            // ── Screens ───────────────────────────────────────────────────────
            if showDifficultyPicker || viewModel.gameState == .idle {
                DifficultyPickerView { difficulty in
                    withAnimation(.easeInOut(duration: 0.3)) { showDifficultyPicker = false }
                    viewModel.startNewGame(difficulty: difficulty)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal:   .move(edge: .leading)
                ))
            } else {
                gameContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal:   .move(edge: .leading)
                    ))
            }

            if viewModel.gameState == .loading { loadingOverlay }

            if viewModel.gameState == .completed || viewModel.gameState == .failed {
                ResultView(
                    viewModel: viewModel,
                    timerVM:   viewModel.timerVM,
                    onNewGame: { viewModel.startNewGame(difficulty: $0) },
                    onRestart: { viewModel.resetGame() }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.gameState)
        .animation(.easeInOut(duration: 0.35), value: showDifficultyPicker)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { viewModel.handleBackground() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .requestHint)) { _ in
            guard let vc = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                .first else { return }
            viewModel.requestHint(presentingViewController: vc)
        }
    }

    // ── Game layout ───────────────────────────────────────────────────────────
    private var gameContent: some View {
        VStack(spacing: 10) {
            HStack {
                GlassButton(title: "Menu",  icon: "house",                 style: .ghost) {
                    withAnimation { showDifficultyPicker = true }
                }
                Spacer()
                GlassButton(title: "Reset", icon: "arrow.counterclockwise", style: .ghost) {
                    viewModel.resetGame()
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            HeaderView(viewModel: viewModel, timerVM: viewModel.timerVM)
            GameBoardView(viewModel: viewModel)

            let isPaused = viewModel.gameState == .paused
            GameControlsView(viewModel: viewModel)
                .opacity(isPaused ? 0.35 : 1)
                .allowsHitTesting(!isPaused)

            NumberPadView(viewModel: viewModel)
                .opacity(isPaused ? 0.35 : 1)
                .allowsHitTesting(!isPaused)

            Spacer(minLength: 0)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.gameState == .paused)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            GlassCard {
                VStack(spacing: 12) {
                    ProgressView().tint(.white).scaleEffect(1.4)
                    Text("Loading Puzzle…")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
    }
}

// MARK: - Premium Background
struct PremiumBackground: View {
    var body: some View {
        ZStack {
            // ── Try to load the bundled background image ───────────────────────
            // Add bg_premium.jpg to your Xcode asset catalog or directly to the bundle.
            // The image was generated at 430×932 (@1x), 860×1864 (@2x), 1290×2796 (@3x).
            if let uiImg = UIImage(named: "bg_premium") {
                Image(uiImage: uiImg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    // Very light overlay so glass cards pop on top
                    .overlay(Color.black.opacity(0.12))
            } else {
                // ── Fallback gradient (same palette as the image) ──────────────
                LinearGradient(
                    colors: [
                        Color(hex: "#08081A"),
                        Color(hex: "#0D0D2B"),
                        Color(hex: "#111130")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Subtle glow orbs to replicate the image look
                ForEach(glowOrbs, id: \.id) { orb in
                    Circle()
                        .fill(orb.color.opacity(orb.opacity))
                        .frame(width: orb.size)
                        .blur(radius: orb.blur)
                        .position(x: UIScreen.main.bounds.width  * orb.x,
                                  y: UIScreen.main.bounds.height * orb.y)
                }
            }
        }
    }

    private struct Orb { let id: Int; let x, y, size, blur, opacity: CGFloat; let color: Color }

    private let glowOrbs: [Orb] = [
        Orb(id: 0, x: 0.15, y: 0.12, size: 280, blur: 60, opacity: 0.22, color: Color(hex: "#C9A84C")),
        Orb(id: 1, x: 0.85, y: 0.22, size: 300, blur: 70, opacity: 0.25, color: Color(hex: "#7C3AED")),
        Orb(id: 2, x: 0.50, y: 0.55, size: 340, blur: 80, opacity: 0.20, color: Color(hex: "#1E40AF")),
        Orb(id: 3, x: 0.12, y: 0.78, size: 240, blur: 55, opacity: 0.16, color: Color(hex: "#9F1239")),
        Orb(id: 4, x: 0.88, y: 0.88, size: 260, blur: 60, opacity: 0.18, color: Color(hex: "#0D9488")),
    ]
}

#Preview { GameView() }
