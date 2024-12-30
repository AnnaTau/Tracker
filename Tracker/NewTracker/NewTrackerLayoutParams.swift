//
//  NewTrackerLayoutParams.swift
//  Tracker
//
//  Created by Анна Рыкунова on 27.12.2024.
//

import UIKit

struct NewTrackerLayoutParams {
    let leftOrRightInset: CGFloat
    let topOrBottomInset: CGFloat
    let cellSpacing: CGFloat
    let itemsInRow: CGFloat
    
    init(
        leftOrRightInset: CGFloat,
        topOrBottomInset: CGFloat,
        cellSpacing: CGFloat,
        itemsInRow: CGFloat
    ) {
        self.leftOrRightInset = leftOrRightInset
        self.topOrBottomInset = topOrBottomInset
        self.cellSpacing = cellSpacing
        self.itemsInRow = itemsInRow
    }
}
