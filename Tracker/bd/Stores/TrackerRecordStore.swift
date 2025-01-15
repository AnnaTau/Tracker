//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Анна Рыкунова on 15.01.2025.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = DBService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecord(_ record: TrackerRecord) {
        let trackerRecord = TrackerRecordCD(context: context)
        trackerRecord.date = record.date
//        trackerRecord.trackerId = record.trackerId
        DBService.shared.saveContext()
    }
    
    private func getRecord(from trackerRecordCoreData: TrackerRecordCD) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.trackerId?.id,
              let date = trackerRecordCoreData.date
        else { preconditionFailure("Failure with getting record") }
        
        let trackerRecord = TrackerRecord(trackerId: id, date: date)
        return trackerRecord
    }
}
