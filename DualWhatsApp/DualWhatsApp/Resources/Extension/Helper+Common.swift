//
//  Helper+Common.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation
import UIKit

extension UITableViewCell {
    static var identifier:String{
        return String(describing: self)
    }
    
    static var identifier_iPad:String {
        let identifier = String(describing: self)
        return identifier + "_iPad"
    }
}

extension UICollectionViewCell {
    static var identifier:String{
        return String(describing: self)
    }
    
    static var identifier_iPad:String {
        let identifier = String(describing: self)
        return identifier + "_iPad"
    }
}
