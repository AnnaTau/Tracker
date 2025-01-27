//
//  TrackerStore.swift
//  Tracker
//
//  Created by Анна Рыкунова on 12.01.2025.
//

import UIKit
import CoreData

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?
    static let shared = TrackerStore()
    private let context: NSManagedObjectContext
    private var insertedSections = IndexSet()
    private var deletedSections = IndexSet()
    private var insertedItems = [Int: IndexSet]()
    private var deletedItems = [Int: IndexSet]()
    private var updatedItems = [Int: IndexSet]()
    private var movedItems = [(from: IndexPath, to: IndexPath)]()
    var onDataUpdate: ( (_ update: IndexUpdate) -> Void )?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        fetchRequest.predicate = getPredicateFor(date: Date().startOfDay())
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.name",
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    // MARK: - Inits
    convenience override init() {
        let context = PersistentService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTrackers(for date: Date) -> [TrackerCategory] {
        updateFetchRequest(date: date.startOfDay())
        guard let sections = fetchedResultsController.sections else { return [] }
        var trackerCategories: [TrackerCategory] = []
        for section in sections {
            guard let objects = section.objects as? [TrackerCoreData] else { continue }
            let trackers: [Tracker] = objects.compactMap { getTracker(from: $0) }
            let trackerCategory = TrackerCategory(name: section.name, trackers: trackers)
            trackerCategories.append(trackerCategory)
        }
        return trackerCategories
    }
    
    func addTracker(tracker: Tracker, category: String) {
        guard let categoryCoreData = findCategory(by: category) else {
            preconditionFailure("Failure with adding tracker")
        }
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
        trackerCD.category = categoryCoreData
        PersistentService.shared.saveContext()
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
    
    // MARK: - Private methods
    
    private func findCategory(by title: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", title)
        if let fetchedCategory = try? context.fetch(fetchRequest).first {
            return fetchedCategory
        }
        return nil
    }
    
    private func getPredicateFor(date: Date) -> NSPredicate {
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
        return finalPredicate
    }
    
    private func updateFetchRequest(date: Date) {
        let fetchRequest = fetchedResultsController.fetchRequest
        fetchRequest.predicate = getPredicateFor(date: date)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            preconditionFailure("Failed to fetch filtered results")
        }
    }
    
    private func reset() {
        insertedSections.removeAll()
        deletedSections.removeAll()
        insertedItems.removeAll()
        deletedItems.removeAll()
        updatedItems.removeAll()
        movedItems.removeAll()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reset()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        case .delete:
            deletedSections.insert(sectionIndex)
        default:
            break
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                var indexSet = insertedItems[newIndexPath.section] ?? IndexSet()
                indexSet.insert(newIndexPath.item)
                insertedItems[newIndexPath.section] = indexSet
            }
        case .delete:
            if let indexPath = indexPath {
                var indexSet = deletedItems[indexPath.section] ?? IndexSet()
                indexSet.insert(indexPath.item)
                deletedItems[indexPath.section] = indexSet
            }
        case .update:
            if let indexPath = indexPath {
                var indexSet = updatedItems[indexPath.section] ?? IndexSet()
                indexSet.insert(indexPath.item)
                updatedItems[indexPath.section] = indexSet
            }
        case .move:
            if let fromIndexPath = indexPath, let toIndexPath = newIndexPath {
                movedItems.append((from: fromIndexPath, to: toIndexPath))
            }
        @unknown default:
            fatalError("Unexpected NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = IndexUpdate(
            insertedSections: insertedSections,
            deletedSections: deletedSections,
            insertedItems: insertedItems,
            deletedItems: deletedItems,
            updatedItems: updatedItems,
            movedItems: movedItems
        )
        delegate?.store(didChangeContentWith: update)
        reset()
    }
}
