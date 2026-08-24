//
//  LoginViewController.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - Properties
    private var viewModel: LoginViewModelProtocol!
    weak var coordinator: LoginCoordinator?

    func inject(viewModel: LoginViewModelProtocol) {
        self.viewModel = viewModel
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil, "LoginViewModel must be injected before using LoginViewController")
        bindViewModel()
    }

    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onLoginSuccess = { [weak self] in
            self?.coordinator?.navigateToHome()
        }

        viewModel.onError = { [weak self] message in
            self?.showErrorAlert(message)
        }
    }

    // MARK: - Actions
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        viewModel.login(
            username: "test@mail.com",
            password: "123456"
        )
    }

    @IBAction func registerButtonTapped(_ sender: UIButton) {
        coordinator?.navigateToRegister()
    }
}
