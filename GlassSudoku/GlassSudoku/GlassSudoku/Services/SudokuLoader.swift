import Foundation

enum SudokuLoaderError: Error {
    case fileNotFound
    case decodingFailed(Error)
    case noPuzzleForDifficulty(DifficultyLevel)
}

actor SudokuLoader {
    static let shared = SudokuLoader()

    private var cachedPuzzles: [SudokuPuzzle]?

    func loadPuzzles() async throws -> [SudokuPuzzle] {
        if let cached = cachedPuzzles { return cached }

        guard let url = Bundle.main.url(forResource: "sudoku_answers", withExtension: "json") else {
            throw SudokuLoaderError.fileNotFound
        }
        do {
            let data = try Data(contentsOf: url)
            let file = try JSONDecoder().decode(SudokuPuzzleFile.self, from: data)
            cachedPuzzles = file.puzzles
            return file.puzzles
        } catch {
            throw SudokuLoaderError.decodingFailed(error)
        }
    }

    func puzzle(for difficulty: DifficultyLevel) async throws -> SudokuPuzzle {
        let all = try await loadPuzzles()
        let filtered = all.filter { $0.difficulty == difficulty }
        guard let puzzle = filtered.randomElement() else {
            throw SudokuLoaderError.noPuzzleForDifficulty(difficulty)
        }
        return puzzle
    }
}
