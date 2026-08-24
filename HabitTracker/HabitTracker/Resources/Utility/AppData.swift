//
//  AppData.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 20/08/25.
//

import Foundation

class AppData {
    static let shared = AppData()
    private init() {}

    lazy var arrOfWeekDay: [(name: String, value: Int)] = [
        ("Sunday", 1),
        ("Monday", 2),
        ("Tuesday", 3),
        ("Wednesday", 4),
        ("Thursday", 5),
        ("Friday", 6),
        ("Saturday", 7)
    ]
    
    lazy var arrOfDay: [Int] = {
        let calendar = Calendar.current
        let selectedDate = Date()
        let numberOfDays = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        return Array(1...numberOfDays)
    }()
    
    lazy var arrOfInterval: [(name: String, value: Int)] = [
        ("Every 2 days", 2),
        ("Every 3 days", 3),
        ("Every 4 days", 4),
        ("Every 5 days", 5),
        ("Every 6 days", 6),
        ("Every 7 days", 7),
        ("Every 8 days", 8),
        ("Every 9 days", 9),
        ("Every 10 days", 10),
        ("Every 11 days", 11),
        ("Every 12 days", 12),
        ("Every 13 days", 13),
        ("Every 14 days", 14),
        ("Every 15 days", 15),
        ("Every 16 days", 16),
        ("Every 17 days", 17),
        ("Every 18 days", 18),
        ("Every 19 days", 19),
        ("Every 20 days", 20),
        ("Every 21 days", 21),
        ("Every 22 days", 22),
        ("Every 23 days", 23),
        ("Every 24 days", 24),
        ("Every 25 days", 25),
        ("Every 26 days", 26),
        ("Every 27 days", 27),
        ("Every 28 days", 28),
        ("Every 29 days", 29),
        ("Every 30 days", 30)
    ]
}
