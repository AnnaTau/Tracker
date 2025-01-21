//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Анна Рыкунова on 15.01.2025.
//

import UIKit
import CoreData

private enum TrackerCategoryStoreError: Error {
    case decodingError
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try? controller.performFetch()
        return controller
    }()
    
    convenience override init() {
        let context = PersistentService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addCategory(_ category: TrackerCategory) {
        let allCategories = fetchCategories()
        if allCategories.contains(where: {$0.name == category.name}) {
            return
        }
        let trackerCategory = TrackerCategoryCoreData(context: context)
        trackerCategory.name = category.name
        trackerCategory.trackers = []
        PersistentService.shared.saveContext()
    }
    
    func addTrackerToCategory(_ tracker: Tracker, category name: String) {
        let tracker = trackerStore.addTracker(tracker: tracker)
        let category = fetchedResultsController.fetchedObjects?.first(where: {$0.name == name} )
        category?.addToTrackers(tracker)
        PersistentService.shared.saveContext()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        guard let object = fetchedResultsController.fetchedObjects,
              let categories = try? object.map({ try getCategory(from: $0)})
        else {
            return []
        }
        return categories
    }
    
    func findCategoriesFor(date: Date) -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let calendar = Calendar.current
        let currentWeekdayInt = calendar.component(.weekday, from: date)
        let currentWeekday = Weekdays.fromGregorianStyle(currentWeekdayInt)?.rawValue ?? 0
        let dateStart = calendar.startOfDay(for: date) as NSDate
        let datePredicate = NSPredicate(format: "date == %@", dateStart)
        let scheduleZeroPredicate = NSPredicate(format: "schedule == 0 OR schedule == nil")
        let dateAndNoSchedulePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, scheduleZeroPredicate])
        let scheduleContainsDayPredicate = NSPredicate(format: "(schedule & %d) != 0", currentWeekday)
        let finalPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [dateAndNoSchedulePredicate, scheduleContainsDayPredicate])
        request.predicate = finalPredicate
        let trackersFromCoreData = try? context.fetch(request)
        var categories: [TrackerCategory] = []
        for trackerCoreData in trackersFromCoreData ?? [] {
            if let category = categories.first(where: { $0.name == trackerCoreData.name }) {
                let name = category.name
                let oldTrackers = category.trackers
                let newCategory = TrackerCategory(name: name, trackers: oldTrackers + [trackerStore.getTracker(from: trackerCoreData)])
                guard let index: Int = categories.firstIndex(where: { $0.name == name }) else { continue }
                categories[index] = newCategory
            } else {
                let category = trackerCoreData.category?.name
                let trackers = [trackerStore.getTracker(from: trackerCoreData)]
                let newCategory = TrackerCategory(name: category ?? "", trackers: trackers)
                categories.append(newCategory)
            }
            
        }
        return categories
    }
    
    private func getCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = trackerCategoryCoreData.name,
              let trackersFromCoreData = trackerCategoryCoreData.trackers else {
            throw TrackerCategoryStoreError.decodingError
        }
        
        let trackers = try trackersFromCoreData.compactMap { tracker -> Tracker? in
            guard let trackerCoreData = tracker as? TrackerCoreData else {
                throw TrackerCategoryStoreError.decodingError
            }
            
            do {
                let tracker = try trackerStore.getTracker(from: trackerCoreData)
                return tracker
            } catch {
                print("\(error.localizedDescription)")
                return nil
            }
        }
        return TrackerCategory(name: name, trackers: trackers)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        //  TODO: - добавить обновление таблицы при добавлении новой категории
    }
}
