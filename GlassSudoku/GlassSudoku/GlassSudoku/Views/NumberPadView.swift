import SwiftUI

struct NumberPadView: View {
    @ObservedObject var viewModel: GameViewModel

    private var range: ClosedRange<Int> {
        viewModel.board?.difficulty.numberRange ?? 1...9
    }
    private var count: Int { range.upperBound }

    // 6 numbers → 3+3 layout, 9 numbers → 3+3+3 layout
    private var columns: [GridItem] {
        let n = count == 6 ? 6 : 9
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: n)
    }

    var body: some View {
        GlassCard(cornerRadius: 20, padding: 14) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(range, id: \.self) { number in
                    NumberButton(
                        number:    number,
                        isSelected: viewModel.selectedNumber == number,
                        remaining: remainingCount(for: number)
                    ) {
                        viewModel.selectNumber(number)
                        viewModel.inputNumber(number)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private func remainingCount(for number: Int) -> Int {
        guard let board = viewModel.board else { return count }
        let S = board.size
        let placed = (0..<S).flatMap { row in
            (0..<S).map { col in board.cells[row][col].value }
        }.filter { $0 == number }.count
        return max(0, S - placed)
    }
}

private struct NumberButton: View {
    let number:    Int
    let isSelected: Bool
    let remaining: Int
    let action:    () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text("\(number)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        remaining == 0 ? .white.opacity(0.2)
                        : isSelected   ? Color(hex: "#818CF8")
                        : .white
                    )

                // Dots showing remaining placements
                HStack(spacing: 2) {
                    ForEach(0..<min(remaining, 5), id: \.self) { _ in
                        Circle()
                            .fill(isSelected ? Color(hex: "#818CF8") : Color.white.opacity(0.45))
                            .frame(width: 3, height: 3)
                    }
                }
                .frame(height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.20) : Color.white.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
        .disabled(remaining == 0)
    }
}
