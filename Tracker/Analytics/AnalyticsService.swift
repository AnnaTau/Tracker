//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Анна Рыкунова on 03.04.2025.
//

import Foundation
import AppMetricaCore


enum AnalyticsServiceError: Error {
    case createReporterError
}


final class AnalyticsService {
    private static let apiKey = "a2af763e-5466-4e19-9f16-5dcaf72e0d4c"
    static let shared = AnalyticsService()
    
    private init() {}
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: AnalyticsService.apiKey) else { return }
        AppMetrica.activate(with: configuration)
    }
    
    func trackEvent(event: AnalyticsEvent, params: [AnyHashable : Any]) {
        guard let reporter = AppMetrica.reporter(for: AnalyticsService.apiKey) else {
            print("failed to create reporter: \(AnalyticsServiceError.createReporterError.localizedDescription)")
            return
        }
        reporter.resumeSession()
        reporter.reportEvent(name: event.rawValue, parameters: params, onFailure: { error in
            print("failed to report event: \(error.localizedDescription)")
        })
        reporter.pauseSession()
    }
}
