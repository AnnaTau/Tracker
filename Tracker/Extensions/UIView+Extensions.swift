//
//  UIView+Extensions.swift
//  Tracker
//
//  Created by Анна Рыкунова on 07.10.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}
