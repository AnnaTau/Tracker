//
//  StatisticsStore.swift
//  Tracker
//
//  Created by Анна Рыкунова on 02.04.2025.
//
import CoreData

final class StatisticsStore: NSObject {
    static let shared = StatisticsStore()
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    // MARK: - Inits
    convenience override init() {
        let context = PersistentService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    
    func countCompletedTrackers() -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.schedule != 0 AND tracker.schedule != nil")
        
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            print("Can not count completed trackers")
            return 0
        }
    }
    
}
