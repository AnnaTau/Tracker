//
//  OnboardingHelper.swift
//  Tracker
//
//  Created by Анна Рыкунова on 11.03.2025.
//

import Foundation

final class OnboardingHelper {
    static let shared = OnboardingHelper()
    private let defaults = UserDefaults.standard
    
    var isOnboarded: Bool {
        get { defaults.bool(forKey: SettingsKey.isOnboarded.rawValue) }
        set { defaults.set(newValue, forKey: SettingsKey.isOnboarded.rawValue) }
    }
    
    private init() {}
    
    private enum SettingsKey: String {
        case isOnboarded
    }
}
