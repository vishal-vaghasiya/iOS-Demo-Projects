//
//  ThirdVm.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 26/03/24.
//

import Foundation

final class ThirdVm: BaseVm {
    // MARK: - Properties
    var handler: Handler<Output>?
    
    // MARK: - Enums
    enum Input {
        case goto
    }
    
    enum Output {
        case isLoading(isLoading: Bool)
        case showAlert(message: String)
    }
    
    // MARK: - Life-Cycle
    func send(_ input: Input) {
        switch input { 
        case .goto:
            router.setRoot(to: .main)
        }
    }
    
    // MARK: - Fuctions
}
