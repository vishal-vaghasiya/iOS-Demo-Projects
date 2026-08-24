//
//  QuotesTVCell.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 10/10/25.
//

import UIKit

class QuotesTVCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Set corner radius
        lblName.layer.cornerRadius = 8
        lblName.clipsToBounds = true  // Important to make the corner radius visible
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
