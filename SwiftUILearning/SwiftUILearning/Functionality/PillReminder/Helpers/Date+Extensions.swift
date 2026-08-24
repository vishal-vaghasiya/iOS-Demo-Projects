import Foundation

extension Date {
    func nextOccurrence(hour: Int, minute: Int) -> Date {
        var cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: self)
        comps.hour = hour
        comps.minute = minute
        return cal.date(from: comps) ?? self
    }
}
