//
//  UIColor+Extension.swift
//  Tracker
//
//  Created by Анна Рыкунова on 24.12.2024.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexFormatted: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        var alpha: CGFloat = 1.0
        
        if hexFormatted.count == 6 {
            Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        } else if hexFormatted.count == 8 {
            Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
            alpha = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            rgbValue = rgbValue & 0x00FFFFFF
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
