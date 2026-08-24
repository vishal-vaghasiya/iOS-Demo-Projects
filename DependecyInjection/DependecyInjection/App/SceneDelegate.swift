//
//  SceneDelegate.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 20/03/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windoeScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windoeScene)
        configApp(with: .main)
    }
    
    private func configApp(with destination: Destination) {
        let navVc = UINavigationController()
        let router: Routable = Router(navigationController: navVc, iniatlDestination: destination)
        window?.rootViewController = navVc
        window?.makeKeyAndVisible()
        Container.default.registerDependency(for: Routable.self, to: router)
        registerAppDenedency()
        router.start()
    }
    
    private func registerAppDenedency() {
        Container.default.registerDependency(for: NotificationService.self, to: NotificationManger())
    }
}

