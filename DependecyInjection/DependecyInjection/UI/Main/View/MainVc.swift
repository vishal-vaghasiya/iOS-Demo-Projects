//
//  MainVc.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 20/03/24.
//

import UIKit

class MainVc: BaseVc<MainVm> {
    // MARK: - @IBOutlets
    @IBOutlet weak var lblCount: UILabel!
    
    // MARK: - Properties
    
    // MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        viewModel?.send(.viewDidLoad)
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewModel?.send(.gotoSecondVc)
        }
    }
    
    // MARK: - @IBActions
    
    // MARK: - Fuctions
    private func addObservers() {
        NotificationCenter.test = { [weak self] notification in
            if let count = notification.userInfo?[AnyHashable("count")] as? Int {
                self?.lblCount.text = "\(count)"
            }
        }
    }
    
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
