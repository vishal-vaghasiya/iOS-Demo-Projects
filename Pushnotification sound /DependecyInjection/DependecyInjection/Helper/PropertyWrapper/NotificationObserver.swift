//
//  NotificationObserver.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 29/03/24.
//

import Foundation

@propertyWrapper
class NotificationObserver {
    private let notificationCenter: NotificationCenter
    private let notificationName: Notification.Name
    var handler: ((Notification) -> Void)?

    var wrappedValue: ((Notification) -> Void)? {
        get { return handler }
        set { self.handler = newValue }
    }

    init(notificationName: Notification.Name, center: NotificationCenter = .default) {
        self.notificationCenter = center
        self.notificationName = notificationName

        notificationCenter.addObserver(self, selector: #selector(handleNotification(_:)), name: notificationName, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc private func handleNotification(_ notification: Notification) {
        handler?(notification)
    }
}

extension NotificationCenter {
    @NotificationObserver(notificationName: .test) static var test: ((Notification) -> Void)?
}

extension Notification.Name {
    static let test = Notification.Name("test")
}
