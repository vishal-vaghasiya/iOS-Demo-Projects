import SwiftUI

struct GameControlsView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        GlassCard(cornerRadius: 18, padding: 12) {
            HStack(spacing: 0) {
                controlButton(icon: "arrow.uturn.backward", label: "Undo", enabled: viewModel.canUndo) {
                    viewModel.undo()
                }

                controlButton(icon: "arrow.uturn.forward", label: "Redo", enabled: viewModel.canRedo) {
                    viewModel.redo()
                }

                controlButton(icon: "delete.left", label: "Erase", enabled: true) {
                    viewModel.clearSelectedCell()
                }

                controlButton(icon: viewModel.isNotesMode ? "pencil.circle.fill" : "pencil.circle",
                              label: "Notes",
                              enabled: true,
                              tint: viewModel.isNotesMode ? Color(hex: "#818CF8") : .white) {
                    viewModel.isNotesMode.toggle()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }

                controlButton(icon: "lightbulb", label: "Hint", enabled: viewModel.selectedCell != nil) {
                    // Hint requires UIViewController — handled in GameView via environment
                    NotificationCenter.default.post(name: .requestHint, object: nil)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private func controlButton(
        icon: String,
        label: String,
        enabled: Bool,
        tint: Color = .white,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(enabled ? tint : .white.opacity(0.25))
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(enabled ? tint.opacity(0.7) : .white.opacity(0.2))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

extension Notification.Name {
    static let requestHint = Notification.Name("GlassSudoku.requestHint")
}
