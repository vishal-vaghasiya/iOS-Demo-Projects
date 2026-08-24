//
//  FancyFontsCell.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 10/10/25.
//

import UIKit

class FancyFontsCell: UITableViewCell {


    // MARK: - OUTLET
    @IBOutlet weak var lblMessage: UILabel!
    
    // MARK: - PROPERTY
    var copyClickEvent: (() -> ())?
    var shareClickEvent: (() -> ())?
    
    // MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func clickCopy(_ sender: UIButton) {
        self.copyClickEvent?()
    }
    
    @IBAction func clickShare(_ sender: UIButton) {
        self.shareClickEvent?()
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
