//
//  LoginCoordinator.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import UIKit

final class LoginCoordinator {

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = StoryboardScene.Login.loginViewController.instantiate()
        let viewModel = LoginViewModel(service: LoginService())
        vc.inject(viewModel: viewModel)
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    func navigateToHome() {
        let homeVC = UIViewController() // replace later
        navigationController.setViewControllers(
            [homeVC],
            animated: true
        )
    }
    
    func navigateToRegister() {
        /*let storyboard = UIStoryboard(
            name: "Register",
            bundle: Bundle(for: RegisterViewController.self)
        )

        let vc = storyboard.instantiateViewController(
            identifier: "RegisterViewController"
        ) as! RegisterViewController

        let viewModel = RegisterViewModel(service: RegisterService())
        vc.inject(viewModel: viewModel)
        vc.coordinator = self

        navigationController.pushViewController(vc, animated: true)*/
    }
}
