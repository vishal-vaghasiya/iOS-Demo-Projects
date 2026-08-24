//
//  SignatureController.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit

class SignatureController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Properties
    let viewModel = SignatureViewModel()
    var didPickSignatureHandler: ((_ signature: String) -> ())?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingIndicator.stopAnimating()
    }
    
    func setupView() {
        title = "Choose Signature"
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissViewController))
        cancelButton.tintColor = .gray
        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.navigationBar.backgroundColor = .appCell
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Methods
    func setupViewModel() {
        viewModel.didFillSignatureHandler = {
            self.tableView.reloadData()
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true
        }
        
        viewModel.fillSignature()
    }
    
}
