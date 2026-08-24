//
//  ViewQuoteTVCell.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 10/10/25.
//

import UIKit

class ViewQuoteTVCell: UITableViewCell {

    @IBOutlet weak var lblQuote: UILabel!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Set corner radius
        lblQuote.layer.cornerRadius = 8
        lblQuote.clipsToBounds = true  // Important to make the corner radius visible
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
