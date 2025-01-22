//
//  TrackerStore.swift
//  Tracker
//
//  Created by Анна Рыкунова on 12.01.2025.
//

import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
            let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)]
            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: #keyPath(TrackerCoreData.name),
                cacheName: nil
            )
            controller.delegate = self
            self.fetchedResultsController = controller
            try? controller.performFetch()
            return controller
        }()
    
    // MARK: - Inits
    convenience override init() {
        let context = PersistentService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addTracker(tracker: Tracker) -> TrackerCoreData {
        let trackerCD = TrackerCoreData(context: context)
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
        PersistentService.shared.saveContext()
        return trackerCD
    }
    
    func getTracker(from tracker: TrackerCoreData) -> Tracker {
        let isHabit = tracker.isHabit
        let schedule = tracker.schedule
        let date = tracker.date
        guard let id = tracker.id,
              let name = tracker.name,
              let color = tracker.colorHex,
              let emoji = tracker.emoji
        else {
            preconditionFailure("Failure with getting tracker")
        }
        return Tracker(
            id: id,
            name: name,
            color: UIColor(hex: color),
            emoji: emoji,
            isHabit: isHabit,
            schedule: Weekdays(rawValue: schedule),
            date: date
        )
    }
    
    func fetchTrackers(for date: Date) -> [Tracker] {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let calendar = Calendar.current
        let currentWeekdayInt = calendar.component(.weekday, from: date)
        guard let currentWeekday = Weekdays.fromGregorianStyle(currentWeekdayInt)?.rawValue else {
            preconditionFailure("Failure with getting current weekday")
        }
        let dateStart = date.startOfDay() as NSDate
        let datePredicate = NSPredicate(format: "date == %@", dateStart)
        let notHabitPredicate = NSPredicate(format: "isHabit == false")
        let dateAndNoSchedulePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, notHabitPredicate])
        let scheduleContainsDayPredicate = NSPredicate(format: "(schedule & %d) != 0", currentWeekday)
        let isHabitPredicate = NSPredicate(format: "isHabit == true")
        let habitAndSchedulePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [scheduleContainsDayPredicate, isHabitPredicate])
        let finalPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [dateAndNoSchedulePredicate, habitAndSchedulePredicate])
        request.predicate = finalPredicate
        let trackersFromCoreData = try? context.fetch(request)
        guard let trackersFromCoreData else { return [] }
        let filteredRecords = trackersFromCoreData.map { getTracker(from: $0) }
        return filteredRecords
    }
    
    func findTracker(with id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {

}
