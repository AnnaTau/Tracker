//
//  TrackerCollectionModel.swift
//  Tracker
//
//  Created by Анна Рыкунова on 25.01.2025.
//

import Foundation

final class TrackerCollectionHelper {
    private let trackerStore = TrackerStore.shared
    private var trackerCategories: [TrackerCategory] = []
    
    func fetchTrackers(for date: Date, completion:() -> Void ) {
        trackerCategories = trackerStore.fetchTrackers(for: date)
        completion()
    }
    
    func numberOfSections() -> Int {
        return trackerCategories.count
    }
    
    func titleForSection(_ section: Int) -> String? {
        guard section >= 0 && section < trackerCategories.count else { return nil }
        return trackerCategories[section].name
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard section >= 0 && section < trackerCategories.count else { return 0 }
        return trackerCategories[section].trackers.count
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let section = indexPath.section
        let row = indexPath.row
        guard section >= 0 && section < trackerCategories.count else { return nil }
        let trackers = trackerCategories[section].trackers
        guard row >= 0 && row < trackers.count else { return nil }
        return trackers[row]
    }
}
