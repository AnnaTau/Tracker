//
//  UIView+Extensions.swift
//  Tracker
//
//  Created by Анна Рыкунова on 07.10.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
}
