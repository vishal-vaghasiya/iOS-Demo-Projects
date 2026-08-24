//
//  AddCheckListCVCell.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 20/08/25.
//

import UIKit

class AddCheckListCVCell: UICollectionViewCell {
    
    @IBOutlet weak var txtNewItem: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txtNewItem.placeholder = "New Item"
        txtNewItem.returnKeyType = .done
    }

}
