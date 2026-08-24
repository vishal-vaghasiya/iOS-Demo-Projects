import Foundation
import SwiftUI

struct Pill: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var dosage: String
    var times: [Date]
    var repeatRule: RepeatRule
    var notes: String?
    var stockCount: Int?
    var createdAt: Date = Date()

    enum RepeatRule: String, Codable, CaseIterable {
        case daily, weekly, custom
    }
}
