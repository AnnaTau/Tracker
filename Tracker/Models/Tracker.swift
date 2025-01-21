//
//  Tracker.swift
//  Tracker
//
//  Created by Анна Рыкунова on 18.10.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let isHabit: Bool
    let schedule: Weekdays?
    let date: Date?
}
