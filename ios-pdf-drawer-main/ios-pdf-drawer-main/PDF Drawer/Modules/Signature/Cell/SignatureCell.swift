//
//  SignatureCell.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit

class SignatureCell: UITableViewCell {

    @IBOutlet weak var imageSignature: UIImageView!
    @IBOutlet weak var lblError: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageSignature.isHidden = false
        lblError.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(with base64Signature: String) {
        
        if let image = base64Signature.convertBase64ToImage() {
            imageSignature.image = image
        } else {
            imageSignature.isHidden = true
            lblError.isHidden = false
        }
        
    }
    
}
