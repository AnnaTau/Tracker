//
//  TrackerStoreDelegate.swift
//  Tracker
//
//  Created by Анна Рыкунова on 27.01.2025.
//

protocol TrackerStoreDelegate: AnyObject {
    func store(didChangeContentWith update: IndexUpdate)
}
