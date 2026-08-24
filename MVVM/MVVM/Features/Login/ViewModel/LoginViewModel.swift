//
//  LoginViewModel.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//
import Foundation

final class LoginViewModel: LoginViewModelProtocol {
    var onLoginSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?

    private let service: LoginServiceProtocol

    init(service: LoginServiceProtocol) {
        self.service = service
    }

    func login(username: String, password: String) {
        onLoadingStateChange?(true)

        service.login(username: username, password: password) { [weak self] result in
            guard let self = self else { return }

            self.onLoadingStateChange?(false)

            switch result {
            case .success:
                self.onLoginSuccess?()

            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
}
