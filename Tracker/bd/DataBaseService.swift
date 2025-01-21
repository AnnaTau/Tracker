//
//  DataBaseService.swift
//  Tracker
//
//  Created by Анна Рыкунова on 17.01.2025.
//

import Foundation

protocol DataBaseServiceDelegate: AnyObject {
    func updateTrackers()
}

final class DataBaseService {
    static let shared = DataBaseService()
    weak var delegate: DataBaseServiceDelegate?
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private var trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    
    // MARK: - Tracker Methods
    
    func addTracker(tracker: Tracker, for category: String) {
        trackerCategoryStore.addTrackerToCategory(tracker, category: category)
        delegate?.updateTrackers()
    }
    
    func fetchTrackers(for date: Date) -> [Tracker] {
        trackerStore.fetchTrackers(for: date)
    }
    
    // MARK: - Category Methods
    
    func findCategoriesBy(date: Date) -> [TrackerCategory] {
        trackerCategoryStore.findCategoriesFor(date: date)
    }
    
    func getCategoriesCount() -> Int {
        guard let count = try? trackerCategoryStore.fetchCategories().count
        else { return 1 }
        return count
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let categories = try? trackerCategoryStore.fetchCategories()
        guard let categories else {
            print("Do not fetch Categories")
            return []
        }
        return categories
    }
    
    func addCategory(_ category: TrackerCategory) {
        trackerCategoryStore.addCategory(category)
    }
    
    // MARK: - Record Methods
    
    func fetchRecords() -> Set<TrackerRecord> {
        trackerRecordStore.fetchRecords()
    }
    
    func findRecordBy(date: Date, trackerId: UUID) -> TrackerRecord? {
        trackerRecordStore.findRecordBy(date: date, trackerId: trackerId)
    }
    
    func findAllRecordsBy(trackerId: UUID) -> [TrackerRecord] {
        trackerRecordStore.findRecordsBy(trackerId: trackerId)
    }
    
    func findAllRecordsBy(date: Date) -> [TrackerRecord] {
        trackerRecordStore.findRecordsBy(date: date)
    }
    
    func addRecord(_ record: TrackerRecord) {
        trackerRecordStore.addRecord(record)
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        trackerRecordStore.deleteRecord(record)
    }
}
