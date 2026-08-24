//
//  SignatureController + Tableview.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit

extension SignatureController: UITableViewDelegateAndDataSource {
    
    func setupTableView() {
        tableView.initialize(cellClass: SignatureCell.self, delegate: self, dataSource: self)
        tableView.separatorInset = .zero
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.layer.bounds.height / 2.5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getSignatueCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(cellClass: SignatureCell.self)
        cell.configure(with: viewModel.getSignatureAt(index: indexPath.row))
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let signature = self.viewModel.getSignatureAt(index: indexPath.row)
        dismiss(animated: true) {
            self.didPickSignatureHandler?(signature)
        }
    }
    
}
