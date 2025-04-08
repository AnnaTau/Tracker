//
//  Filter.swift
//  Tracker
//
//  Created by Анна Рыкунова on 30.03.2025.
//

import Foundation

enum Filter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted
    
    var name: String {
        switch self {
        case .all:
            return NSLocalizedString("filters.all", comment: "")
        case .today:
            return NSLocalizedString("filters.today", comment: "")
        case .completed:
            return NSLocalizedString("filters.completed", comment: "")
        case .uncompleted:
            return NSLocalizedString("filters.uncompleted", comment: "")
        }
    }
}
