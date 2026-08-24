import SwiftUI

struct DifficultyPickerView: View {
    let onSelect: (DifficultyLevel) -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 32) {
            // Logo
            VStack(spacing: 10) {
                Text("⬛")
                    .font(.system(size: 56))
                Text("GlassSudoku")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("Choose your challenge")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .scaleEffect(appeared ? 1 : 0.85)
            .opacity(appeared ? 1 : 0)

            // Difficulty cards
            VStack(spacing: 12) {
                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                    DifficultyCard(level: level) { onSelect(level) }
                        .offset(x: appeared ? 0 : 60)
                        .opacity(appeared ? 1 : 0)
                        .animation(
                            .spring(response: 0.55, dampingFraction: 0.75)
                            .delay(0.1 + Double(DifficultyLevel.allCases.firstIndex(of: level)!) * 0.09),
                            value: appeared
                        )
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear { withAnimation { appeared = true } }
    }
}

private struct DifficultyCard: View {
    let level:  DifficultyLevel
    let action: () -> Void

    private var color: Color {
        switch level {
        case .easy:   return .green
        case .medium: return .yellow
        case .hard:   return .orange
        }
    }

    private var description: String {
        switch level {
        case .easy:   return "6×6 grid · Numbers 1–6"
        case .medium: return "9×9 grid · Standard rules"
        case .hard:   return "9×9 grid · Fewer hints"
        }
    }

    private var icon: String {
        switch level {
        case .easy:   return "🌱"
        case .medium: return "🔥"
        case .hard:   return "💥"
        }
    }

    var body: some View {
        Button(action: action) {
            GlassCard(cornerRadius: 18, padding: 0) {
                HStack(spacing: 16) {
                    Text(icon)
                        .font(.system(size: 30))
                        .frame(width: 52, height: 52)
                        .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(level.displayName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(description)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .buttonStyle(.plain)
    }
}
