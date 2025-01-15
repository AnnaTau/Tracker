//
//  TrackerStore.swift
//  Tracker
//
//  Created by Анна Рыкунова on 12.01.2025.
//

import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    // MARK: - Inits
    convenience init() {
        let context = DBService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addTracker(tracker: Tracker) -> TrackerCD {
        let trackerCD = TrackerCD(context: context)
        trackerCD.id = tracker.id
        trackerCD.name = tracker.name
        trackerCD.emoji = tracker.emoji
        trackerCD.colorHex = UIColor.hexString(from: tracker.color)
        trackerCD.isHabit = tracker.isHabit
        guard let schedule = tracker.schedule else {
            preconditionFailure("Failure with adding tracker")
        }
        trackerCD.schedule = Int32(schedule.rawValue)
        trackerCD.date = tracker.date
        DBService.shared.saveContext()
        return trackerCD
    }
    
    func getTracker(from tracker: TrackerCD) throws -> Tracker {
        let isHabit = tracker.isHabit
        let schedule = tracker.schedule
        guard let id = tracker.id,
              let name = tracker.name,
              let color = tracker.colorHex,
              let emoji = tracker.emoji,
              let date = tracker.date
        else {
            preconditionFailure("Failure with getting tracker")
        }
        return Tracker(
            id: id,
            name: name,
            color: UIColor(hex: color),
            emoji: emoji,
            isHabit: isHabit,
            schedule: Schedule(rawValue: Int(schedule)),
            date: date
        )
    }
}
