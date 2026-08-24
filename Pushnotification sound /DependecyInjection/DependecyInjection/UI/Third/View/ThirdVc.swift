//
//  ThirdVc.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 26/03/24.
//

import UIKit

final class ThirdVc: BaseVc<ThirdVm> {
    // MARK: - @IBOutlets
    
    // MARK: - Properties
    
    // MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    // MARK: - @IBActions
    @IBAction func onTapButtonGoTo(_ sender: Any) {
        viewModel?.send(.goto)
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
