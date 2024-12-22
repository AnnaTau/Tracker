//
//  Array+Extension.swift
//  Tracker
//
//  Created by Анна Рыкунова on 09.11.2024.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
