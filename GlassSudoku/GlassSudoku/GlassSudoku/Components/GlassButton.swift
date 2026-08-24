import SwiftUI

struct GlassButton: View {
    let title: String
    var icon: String? = nil
    var style: GlassButtonStyle = .primary
    let action: () -> Void

    enum GlassButtonStyle {
        case primary, secondary, danger, ghost
    }

    private var bgColor: Color {
        switch style {
        case .primary:   return Color.white.opacity(0.18)
        case .secondary: return Color.white.opacity(0.10)
        case .danger:    return Color.red.opacity(0.25)
        case .ghost:     return Color.clear
        }
    }

    private var textColor: Color {
        switch style {
        case .danger: return .red
        default:      return .white
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(textColor)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(bgColor, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
