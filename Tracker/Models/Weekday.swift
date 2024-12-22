//
//  Weekday.swift
//  Tracker
//
//  Created by Анна Рыкунова on 18.10.2024.
//

import Foundation

enum Weekday: String {
    
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortName: String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
    
    var number: Int {
        switch self {
        case .monday:
            return 1
        case .tuesday:
            return 2
        case .wednesday:
            return 3
        case .thursday:
            return 4
        case .friday:
            return 5
        case .saturday:
            return 6
        case .sunday:
            return 7
        }
    }
    
    static func at(numberOfDay intValue: Int) -> Weekday? {
        let day: Weekday
        switch intValue {
        case 1:
            day = .monday
        case 2:
            day = .tuesday
        case 3:
            day = .wednesday
        case 4:
            day = .thursday
        case 5:
            day = .friday
        case 6:
            day = .saturday
        case 7:
            day = .sunday
        default:
            return nil
        }
        return day
    }
    
}
