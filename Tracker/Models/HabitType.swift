//
//  HabitType.swift
//  Tracker
//
//  Created by Анна Рыкунова on 27.10.2024.
//

import Foundation

enum HabitType {
    case habit
    case event

    var value: String {
        return switch self {
        case .habit: "Новая привычка"
        case .event: "Новое нерегулярное событие"
        }
    }

    var countOfCells: Int {
        return switch self {
        case .habit: 2
        case .event: 1
        }
    }
}
