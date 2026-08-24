//
//  Routable.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 26/03/24.
//

import UIKit

protocol Routable {
    func push(to destination: Destination)
    func present(to destination: Destination)
    func pop()
    func pop(to destination: Destination)
    func setRoot(to destination: Destination)
    func start()
}

class Router: Routable {
    var navigationController: UINavigationController
    let iniatlDestination: Destination
    
    init(navigationController: UINavigationController, iniatlDestination: Destination) {
        self.navigationController = navigationController
        self.iniatlDestination = iniatlDestination
    }
    
    func push(to destination: Destination) {
        self.navigationController.pushViewController(destination.viewController, animated: true)
    }
    
    func present(to destination: Destination) {
        self.navigationController.present(destination.viewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    func pop(to destination: Destination) {
        if let targetViewController = self.navigationController.viewControllers.first(where: { $0.isKind(of: destination.viewController.classForCoder) }) {
            self.navigationController.popToViewController(targetViewController, animated: true)
        }
    }
    
    func setRoot(to destination: Destination) {
        self.navigationController.setViewControllers([destination.viewController], animated: false)
    }
    
    func start() {
        self.navigationController.setViewControllers([iniatlDestination.viewController], animated: true)
    }
}
