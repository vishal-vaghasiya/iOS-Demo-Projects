//
//  UIColor + Extensions.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import UIKit

extension UIColor {
    
//    static let customWhite = UIColor(hex: 0xFFFFFF)
//    static let customBlack = UIColor(hex: 0x000000)
//    static let customCell = UIColor(hex: 0xF2F6F9)
//    
//    static let customPrimary = UIColor(hex: 0x004C46)
//    static let customBlue = UIColor(hex: 0x437F9C)
//    static let customGreen = UIColor(hex: 0x51B749)
//    
//    static let customMainText = UIColor(hex: 0x000000)
//    static let customSubText = UIColor(hex: 0x808080)
//    
//    static let customBorder = UIColor(hex: 0xE5E5EA)
    
    
    // MARK: - Life Cycle
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
    }
    
    convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF, a: a)
    }
    
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
