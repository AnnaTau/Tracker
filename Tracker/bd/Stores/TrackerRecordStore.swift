//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Анна Рыкунова on 15.01.2025.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    static let shared = TrackerRecordStore()
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore.shared
    
    convenience init() {
        let context = PersistentService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecord(_ record: TrackerRecord) {
        guard let tracker = findTracker(with: record.trackerId) else {
            preconditionFailure("Failure with getting tracker")
        }
        let trackerRecord = TrackerRecordCoreData(context: context)
        trackerRecord.date = record.date
        trackerRecord.trackerId = record.trackerId
        trackerRecord.tracker = tracker
        PersistentService.shared.saveContext()
    }
    
    func findRecordBy(date: Date, trackerId: UUID) -> TrackerRecord? {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let dateStart = date.startOfDay() as NSDate
        let predicate = NSPredicate(format: "trackerId == %@ AND date == %@", trackerId as CVarArg, dateStart)
        request.predicate = predicate
        let trackerRecordsFromCoreData = try? context.fetch(request)
        guard let record = trackerRecordsFromCoreData?.first else { return nil }
        let foundRecord = getRecord(from: record)
        return foundRecord
    }
    
    func findRecordsBy(trackerId: UUID) -> [TrackerRecord] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        request.predicate = predicate
        let trackerRecordsFromCoreData = try? context.fetch(request)
        guard let records = trackerRecordsFromCoreData else { return [] }
        let foundRecords = records.map { getRecord(from: $0) }
        return foundRecords
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let dateStart = record.date.startOfDay() as NSDate
        request.predicate = NSPredicate(format: "trackerId == %@ AND date == %@", record.trackerId as CVarArg, dateStart as CVarArg)
        let trackerRecordsFromCoreData = try? context.fetch(request)
        if let recordForDelete = trackerRecordsFromCoreData?.first {
            context.delete(recordForDelete)
            PersistentService.shared.saveContext()
        }
    }
    
    func deleteTrackerAndRecords(with trackerId: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        guard let trackerCoreData = try? context.fetch(fetchRequest).first else {
            print("tracker with id \(trackerId) not found")
            return
        }
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        request.predicate = predicate
        let trackerRecordsFromCoreData = try? context.fetch(request)
        guard let records = trackerRecordsFromCoreData else { return }
        for record in records {
            context.delete(record)
        }
        context.delete(trackerCoreData)
        PersistentService.shared.saveContext()
        
    }
    
    // MARK: - Private methods
    
    private func findTracker(with id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }
    
    private func getRecord(from trackerRecordCoreData: TrackerRecordCoreData) -> TrackerRecord {
        guard let id = trackerRecordCoreData.trackerId,
              let date = trackerRecordCoreData.date else {
            preconditionFailure("Failure with getting record")
        }
        let trackerRecord = TrackerRecord(trackerId: id, date: date)
        return trackerRecord
    }
}
