//
//  MainVm.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 20/03/24.
//

import Foundation

final class MainVm: BaseVm {
    // MARK: - Properties
    var handler: Handler<Output>?
    
    // MARK: - Enums
    enum Input {
        case viewDidLoad
        case gotoSecondVc
    }
    
    enum Output {
        case isLoading(isLoading: Bool)
        case showAlert(message: String)
    }
    
    // MARK: - Life-Cycle
    func send(_ input: Input) {
        switch input {
        case .viewDidLoad:
            self.scheduleNotification()
        case .gotoSecondVc:
            self.router.push(to: .second)
        }
    }
    
    // MARK: - Fuctions
    private func scheduleNotification() {
        notificationService.scheduleNotification(for: .test)
    }
}
