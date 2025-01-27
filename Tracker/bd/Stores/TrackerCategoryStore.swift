//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Анна Рыкунова on 15.01.2025.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore.shared
    
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
    
    func fetchCategories() -> [TrackerCategory] {
        guard let object = fetchedResultsController.fetchedObjects else { return [] }
        return object.map({ getCategory(from: $0) })
    }
    
    private func getCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory {
        guard let name = trackerCategoryCoreData.name,
              let trackersFromCoreData = trackerCategoryCoreData.trackers else {
            preconditionFailure("Failure with decoding trackerCategoryCoreData")
        }
        let trackers = trackersFromCoreData.compactMap { tracker -> Tracker? in
            guard let trackerCoreData = tracker as? TrackerCoreData else {
                preconditionFailure("Failure with decoding trackerCoreData")
            }
            let tracker = trackerStore.getTracker(from: trackerCoreData)
            return tracker
        }
        return TrackerCategory(name: name, trackers: trackers)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        //  TODO: - добавить обновление таблицы при добавлении новой категории
    }
}
