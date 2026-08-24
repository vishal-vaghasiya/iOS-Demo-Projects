//
//  HabitListTVCell.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 20/08/25.
//

import UIKit

class HabitListTVCell: UITableViewCell {
    
    @IBOutlet weak var ivCategoryLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblGoal: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
