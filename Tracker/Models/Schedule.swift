//
//  Schedule.swift
//  Tracker
//
//  Created by Анна Рыкунова on 22.12.2024.
//

import Foundation

enum Schedule {
    case regular(Set<Weekday>)
    case irregular(Date)
}
