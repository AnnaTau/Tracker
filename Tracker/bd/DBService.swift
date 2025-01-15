//
//  DBService.swift
//  Tracker
//
//  Created by Анна Рыкунова on 12.01.2025.
//

import CoreData

final class DBService {
    static let shared = DBService()
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Load Persistent Store failed: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    lazy var context: NSManagedObjectContext = {
        container.viewContext
    }()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
                context.rollback()
            }
        }
    }
}
