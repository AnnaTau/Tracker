//
//  Schedule.swift
//  Tracker
//
//  Created by Анна Рыкунова on 22.12.2024.
//

import Foundation

struct Schedule: OptionSet {
    let rawValue: Int

    static let monday       = Schedule(rawValue: 1 << 0)
    static let tuesday      = Schedule(rawValue: 1 << 1)
    static let wednesday    = Schedule(rawValue: 1 << 2)
    static let thursday     = Schedule(rawValue: 1 << 3)
    static let friday       = Schedule(rawValue: 1 << 4)
    static let saturday     = Schedule(rawValue: 1 << 5)
    static let sunday       = Schedule(rawValue: 1 << 6)
    
    func toWeekdays() -> [Weekday] {
        var weekdays: [Weekday] = []
        if contains(.monday) { weekdays.append(.monday) }
        if contains(.tuesday) { weekdays.append(.tuesday) }
        if contains(.wednesday) { weekdays.append(.wednesday) }
        if contains(.thursday) { weekdays.append(.thursday) }
        if contains(.friday) { weekdays.append(.friday) }
        if contains(.saturday) { weekdays.append(.saturday) }
        if contains(.sunday) { weekdays.append(.sunday) }
        return weekdays
    }
    
    static func fromArray(_ array: [Weekday]) -> Schedule {
        var schedule: Schedule = []
        if array.contains(.monday) { schedule.insert(.monday) }
        if array.contains(.tuesday) { schedule.insert(.tuesday) }
        if array.contains(.wednesday) { schedule.insert(.wednesday) }
        if array.contains(.thursday) { schedule.insert(.thursday) }
        if array.contains(.friday) { schedule.insert(.friday) }
        if array.contains(.saturday) { schedule.insert(.saturday) }
        if array.contains(.sunday) { schedule.insert(.sunday) }
        return schedule
    }
}
