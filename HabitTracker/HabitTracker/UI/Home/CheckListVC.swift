//
//  CheckListVC.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 19/08/25.
//

import UIKit
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
class CheckListVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var checkListCV: UICollectionView!
    @IBOutlet weak var conHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    var checkListItems: [String] = []
    var onChecklistUpdated: (([String]) -> Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = false
        IQKeyboardToolbarManager.shared.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.isEnabled = true
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        checkListCV.register( UINib(nibName: CheckListCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: CheckListCVCell.identifier)
        checkListCV.register( UINib(nibName: AddCheckListCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: AddCheckListCVCell.identifier)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func backButtonClick(_ sender: UIButton) {
        onChecklistUpdated?(checkListItems)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
// MARK: - UICollectionView Delegate & DataSource
extension CheckListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return checkListItems.count + 1 // +1 for AddCheckList cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < checkListItems.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckListCVCell.identifier, for: indexPath) as! CheckListCVCell
            cell.lblTitle.text = checkListItems[indexPath.item]
            
            cell.btnClear.tag = indexPath.item
            cell.btnClear.addTarget(self, action: #selector(clearButtonTapped(_:)), for: .touchUpInside)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddCheckListCVCell.identifier, for: indexPath) as! AddCheckListCVCell
            cell.txtNewItem.delegate = self
            return cell
        }
    }
    
    // MARK: - CLEAR BUTTON HANDLER
    @objc func clearButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index >= 0 && index < checkListItems.count else { return }
        checkListItems.remove(at: index)
        checkListCV.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.conHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    // cell sizing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

// MARK: - UITextField Delegate
extension CheckListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newItem = textField.text, !newItem.isEmpty {
            checkListItems.append(newItem)
            checkListCV.reloadData()
            textField.text = "" // clear after add
        }
        textField.resignFirstResponder()
        return true
    }
}
