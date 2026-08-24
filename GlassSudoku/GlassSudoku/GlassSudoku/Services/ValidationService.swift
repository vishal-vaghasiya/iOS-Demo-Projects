import Foundation

struct ValidationService {

    static func isBoardComplete(_ board: SudokuBoard) -> Bool {
        board.isComplete
    }

    /// Returns "row,col" keys for all cells that conflict (duplicates in row/col/box).
    static func conflicts(in cells: [[SudokuCell]], size: Int, boxRows: Int, boxCols: Int) -> Set<String> {
        var keys = Set<String>()

        for i in 0..<size {
            keys.formUnion(dupeKeys((0..<size).map { j in (i, j, cells[i][j].value) }))
            keys.formUnion(dupeKeys((0..<size).map { j in (j, i, cells[j][i].value) }))
        }

        let numBoxRows = size / boxRows   // e.g. 6/2=3 box rows for 6×6
        let numBoxCols = size / boxCols   // e.g. 6/3=2 box cols for 6×6
        for br in 0..<numBoxRows {
            for bc in 0..<numBoxCols {
                var entries: [(Int, Int, Int)] = []
                for r in 0..<boxRows {
                    for c in 0..<boxCols {
                        let row = br * boxRows + r
                        let col = bc * boxCols + c
                        entries.append((row, col, cells[row][col].value))
                    }
                }
                keys.formUnion(dupeKeys(entries))
            }
        }
        return keys
    }

    private static func dupeKeys(_ entries: [(Int, Int, Int)]) -> Set<String> {
        var seen  = [Int: (Int, Int)]()
        var keys  = Set<String>()
        for (row, col, val) in entries {
            guard val != 0 else { continue }
            if let prev = seen[val] {
                keys.insert("\(prev.0),\(prev.1)")
                keys.insert("\(row),\(col)")
            } else {
                seen[val] = (row, col)
            }
        }
        return keys
    }
}
