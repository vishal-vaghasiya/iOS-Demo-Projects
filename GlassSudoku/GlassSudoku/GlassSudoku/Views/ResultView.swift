import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var timerVM: TimerViewModel
    let onNewGame: (DifficultyLevel) -> Void
    let onRestart: () -> Void

    @State private var showContent = false
    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0

    private var isSuccess: Bool { viewModel.gameState == .completed }

    var body: some View {
        ZStack {
            // Blur backdrop
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .blur(radius: 2)

            VStack(spacing: 28) {
                // Animated ring / icon
                ZStack {
                    Circle()
                        .stroke(isSuccess ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 30)
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(isSuccess ? .green : .red)
                        .scaleEffect(showContent ? 1.0 : 0.2)
                        .opacity(showContent ? 1 : 0)
                }

                // Headline
                VStack(spacing: 8) {
                    Text(isSuccess ? "Puzzle Solved!" : "Game Over")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(isSuccess ? "Congratulations 🎉" : "Better luck next time")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .opacity(showContent ? 1 : 0)

                // Stats
                if let board = viewModel.board {
                    GlassCard(cornerRadius: 16, padding: 16) {
                        HStack(spacing: 0) {
                            statItem(icon: "clock", label: "Time", value: timerVM.displayTime)
                            Divider().background(.white.opacity(0.2)).frame(height: 40)
                            statItem(icon: "star", label: "Level", value: board.difficulty.displayName)
                            Divider().background(.white.opacity(0.2)).frame(height: 40)
                            statItem(icon: "exclamationmark.triangle", label: "Mistakes", value: "\(viewModel.mistakeCount)")
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                }

                // Actions
                VStack(spacing: 12) {
                    GlassButton(title: "New Puzzle", icon: "shuffle", style: .primary, action: {
                        onNewGame(viewModel.board?.difficulty ?? .easy)
                    })

                    GlassButton(title: "Try Again", icon: "arrow.counterclockwise", style: .secondary, action: onRestart)

                    if isSuccess {
                        HStack(spacing: 8) {
                            ForEach(DifficultyLevel.allCases, id: \.self) { level in
                                if level != viewModel.board?.difficulty {
                                    Button(level.displayName) { onNewGame(level) }
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                        }
                    }
                }
                .opacity(showContent ? 1 : 0)
            }
            .padding(32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                ringScale = 1.3
                ringOpacity = 1
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.2)) {
                showContent = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                ringScale = 1.0
            }
        }
    }

    private func statItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}
