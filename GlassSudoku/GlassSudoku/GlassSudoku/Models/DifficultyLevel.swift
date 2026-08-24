import Foundation

enum DifficultyLevel: String, CaseIterable, Codable {
    case easy   = "easy"
    case medium = "medium"
    case hard   = "hard"

    var displayName: String { rawValue.capitalized }

    var mistakeLimit: Int {
        switch self {
        case .easy:   return 10
        case .medium: return 7
        case .hard:   return 5
        }
    }

    /// Easy uses a 6×6 grid (numbers 1-6), Medium/Hard use the standard 9×9 grid.
    var gridSize: Int {
        switch self {
        case .easy:           return 6
        case .medium, .hard:  return 9
        }
    }

    /// The set of valid numbers for this difficulty.
    var numberRange: ClosedRange<Int> {
        switch self {
        case .easy:           return 1...6
        case .medium, .hard:  return 1...9
        }
    }

    /// Box dimensions (rows × cols) for the sub-grid.
    var boxRows: Int {
        switch self {
        case .easy:           return 2   // 2×3 boxes in a 6×6 grid
        case .medium, .hard:  return 3   // 3×3 boxes in a 9×9 grid
        }
    }

    var boxCols: Int {
        switch self {
        case .easy:           return 3
        case .medium, .hard:  return 3
        }
    }
}
