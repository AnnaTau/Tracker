//
//  TrackersCollectionLayoutParams.swift
//  Tracker
//
//  Created by Анна Рыкунова on 19.12.2024.
//

import UIKit

struct TrackersCollectionLayoutParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(
        cellCount: Int,
        leftInset: CGFloat,
        rightInset: CGFloat,
        cellSpacing: CGFloat
    ) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}
