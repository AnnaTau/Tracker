//
//  IndexUpdate.swift
//  Tracker
//
//  Created by Анна Рыкунова on 27.01.2025.
//

import Foundation

struct IndexUpdate {
    let insertedSections: IndexSet
    let deletedSections: IndexSet
    let insertedItems: [Int: IndexSet]
    let deletedItems: [Int: IndexSet]
    let updatedItems: [Int: IndexSet]
    let movedItems: [(from: IndexPath, to: IndexPath)]
}
