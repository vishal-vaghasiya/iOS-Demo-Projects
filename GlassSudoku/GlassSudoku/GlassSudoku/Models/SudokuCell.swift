import Foundation

struct SudokuCell: Identifiable, Equatable {
    let id: UUID = UUID()
    var value: Int         // 0 = empty
    var isFixed: Bool      // prefilled from puzzle
    var isInvalid: Bool = false
    var notes: Set<Int> = []
    var isHinted: Bool = false
}
