//
//  NotificationManager.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 20/08/25.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func scheduleHabitNotifications(habit: Habit) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                // Remove old
                if let id = habit.id?.uuidString {
                    center.removePendingNotificationRequests(withIdentifiers: [id])
                }

                // Schedule reminders
                if let reminders = habit.reminders as? [Date] {
                    for reminder in reminders {
                        let content = UNMutableNotificationContent()
                        content.title = "Habit Reminder"
                        content.body = "It's time for your habit: \(habit.name ?? "")"
                        content.sound = .default

                        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder)

                        // Example: repeat daily
                        if RepeatType(rawValue: Int(habit.repeatType)) == .daily {
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                            let request = UNNotificationRequest(
                                identifier: UUID().uuidString,
                                content: content,
                                trigger: trigger
                            )
                            center.add(request)
                        }

                        // You can extend for weekly/monthly by adding weekday/day component
                    }
                }
            }
        }
    }
}
