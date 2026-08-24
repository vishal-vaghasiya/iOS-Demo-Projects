//
//  NotificationManger.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 20/03/24.
//

import Foundation
import UserNotifications

class NotificationManger: NotificationService {
    func scheduleNotification(for notificationType: NotificationType) {
        let content = UNMutableNotificationContent()
        content.title = notificationType.body.title
        content.body = notificationType.body.subTitle
        content.sound = UNNotificationSound(named: UNNotificationSoundName("sound.caf"))

        var dateComponents = DateComponents(calendar: Calendar.current)
        dateComponents.hour = notificationType.time.hour
        dateComponents.minute = notificationType.time.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notificationType.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
