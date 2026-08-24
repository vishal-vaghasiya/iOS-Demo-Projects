//
//  LoginViewModelProtocol.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import Foundation

protocol LoginViewModelProtocol {

    // MARK: - Outputs
    var onLoginSuccess: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoadingStateChange: ((Bool) -> Void)? { get set }

    // MARK: - Inputs
    func login(username: String, password: String)
}
