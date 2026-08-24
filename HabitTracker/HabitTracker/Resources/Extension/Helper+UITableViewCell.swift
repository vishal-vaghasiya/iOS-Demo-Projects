//
//  Helper+UITableView.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 18/08/25.
//

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
