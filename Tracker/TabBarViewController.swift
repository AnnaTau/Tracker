//
//  ViewController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 27.09.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerNavigationController = TrackersNavigationController()
        let statisticsNavigationController = StatisticsNavigationsController()
        
        trackerNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers.title", comment: ""),
            image: UIImage(named: "Tab Logo Trackers"),
            selectedImage: nil
        )
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics.title", comment: ""),
            image: UIImage(named: "Tab Logo Statistics"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackerNavigationController, statisticsNavigationController]
    }

}
