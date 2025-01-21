//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Анна Рыкунова on 15.01.2025.
//

import UIKit
import CoreData

private enum TrackerRecordStoreError: Error {
    case decodingError
}

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    
    convenience init() {
        let context = PersistentService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecord(_ record: TrackerRecord) {
        guard let tracker = trackerStore.findTracker(with: record.trackerId) else {
            preconditionFailure("Failure with getting tracker")
        }
        let trackerRecord = TrackerRecordCoreData(context: context)
        trackerRecord.date = record.date
        trackerRecord.trackerId = record.trackerId
        trackerRecord.tracker = tracker
        PersistentService.shared.saveContext()
    }
    
    private func getRecord(from trackerRecordCoreData: TrackerRecordCoreData) -> TrackerRecord {
        guard let id = trackerRecordCoreData.trackerId,
              let date = trackerRecordCoreData.date
        else { preconditionFailure("Failure with getting record") }
        
        let trackerRecord = TrackerRecord(trackerId: id, date: date)
        return trackerRecord
    }
    
    func fetchRecords() -> Set<TrackerRecord> {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let trackerRecordsFromCoreData = try? context.fetch(request)
        guard let trackerRecordsFromCoreData else {
            return Set()
        }
        let trackerRecords = trackerRecordsFromCoreData.map ({ getRecord(from: $0) })
        return Set(trackerRecords)
    }
    
    func findRecordBy(date: Date, trackerId: UUID) -> TrackerRecord? {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let dateStart = Calendar.current.startOfDay(for: date) as NSDate
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
    
    func findRecordsBy(date: Date) -> [TrackerRecord] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let dateStart = Calendar.current.startOfDay(for: date) as NSDate
        let predicate = NSPredicate(format: "date == %@", dateStart)
        request.predicate = predicate
        let trackerRecordsFromCoreData = try? context.fetch(request)
        guard let records = trackerRecordsFromCoreData else { return [] }
        let foundRecords = records.map { getRecord(from: $0) }
        return foundRecords
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let dateStart = Calendar.current.startOfDay(for: record.date) as NSDate
        request.predicate = NSPredicate(format: "trackerId == %@ AND date == %@", record.trackerId as CVarArg, dateStart as CVarArg)
        let trackerRecordsFromCoreData = try? context.fetch(request)
        if let recordForDelete = trackerRecordsFromCoreData?.first {
            context.delete(recordForDelete)
            PersistentService.shared.saveContext()
        }
    }
}
