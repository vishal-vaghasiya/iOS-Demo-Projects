//
//  SecondVc.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 26/03/24.
//

import UIKit

final class SecondVc: BaseVc<SecondVm> {
    // MARK: - @IBOutlets
    
    // MARK: - Properties
    
    // MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        bindViewModel()
    }
    
    // MARK: - @IBActions
    @IBAction func onTapButtonGoToNext(_ sender: Any) {
        viewModel?.send(.gotoNext)
    }
    
    // MARK: - Fuctions
    private func bindViewModel() {
        viewModel?.handler = { event in
            switch event {
            case .isLoading(let isLoading):
                print(isLoading)
            case .showAlert(let message):
                print(message)
            }
        }
    }
}
