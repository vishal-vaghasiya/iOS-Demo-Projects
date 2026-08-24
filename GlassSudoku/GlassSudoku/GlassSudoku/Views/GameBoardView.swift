import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: GameViewModel

    private var gridSize: Int { viewModel.board?.size ?? 9 }

    private var cellSize: CGFloat {
        let total = UIScreen.main.bounds.width - 32  // subtract card padding
        return total / CGFloat(gridSize)
    }

    var body: some View {
        GlassCard(cornerRadius: 16, padding: 0) {
            ZStack {
                boardGrid
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                if viewModel.gameState == .paused {
                    pauseOverlay
                }
            }
        }
        .padding(.horizontal, 8)
    }

    // ── Grid ──────────────────────────────────────────────────────────────────
    private var boardGrid: some View {
        Group {
            if let board = viewModel.board {
                VStack(spacing: 0) {
                    ForEach(0..<gridSize, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<gridSize, id: \.self) { col in
                                SudokuCellView(
                                    cell:          board.cells[row][col],
                                    row:           row,
                                    col:           col,
                                    isSelected:    viewModel.isSelected(row: row, col: col),
                                    isHighlighted: viewModel.isHighlighted(row: row, col: col),
                                    isSameValue:   viewModel.isSameValue(row: row, col: col),
                                    isConflict:    viewModel.isConflict(row: row, col: col),
                                    isCompleted:   viewModel.isCompletedCell(row: row, col: col),
                                    isFlashing:    viewModel.isFlashing(row: row, col: col),
                                    boxRows:       board.boxRows,
                                    boxCols:       board.boxCols,
                                    gridSize:      gridSize,
                                    onTap:         { viewModel.selectCell(row: row, col: col) }
                                )
                                .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            } else {
                ProgressView()
                    .tint(.white)
                    .frame(width: cellSize * CGFloat(gridSize),
                           height: cellSize * CGFloat(gridSize))
            }
        }
    }

    // ── Pause overlay ─────────────────────────────────────────────────────────
    private var pauseOverlay: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
            VStack(spacing: 14) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.white.opacity(0.85))
                    .symbolEffect(.pulse, isActive: true)
                Text("Paused")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("Tap to resume")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
        .onTapGesture { viewModel.togglePause() }
        .animation(.easeInOut(duration: 0.2), value: viewModel.gameState)
    }
}
