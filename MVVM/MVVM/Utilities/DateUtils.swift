//
//  DateUtils.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import Foundation

struct DateUtils {

    static func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        Calendar.current.isDate(d1, inSameDayAs: d2)
    }

    static func daysBetween(_ from: Date, _ to: Date) -> Int {
        Calendar.current.dateComponents([.day], from: from, to: to).day ?? 0
    }
}
