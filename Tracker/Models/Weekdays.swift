//
//  Weekday.swift
//  Tracker
//
//  Created by Анна Рыкунова on 18.10.2024.
//

import Foundation

struct Weekdays: OptionSet, Sequence {
    let rawValue: Int32
    
    static let monday =    Weekdays(rawValue: 1 << 0)
    static let tuesday =   Weekdays(rawValue: 1 << 1)
    static let wednesday = Weekdays(rawValue: 1 << 2)
    static let thursday =  Weekdays(rawValue: 1 << 3)
    static let friday =    Weekdays(rawValue: 1 << 4)
    static let saturday =  Weekdays(rawValue: 1 << 5)
    static let sunday =    Weekdays(rawValue: 1 << 6)
    static let all: Weekdays = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    var name: String {
        switch self {
        case .monday:
            return NSLocalizedString("weekdays.monday", comment: "")
        case .tuesday:
            return NSLocalizedString("weekdays.tuesday", comment: "")
        case .wednesday:
            return NSLocalizedString("weekdays.wednesday", comment: "")
        case .thursday:
            return NSLocalizedString("weekdays.thursday", comment: "")
        case .friday:
            return NSLocalizedString("weekdays.friday", comment: "")
        case .saturday:
            return NSLocalizedString("weekdays.saturday", comment: "")
        case .sunday:
            return NSLocalizedString("weekdays.sunday", comment: "")
        default:
            return "Unknown day"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday:
            return NSLocalizedString("weekdays.short.monday", comment: "")
        case .tuesday:
            return NSLocalizedString("weekdays.short.tuesday", comment: "")
        case .wednesday:
            return NSLocalizedString("weekdays.short.wednesday", comment: "")
        case .thursday:
            return NSLocalizedString("weekdays.short.thursday", comment: "")
        case .friday:
            return NSLocalizedString("weekdays.short.friday", comment: "")
        case .saturday:
            return NSLocalizedString("weekdays.short.saturday", comment: "")
        case .sunday:
            return NSLocalizedString("weekdays.short.sunday", comment: "")
        default:
            return "Unknown day"
        }
    }
    
    var number: Int? {
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
        default:
            return nil
        }
    }
    
    static func at(numberOfDay intValue: Int) -> Weekdays? {
        let day: Weekdays
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
    
    static func fromGregorianStyle(_ intValue: Int) -> Weekdays? {
        guard intValue >= 1 && intValue <= 7 else { return nil }
        return intValue == 1 ? .sunday : Weekdays(rawValue: 1 << (intValue - 2))
    }
    
    public func makeIterator() -> AnyIterator<Weekdays> {
        var currentBit: Int32 = 1
        return AnyIterator {
            while currentBit < (1 << 7) {
                let day = Weekdays(rawValue: currentBit)
                currentBit <<= 1
                if self.contains(day) {
                    return day
                }
            }
            return nil
        }
    }
}
