//
//  HabitType.swift
//  Tracker
//
//  Created by Анна Рыкунова on 27.10.2024.
//

import Foundation

enum Schedule {
    case regular(Set<Weekday>)
    case irregular(Date)
}

enum HabitType: String {
    case habit = "Новая привычка"
    case event = "Новое нерегулярное событие"
    
    var countOfCells: Int {
        switch self {
        case .habit: return 2
        case .event: return 1
        }
    }
}
