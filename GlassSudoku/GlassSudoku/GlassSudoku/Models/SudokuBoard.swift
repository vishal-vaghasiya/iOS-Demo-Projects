import Foundation

struct SudokuPuzzle: Codable, Identifiable {
    let id: Int
    let difficulty: DifficultyLevel
    let board: [[Int]]
    let solution: [[Int]]
}

struct SudokuPuzzleFile: Codable {
    let puzzles: [SudokuPuzzle]
}

struct SudokuBoard {
    var cells: [[SudokuCell]]
    let solution: [[Int]]
    let difficulty: DifficultyLevel
    let puzzleId: Int

    /// Grid size (6 for Easy, 9 for Medium/Hard)
    var size: Int { difficulty.gridSize }
    /// Box rows/cols
    var boxRows: Int { difficulty.boxRows }
    var boxCols: Int { difficulty.boxCols }

    init(puzzle: SudokuPuzzle) {
        self.solution   = puzzle.solution
        self.difficulty = puzzle.difficulty
        self.puzzleId   = puzzle.id
        self.cells      = puzzle.board.map { row in
            row.map { val in SudokuCell(value: val, isFixed: val != 0) }
        }
    }

    init(cells: [[SudokuCell]], solution: [[Int]], difficulty: DifficultyLevel, puzzleId: Int) {
        self.cells      = cells
        self.solution   = solution
        self.difficulty = difficulty
        self.puzzleId   = puzzleId
    }

    var isComplete: Bool {
        for row in 0..<size {
            for col in 0..<size {
                if cells[row][col].value != solution[row][col] { return false }
            }
        }
        return true
    }

    mutating func setValue(_ value: Int, row: Int, col: Int) {
        guard !cells[row][col].isFixed else { return }
        cells[row][col].value = value
        cells[row][col].notes = []
        validateBoard()
    }

    mutating func clearCell(row: Int, col: Int) {
        guard !cells[row][col].isFixed else { return }
        cells[row][col].value     = 0
        cells[row][col].isInvalid = false
        cells[row][col].notes     = []
    }

    mutating func toggleNote(_ note: Int, row: Int, col: Int) {
        guard !cells[row][col].isFixed, cells[row][col].value == 0 else { return }
        if cells[row][col].notes.contains(note) {
            cells[row][col].notes.remove(note)
        } else {
            cells[row][col].notes.insert(note)
        }
    }

    mutating func applyHint(row: Int, col: Int) {
        guard !cells[row][col].isFixed else { return }
        cells[row][col].value    = solution[row][col]
        cells[row][col].isHinted = true
        cells[row][col].isInvalid = false
        cells[row][col].notes    = []
        validateBoard()
    }

    mutating func validateBoard() {
        for row in 0..<size {
            for col in 0..<size {
                let val = cells[row][col].value
                if val == 0 {
                    cells[row][col].isInvalid = false
                    continue
                }
                cells[row][col].isInvalid = (val != solution[row][col])
            }
        }
    }
}
