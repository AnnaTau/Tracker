//
//  CollectionData.swift
//  Tracker
//
//  Created by Анна Рыкунова on 24.12.2024.
//

import UIKit

enum NewTrackerSection {
    case emojis
    case colors
}

enum CollectionData {
    static let colors: [UIColor] = [
        UIColor(hex: "#FD4C49"),
        UIColor(hex: "#FF881E"),
        UIColor(hex: "#007BFA"),
        UIColor(hex: "#6E44FE"),
        UIColor(hex: "#33CF69"),
        UIColor(hex: "#E66DD4"),
        UIColor(hex: "#F9D4D4"),
        UIColor(hex: "#34A7FE"),
        UIColor(hex: "#46E69D"),
        UIColor(hex: "#35347C"),
        UIColor(hex: "#FF674D"),
        UIColor(hex: "#FF99CC"),
        UIColor(hex: "#F6C48B"),
        UIColor(hex: "#7994F5"),
        UIColor(hex: "#832CF1"),
        UIColor(hex: "#AD56DA"),
        UIColor(hex: "#8D72E6"),
        UIColor(hex: "#2FD058")
    ]
    
    static let emojis: [String] =
    ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
}
