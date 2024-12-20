//
//  Weekday.swift
//  Tracker
//
//  Created by Анна Рыкунова on 18.10.2024.
//

import Foundation

enum Weekday: String {
    
    case MONDAY = "Понедельник"
    case TUESDAY = "Вторник"
    case WEDNESDAY = "Среда"
    case THURSDAY = "Четверг"
    case FRIDAY = "Пятница"
    case SATURDAY = "Суббота"
    case SUNDAY = "Воскресенье"
    
    var shortName: String {
        switch self {
        case .MONDAY:
            return "Пн"
        case .TUESDAY:
            return "Вт"
        case .WEDNESDAY:
            return "Ср"
        case .THURSDAY:
            return "Чт"
        case .FRIDAY:
            return "Пт"
        case .SATURDAY:
            return "Сб"
        case .SUNDAY:
            return "Вс"
        }
    }
    
    var number: Int {
        switch self {
        case .MONDAY:
            return 1
        case .TUESDAY:
            return 2
        case .WEDNESDAY:
            return 3
        case .THURSDAY:
            return 4
        case .FRIDAY:
            return 5
        case .SATURDAY:
            return 6
        case .SUNDAY:
            return 7
        }
    }
    
    static func at(numberOfDay intValue: Int) -> Weekday? {
        let day: Weekday
        switch intValue {
        case 1:
            day = .MONDAY
        case 2:
            day = .TUESDAY
        case 3:
            day = .WEDNESDAY
        case 4:
            day = .THURSDAY
        case 5:
            day = .FRIDAY
        case 6:
            day = .SATURDAY
        case 7:
            day = .SUNDAY
        default:
            return nil
        }
        return day
    }
    
}
