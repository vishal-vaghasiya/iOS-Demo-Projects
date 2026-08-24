//
//  BaseVc.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 20/03/24.
//

import UIKit

class BaseVc<Model: BaseVm>: UIViewController {
    // MARK: - Properties
    var viewModel: Model?
    
    // MARK: - Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = Model()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Fuctions
}
