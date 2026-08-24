import Foundation
import UIKit
import SwiftUI

enum GameState {
    case idle
    case loading
    case playing
    case paused
    case completed
    case failed
}

@MainActor
final class GameViewModel: ObservableObject {

    // ── Published state ──────────────────────────────────────────────────────
    @Published private(set) var board: SudokuBoard?
    @Published private(set) var gameState: GameState = .idle
    @Published var selectedCell: (row: Int, col: Int)? = nil
    @Published var selectedNumber: Int? = nil
    @Published var isNotesMode: Bool = false
    @Published var mistakeCount: Int = 0
    @Published var errorMessage: String? = nil
    @Published private(set) var conflictKeys: Set<String> = []

    // ── Completion tracking ───────────────────────────────────────────────────
    @Published private(set) var completedRows:  Set<Int> = []
    @Published private(set) var completedCols:  Set<Int> = []
    @Published private(set) var completedBoxes: Set<Int> = []  // 0-8, box = row/3*3 + col/3
    @Published private(set) var flashingCells:  Set<String> = []

    // ── Child ViewModels ─────────────────────────────────────────────────────
    let timerVM = TimerViewModel()
    let adsVM   = AdsViewModel()

    // ── Private ──────────────────────────────────────────────────────────────
    private var currentPuzzle: SudokuPuzzle?
    private var undoStack: [SudokuBoard] = []
    private var redoStack: [SudokuBoard] = []
    private let maxUndoDepth = 30
    private var hasStartedTyping = false

    // ── Load / New Game ──────────────────────────────────────────────────────
    func startNewGame(difficulty: DifficultyLevel) {
        gameState = .loading
        undoStack = []
        redoStack = []
        mistakeCount = 0
        hasStartedTyping = false
        selectedCell = nil
        selectedNumber = nil
        completedRows = []; completedCols = []; completedBoxes = []
        flashingCells = []

        Task {
            do {
                let puzzle = try await SudokuLoader.shared.puzzle(for: difficulty)
                currentPuzzle = puzzle
                let b = SudokuBoard(puzzle: puzzle)
                board = b
                conflictKeys = []
                timerVM.reset()
                gameState = .playing
                recomputeCompletions(in: b, flash: false)
                adsVM.preloadAd()
            } catch {
                errorMessage = "Failed to load puzzle: \(error.localizedDescription)"
                gameState = .idle
            }
        }
    }

    // ── Pause / Resume ───────────────────────────────────────────────────────
    func togglePause() {
        if gameState == .playing {
            gameState = .paused
            timerVM.pause()
            selectedCell = nil
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else if gameState == .paused {
            gameState = .playing
            if hasStartedTyping { timerVM.start() }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // ── Cell Selection ───────────────────────────────────────────────────────
    func selectCell(row: Int, col: Int) {
        guard gameState == .playing else { return }
        if selectedCell?.row == row && selectedCell?.col == col {
            selectedCell = nil
        } else {
            selectedCell = (row, col)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // ── Number Input ─────────────────────────────────────────────────────────
    func inputNumber(_ number: Int) {
        guard gameState == .playing,
              let sel = selectedCell,
              var b = board else { return }

        let cell = b.cells[sel.row][sel.col]
        guard !cell.isFixed else { return }

        if !hasStartedTyping {
            hasStartedTyping = true
            timerVM.start()
        }

        if isNotesMode {
            pushUndo()
            b.toggleNote(number, row: sel.row, col: sel.col)
            board = b
        } else {
            let isWrong = b.solution[sel.row][sel.col] != number
            pushUndo()
            b.setValue(number, row: sel.row, col: sel.col)
            board = b
            conflictKeys = ValidationService.conflicts(in: b.cells, size: b.size, boxRows: b.boxRows, boxCols: b.boxCols)

            if isWrong {
                mistakeCount += 1
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                let limit = currentPuzzle
                    .flatMap { DifficultyLevel(rawValue: $0.difficulty.rawValue)?.mistakeLimit } ?? 5
                if mistakeCount >= limit {
                    gameState = .failed
                    timerVM.stop()
                    return
                }
            } else {
                recomputeCompletions(in: b, flash: true)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            checkCompletion()
        }
    }

    func selectNumber(_ number: Int) {
        selectedNumber = (selectedNumber == number) ? nil : number
    }

    // ── Erase ────────────────────────────────────────────────────────────────
    func clearSelectedCell() {
        guard gameState == .playing,
              let sel = selectedCell,
              var b = board else { return }
        guard !b.cells[sel.row][sel.col].isFixed else { return }
        pushUndo()
        b.clearCell(row: sel.row, col: sel.col)
        board = b
        conflictKeys = ValidationService.conflicts(in: b.cells, size: b.size, boxRows: b.boxRows, boxCols: b.boxCols)
        recomputeCompletions(in: b, flash: false)
    }

    // ── Reset ────────────────────────────────────────────────────────────────
    func resetGame() {
        guard let puzzle = currentPuzzle else { return }
        undoStack = []; redoStack = []
        mistakeCount = 0; hasStartedTyping = false
        let b = SudokuBoard(puzzle: puzzle)
        board = b
        conflictKeys = []
        completedRows = []; completedCols = []; completedBoxes = []
        flashingCells = []
        timerVM.reset()
        gameState = .playing
        selectedCell = nil; selectedNumber = nil
        recomputeCompletions(in: b, flash: false)
    }

    // ── Undo / Redo ──────────────────────────────────────────────────────────
    func undo() {
        guard let prev = undoStack.popLast(), let b = board else { return }
        redoStack.append(b)
        board = prev
        conflictKeys = ValidationService.conflicts(in: prev.cells, size: prev.size, boxRows: prev.boxRows, boxCols: prev.boxCols)
        recomputeCompletions(in: prev, flash: false)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func redo() {
        guard let next = redoStack.popLast() else { return }
        if let b = board { undoStack.append(b) }
        board = next
        conflictKeys = ValidationService.conflicts(in: next.cells, size: next.size, boxRows: next.boxRows, boxCols: next.boxCols)
        recomputeCompletions(in: next, flash: false)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    // ── Hint ─────────────────────────────────────────────────────────────────
    func requestHint(presentingViewController: UIViewController) {
        guard gameState == .playing,
              let sel = selectedCell,
              let b = board,
              !b.cells[sel.row][sel.col].isFixed else { return }
        adsVM.requestHint(presentingViewController: presentingViewController) { [weak self] in
            Task { @MainActor in self?.applyHint(row: sel.row, col: sel.col) }
        }
    }

    private func applyHint(row: Int, col: Int) {
        guard var b = board else { return }
        pushUndo()
        b.applyHint(row: row, col: col)
        board = b
        conflictKeys = ValidationService.conflicts(in: b.cells, size: b.size, boxRows: b.boxRows, boxCols: b.boxCols)
        recomputeCompletions(in: b, flash: true)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        checkCompletion()
    }

    // ── Completion tracking ───────────────────────────────────────────────────
    private func recomputeCompletions(in b: SudokuBoard, flash: Bool) {
        var newRows  = Set<Int>()
        var newCols  = Set<Int>()
        var newBoxes = Set<Int>()
        let S = b.size
        let BR = b.boxRows; let BC = b.boxCols
        let expected = Set(1...S)

        for i in 0..<S {
            let rowVals = (0..<S).map { b.cells[i][$0].value }
            if !rowVals.contains(0) && Set(rowVals) == expected { newRows.insert(i) }

            let colVals = (0..<S).map { b.cells[$0][i].value }
            if !colVals.contains(0) && Set(colVals) == expected { newCols.insert(i) }
        }
        let numBoxRows = S / BR; let numBoxCols = S / BC
        for br in 0..<numBoxRows {
            for bc in 0..<numBoxCols {
                var vals = [Int]()
                for r in 0..<BR { for c in 0..<BC { vals.append(b.cells[br*BR+r][bc*BC+c].value) } }
                if !vals.contains(0) && Set(vals) == expected { newBoxes.insert(br*numBoxCols+bc) }
            }
        }

        if flash {
            let justRows  = newRows.subtracting(completedRows)
            let justCols  = newCols.subtracting(completedCols)
            let justBoxes = newBoxes.subtracting(completedBoxes)
            if !justRows.isEmpty || !justCols.isEmpty || !justBoxes.isEmpty {
                triggerFlash(rows: justRows, cols: justCols, boxes: justBoxes)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }

        completedRows  = newRows
        completedCols  = newCols
        completedBoxes = newBoxes
    }

    private func triggerFlash(rows: Set<Int>, cols: Set<Int>, boxes: Set<Int>) {
        var cells = Set<String>()
        for row in rows  { for col in 0..<9  { cells.insert("\(row),\(col)") } }
        for col in cols  { for row in 0..<9  { cells.insert("\(row),\(col)") } }
        for box in boxes {
            let br = box/3*3; let bc = box%3*3
            for r in 0..<3 { for c in 0..<3 { cells.insert("\(br+r),\(bc+c)") } }
        }
        flashingCells = cells
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            flashingCells = []
        }
    }

    // ── Private helpers ──────────────────────────────────────────────────────
    private func pushUndo() {
        guard let b = board else { return }
        undoStack.append(b)
        redoStack = []
        if undoStack.count > maxUndoDepth { undoStack.removeFirst() }
    }

    private func checkCompletion() {
        guard let b = board, b.isComplete else { return }
        timerVM.stop()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { gameState = .completed }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // ── Highlight helpers ────────────────────────────────────────────────────
    func isHighlighted(row: Int, col: Int) -> Bool {
        guard let sel = selectedCell else { return false }
        return sel.row == row || sel.col == col || sameBox(sel.row, sel.col, row, col)
    }
    func isSelected(row: Int, col: Int) -> Bool { selectedCell?.row == row && selectedCell?.col == col }
    func isSameValue(row: Int, col: Int) -> Bool {
        guard let sel = selectedCell, let b = board else { return false }
        let sv = b.cells[sel.row][sel.col].value
        let cv = b.cells[row][col].value
        return sv != 0 && sv == cv
    }
    func isConflict(row: Int, col: Int) -> Bool { conflictKeys.contains("\(row),\(col)") }
    func isCompletedCell(row: Int, col: Int) -> Bool {
        guard let b = board else { return false }
        let numBoxCols = b.size / b.boxCols
        let boxIdx = (row / b.boxRows) * numBoxCols + (col / b.boxCols)
        return completedRows.contains(row) || completedCols.contains(col) || completedBoxes.contains(boxIdx)
    }
    func isFlashing(row: Int, col: Int) -> Bool { flashingCells.contains("\(row),\(col)") }
    private func sameBox(_ r1: Int, _ c1: Int, _ r2: Int, _ c2: Int) -> Bool {
        guard let b = board else { return false }
        return (r1 / b.boxRows == r2 / b.boxRows) && (c1 / b.boxCols == c2 / b.boxCols)
    }

    // ── App lifecycle ────────────────────────────────────────────────────────
    func handleBackground() {
        if gameState == .playing {
            gameState = .paused
            timerVM.pause()
        }
    }
    func handleForeground() { /* user taps Resume manually */ }
}
