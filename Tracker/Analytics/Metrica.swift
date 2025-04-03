//
//  Metrica.swift
//  Tracker
//
//  Created by Анна Рыкунова on 03.04.2025.
//

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum Parameters: String {
    case screen
    case item
}

enum AnalyticsEventData {
    enum MainScreen {
        static let name = "Main"
        static let clickAddTracker: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "add_tracker"
        ]
        static let clickFilter: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "filter"
        ]
        static let clickEdit: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "edit"
        ]
        static let clickDelete: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "delete"
        ]
        static let clickTracker: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "track"
        ]
    }
    
    enum TrackersTypeScreen {
        static let name = "TrackersType"
        static let clickAddTracker: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "add_tracker"
        ]
        static let clickAddIrregularEvent: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "add_irregularEvent"
        ]
    }
    
    enum NewTrackerScreen {
        static let name = "NewTracker"
        static let clickSave: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "save"
        ]
        static let clickCancel: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "cancel"
        ]
    }
    
    enum FiltersScreen {
        static let name = "Filters"
        static let selectFilter: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "select_filter"
        ]
    }
    
    enum NewCategoryScreen {
        static let name = "NewCategory"
        static let clickCreate: [AnyHashable: Any] = [
            Parameters.screen.rawValue: name,
            Parameters.item.rawValue: "create"
        ]
    }
    
    enum CategoriesScreen {
        static let name = "Categories"
    }
    
    enum StatisticsScreen {
        static let name = "Statistics"
    }
}
