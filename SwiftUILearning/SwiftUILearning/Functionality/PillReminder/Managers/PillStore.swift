import Foundation
import Combine

final class PillStore: ObservableObject {
    @Published private(set) var pills: [Pill] = []
    private let saveKey = "pillstore_v1"

    static let shared = PillStore()

    private var cancellables = Set<AnyCancellable>()

    private init() {
        load()
        $pills
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
    }

    func add(_ pill: Pill) {
        pills.append(pill)
        sort()
    }

    func update(_ pill: Pill) {
        guard let idx = pills.firstIndex(where: { $0.id == pill.id }) else { return }
        pills[idx] = pill
        sort()
    }

    func remove(_ pill: Pill) {
        pills.removeAll { $0.id == pill.id }
    }

    func markTaken(_ pill: Pill, at time: Date = Date()) {
        // Simple history could be implemented later. For now just log.
        print("Marked taken: \(pill.name) at \(time)")
    }

    private func sort() {
        pills.sort { $0.createdAt > $1.createdAt }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(pills)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Save error: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        do {
            pills = try JSONDecoder().decode([Pill].self, from: data)
        } catch {
            print("Load error: \(error)")
        }
    }
}
