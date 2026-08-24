import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var timerVM: TimerViewModel

    var body: some View {
        GlassCard(cornerRadius: 20, padding: 14) {
            HStack(spacing: 0) {

                // ── Difficulty badge ──────────────────────────────────────────
                if let board = viewModel.board {
                    difficultyBadge(board.difficulty)
                }

                Spacer()

                // ── Timer + pause button ──────────────────────────────────────
                Button(action: { viewModel.togglePause() }) {
                    HStack(spacing: 7) {
                        // Pause / play icon
                        Image(systemName: viewModel.gameState == .paused ? "play.fill" : "pause.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.65))
                            .frame(width: 18)

                        // Time digits
                        Text(viewModel.gameState == .paused ? "--:--" : timerVM.displayTime)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: timerVM.displayTime)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.gameState == .paused
                                  ? Color(hex: "#818CF8").opacity(0.25)
                                  : Color.white.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.gameState == .paused
                                    ? Color(hex: "#818CF8").opacity(0.6)
                                    : Color.white.opacity(0.15),
                                    lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Spacer()

                // ── Mistake dots ──────────────────────────────────────────────
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i < viewModel.mistakeCount
                                  ? Color(hex: "#F87171")
                                  : Color.white.opacity(0.18))
                            .frame(width: 10, height: 10)
                            .scaleEffect(i == viewModel.mistakeCount - 1 ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: viewModel.mistakeCount)
                    }
                    if viewModel.mistakeCount > 3 {
                        Text("+\(viewModel.mistakeCount - 3)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "#F87171"))
                    }
                }
                .frame(minWidth: 50, alignment: .trailing)
            }
        }
        .padding(.horizontal, 8)
    }

    // ── Difficulty badge ──────────────────────────────────────────────────────
    private func difficultyBadge(_ difficulty: DifficultyLevel) -> some View {
        Text(difficulty.displayName)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(difficultyColor(difficulty).opacity(0.25), in: Capsule())
            .overlay(Capsule().stroke(difficultyColor(difficulty).opacity(0.55), lineWidth: 1))
            .frame(minWidth: 70, alignment: .leading)
    }

    private func difficultyColor(_ d: DifficultyLevel) -> Color {
        switch d {
        case .easy:   return .green
        case .medium: return .yellow
        case .hard:   return .orange
        }
    }
}
