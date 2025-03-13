//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Анна Рыкунова on 12.03.2025.
//

typealias Binding<T> = (T) -> Void

protocol StoreDelegate: AnyObject {
    func storeDidUpdate()
}

final class TrackerCategoryViewModel {
    var trackerCategoriesBinding: Binding<[String?]>?
    private(set) var trackerCategories: [String?] = [] {
        didSet { trackerCategoriesBinding?(trackerCategories) }
    }
    private let trackerCategoryStore = TrackerCategoryStore()

    init() { trackerCategoryStore.delegate = self }
        
    func addTrackerCategory(category: String) {
        trackerCategoryStore.addCategory(category)
    }
    
    func fetchTrackerCategories() {
        self.trackerCategories = trackerCategoryStore.fetchAllCategories()
    }
}

extension TrackerCategoryViewModel: StoreDelegate {
    func storeDidUpdate() {
        fetchTrackerCategories()
    }
}
