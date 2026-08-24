//
//  NoteTVCell.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 09/10/25.
//

import UIKit

class NoteTVCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with note: Notes) {
        titleLabel.text = note.text
        if let createdAt = note.createdAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: createdAt)
        } else {
            dateLabel.text = ""
        }
    }
}
