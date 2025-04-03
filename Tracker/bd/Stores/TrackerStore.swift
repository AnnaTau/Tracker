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
    
    private lazy var fetchedPinnedController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        fetchRequest.predicate = getPredicateForPinned()
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
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
        updateFetchRequestForPinned()
        guard let sections = fetchedResultsController.sections else { return [] }
        guard let pinnedObjects = fetchedPinnedController.fetchedObjects else { return [] }
        var trackerCategories: [TrackerCategory] = []
        
        let pinnedTrackers = pinnedObjects.compactMap { getTracker(from: $0) }
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(name: NSLocalizedString("trackers.pinned.category", comment: ""), trackers: pinnedTrackers)
            trackerCategories.append(pinnedCategory)
        }
        
        for section in sections {
            guard let objects = section.objects as? [TrackerCoreData] else { continue }
            let trackers: [Tracker] = objects.compactMap { getTracker(from: $0) }
            let trackerCategory = TrackerCategory(name: section.name, trackers: trackers)
            trackerCategories.append(trackerCategory)
        }
        return trackerCategories
    }
    
    func fetchTrackers(for searchString: String) -> [TrackerCategory] {
        updateFetchRequest(searchString: searchString)
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
        trackerCD.isPinned = tracker.isPinned
        guard let schedule = tracker.schedule else {
            preconditionFailure("Failure with adding tracker")
        }
        trackerCD.schedule = Int32(schedule.rawValue)
        trackerCD.date = tracker.date
        trackerCD.category = categoryCoreData
        PersistentService.shared.saveContext()
    }
    
    func editTracker(tracker: Tracker, category: String) {
        guard let categoryCoreData = findCategory(by: category) else {
            preconditionFailure("Failure with editing tracker")
        }
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        guard let trackerCoreData = try? context.fetch(fetchRequest).first else {
            preconditionFailure("Failure with editing tracker")
        }
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = UIColor.hexString(from: tracker.color)
        if let schedule = tracker.schedule {
            trackerCoreData.schedule = Int32(schedule.rawValue)
        }
        trackerCoreData.category = categoryCoreData
        PersistentService.shared.saveContext()
    }
    
    func togglePinned(for trackerID: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        do {
            if let trackerCoreData = try context.fetch(fetchRequest).first {
                trackerCoreData.isPinned.toggle()
                try context.save()
            } else {
                print("tracker with id \(trackerID) not found")
            }
        } catch {
            print("failed to toggle pinned state for tracker with id \(trackerID)")
        }
    }
    
    func deleteAll() {
        let trackerFetchRequest: NSFetchRequest<NSFetchRequestResult> = TrackerCoreData.fetchRequest()
        let trackerCategoryFetchRequest: NSFetchRequest<NSFetchRequestResult> = TrackerCategoryCoreData.fetchRequest()
        let trackerRecordFetchRequest: NSFetchRequest<NSFetchRequestResult> = TrackerRecordCoreData.fetchRequest()
        
        let deleteTrackerRequest = NSBatchDeleteRequest(fetchRequest: trackerFetchRequest)
        let deleteCategoryRequest = NSBatchDeleteRequest(fetchRequest: trackerCategoryFetchRequest)
        let deleteRecordRequest = NSBatchDeleteRequest(fetchRequest: trackerRecordFetchRequest)
        
        do {
            try context.execute(deleteTrackerRequest)
            try context.execute(deleteCategoryRequest)
            try context.execute(deleteRecordRequest)
            PersistentService.shared.saveContext()
        } catch {
            print("Failed to delete all data from Core Data")
        }
    }
    
    // MARK: - Private methods
    
    private func getTracker(from tracker: TrackerCoreData) -> Tracker {
        let isHabit = tracker.isHabit
        let isPinned = tracker.isPinned
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
            isPinned: isPinned,
            schedule: Weekdays(rawValue: schedule),
            date: date
        )
    }
    
    private func findCategory(by title: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", title)
        if let fetchedCategory = try? context.fetch(fetchRequest).first {
            return fetchedCategory
        }
        return nil
    }
    
    func categoryFor(trackerID: UUID) -> String {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        guard let trackerCoreData = try? context.fetch(fetchRequest).first,
              let categoryName = trackerCoreData.category?.name
        else {
            preconditionFailure("Category name not found for tracker with id \(trackerID)")
        }
        return categoryName
    }
    
    private func getPredicateFor(date: Date) -> NSPredicate {
        let calendar = Calendar.current
        let currentWeekdayInt = calendar.component(.weekday, from: date)
        guard let currentWeekday = Weekdays.fromGregorianStyle(currentWeekdayInt)?.rawValue else {
            preconditionFailure("Failure with getting current weekday")
        }
        let dateStart = date.startOfDay() as NSDate
        let datePredicate = NSPredicate(format: "date == %@", dateStart)
        let isPinnedPredicate = NSPredicate(format: "isPinned == false")
        let notHabitPredicate = NSPredicate(format: "isHabit == false")
        let dateAndNoSchedulePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, notHabitPredicate, isPinnedPredicate])
        let scheduleContainsDayPredicate = NSPredicate(format: "(schedule & %d) != 0", currentWeekday)
        let isHabitPredicate = NSPredicate(format: "isHabit == true")
        let habitAndSchedulePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [scheduleContainsDayPredicate, isHabitPredicate, isPinnedPredicate])
        let finalPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [dateAndNoSchedulePredicate, habitAndSchedulePredicate])
        return finalPredicate
    }
    
    private func getPredicateFor(searchString: String) -> NSPredicate {
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchString)
        return predicate
    }
    
    private func getPredicateForPinned() -> NSPredicate {
        let predicate = NSPredicate(format: "isPinned == true")
        return predicate
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
    
    private func updateFetchRequest(searchString: String) {
        let fetchRequest = fetchedResultsController.fetchRequest
        fetchRequest.predicate = getPredicateFor(searchString: searchString)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            preconditionFailure("Failed to fetch filtered results")
        }
    }
    
    private func updateFetchRequestForPinned() {
        let fetchRequest = fetchedPinnedController.fetchRequest
        fetchRequest.predicate = getPredicateForPinned()
        do {
            try fetchedPinnedController.performFetch()
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
