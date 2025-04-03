//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Анна Рыкунова on 03.04.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerScreenshotTests: XCTestCase {
    private let reset = false
    
    private var trackerStore = TrackerStore()
    private var trackerCategoryStore = TrackerCategoryStore()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        prepareTestData()
    }
    
    override func tearDownWithError() throws {
        trackerStore.deleteAll()
        try super.tearDownWithError()
    }
    
    private func prepareTestData() {
        trackerStore.deleteAll()
        let category = "Test Category"
        
        let date = Date().startOfDay()
        
        let id1 = UUID()
        let id2 = UUID()
        
        let tracker1 = Tracker(
            id: id1,
            name: "Tracker 1",
            color: UIColor(hex: "FD4C49"),
            emoji: "❤️",
            isHabit: true,
            isPinned: false,
            schedule: Weekdays.all,
            date: Date()
        )
        
        let tracker2 = Tracker(
            id: id2,
            name: "Tracker 2",
            color: UIColor(hex: "35347C"),
            emoji: "🥦",
            isHabit: true,
            isPinned: false,
            schedule: Weekdays.saturday,
            date: Date()
        )
        
        trackerCategoryStore.addCategory(category)
        trackerStore.addTracker(tracker: tracker1, category: category)
        trackerStore.addTracker(tracker: tracker2, category: category)
    }

    func testTrackersViewController() throws {
        let vc = TrackersListViewController()
        
        vc.overrideUserInterfaceStyle = .light
        assertSnapshot(of: vc, as: .image, named: "LightMode", record: reset)
        
        vc.overrideUserInterfaceStyle = .dark
        assertSnapshot(of: vc, as: .image, named: "DarkMode", record: reset)
    }
    
}
