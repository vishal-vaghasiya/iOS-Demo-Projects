import SwiftUI

struct SudokuCellView: View {
    let cell:          SudokuCell
    let row:           Int
    let col:           Int
    let isSelected:    Bool
    let isHighlighted: Bool
    let isSameValue:   Bool
    let isConflict:    Bool
    let isCompleted:   Bool
    let isFlashing:    Bool
    let boxRows:       Int      // 2 for 6×6, 3 for 9×9
    let boxCols:       Int      // 3 for 6×6, 3 for 9×9
    let gridSize:      Int      // 6 or 9
    let onTap:         () -> Void

    @State private var popScale:    CGFloat = 1.0
    @State private var flashOpacity: Double = 0.0

    // ── Background ────────────────────────────────────────────────────────────
    private var bgColor: Color {
        if isSelected    { return Color.white.opacity(0.30) }
        if isSameValue   { return Color.white.opacity(0.16) }
        if isCompleted   { return Color(hex: "#22C55E").opacity(0.16) }
        if isHighlighted { return Color.white.opacity(0.08) }
        return Color.clear
    }

    // ── Text colour ───────────────────────────────────────────────────────────
    private var textColor: Color {
        if isConflict              { return Color(hex: "#F87171") }
        if cell.isHinted           { return Color(hex: "#A78BFA") }
        if isCompleted && !cell.isFixed { return Color(hex: "#86EFAC") }
        if cell.isFixed            { return .white }
        return Color(hex: "#93C5FD")
    }

    // ── Box-edge borders ──────────────────────────────────────────────────────
    private var topThick:     Bool { row % boxRows == 0 }
    private var leadingThick: Bool { col % boxCols == 0 }
    private var isLastRow:    Bool { row == gridSize - 1 }
    private var isLastCol:    Bool { col == gridSize - 1 }

    var body: some View {
        ZStack {
            bgColor
                .animation(.easeInOut(duration: 0.2), value: isCompleted)
                .animation(.easeInOut(duration: 0.15), value: isSelected)

            // Completion flash burst
            Color(hex: "#22C55E")
                .opacity(flashOpacity)
                .allowsHitTesting(false)

            if cell.value != 0 {
                Text("\(cell.value)")
                    .font(.system(
                        size: gridSize == 6 ? 24 : 20,
                        weight: cell.isFixed ? .bold : .semibold,
                        design: .rounded
                    ))
                    .foregroundStyle(textColor)
                    .scaleEffect(popScale)
            } else if !cell.notes.isEmpty {
                notesGrid
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Top border
        .overlay(alignment: .top) {
            Rectangle()
                .frame(height: topThick ? 1.5 : 0.4)
                .foregroundStyle(Color.white.opacity(topThick ? 0.35 : 0.10))
        }
        // Leading border
        .overlay(alignment: .leading) {
            Rectangle()
                .frame(width: leadingThick ? 1.5 : 0.4)
                .foregroundStyle(Color.white.opacity(leadingThick ? 0.35 : 0.10))
        }
        // Outer edges
        .overlay(alignment: .trailing) {
            Rectangle().frame(width: isLastCol ? 1.5 : 0)
                .foregroundStyle(Color.white.opacity(0.35))
        }
        .overlay(alignment: .bottom) {
            Rectangle().frame(height: isLastRow ? 1.5 : 0)
                .foregroundStyle(Color.white.opacity(0.35))
        }
        // Selection ring
        .overlay(
            isSelected ?
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.white.opacity(0.85), lineWidth: 1.5)
                .padding(1)
            : nil
        )
        // Completed unit ring
        .overlay(
            isCompleted && !isSelected ?
            Rectangle().stroke(Color(hex: "#22C55E").opacity(0.35), lineWidth: 0.5)
            : nil
        )
        .scaleEffect(isSelected ? 1.06 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.65), value: isSelected)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .onChange(of: cell.value)   { _, _ in animatePop() }
        .onChange(of: isFlashing)   { _, flashing in if flashing { animateFlash() } }
    }

    // ── Notes grid ────────────────────────────────────────────────────────────
    private var notesGrid: some View {
        let cols = boxCols  // 3 columns of notes regardless
        return LazyVGrid(
            columns: Array(repeating: .init(.flexible(), spacing: 0), count: cols),
            spacing: 0
        ) {
            ForEach(1...gridSize, id: \.self) { n in
                Text(cell.notes.contains(n) ? "\(n)" : "")
                    .font(.system(size: gridSize == 6 ? 8 : 7, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(2)
    }

    // ── Animations ────────────────────────────────────────────────────────────
    private func animatePop() {
        guard cell.value != 0 else { return }
        popScale = 1.35
        withAnimation(.spring(response: 0.28, dampingFraction: 0.45)) { popScale = 1.0 }
    }

    private func animateFlash() {
        flashOpacity = 0.55
        withAnimation(.easeOut(duration: 0.85)) { flashOpacity = 0.0 }
    }
}

// MARK: - Hex colour
extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var val: UInt64 = 0
        Scanner(string: h).scanHexInt64(&val)
        self.init(
            red:   Double((val >> 16) & 0xff) / 255,
            green: Double((val >>  8) & 0xff) / 255,
            blue:  Double( val        & 0xff) / 255
        )
    }
}
