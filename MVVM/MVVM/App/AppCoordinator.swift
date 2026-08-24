//
//  AppCoordinator.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import UIKit

final class AppCoordinator {

    private let window: UIWindow
    private let navigationController = UINavigationController()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        if isUserLoggedIn() {
            showMainFlow()
        } else {
            showLoginFlow()
        }
    }

    private func showLoginFlow() {
        let coordinator = LoginCoordinator(
            navigationController: navigationController
        )
        coordinator.start()
    }

    private func showMainFlow() {
        // let coordinator = MainTabCoordinator(
        //     navigationController: navigationController
        // )
        // coordinator.start()
    }

    private func isUserLoggedIn() -> Bool {
        UserSession.shared.isLoggedIn
    }
}
