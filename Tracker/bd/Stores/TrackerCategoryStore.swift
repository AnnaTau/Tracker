//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Анна Рыкунова on 15.01.2025.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    
    convenience init() {
        let context = DBService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addCategory(_ category: TrackerCategory) {
        let trackerCategory = TrackerCategoryCD(context: context)
        trackerCategory.name = category.name
        trackerCategory.trackers = []
        DBService.shared.saveContext()
    }
    
}
