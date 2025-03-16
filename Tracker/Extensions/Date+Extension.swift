//
//  Date+Extension.swift
//  Tracker
//
//  Created by Анна Рыкунова on 21.01.2025.
//

import Foundation

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}
