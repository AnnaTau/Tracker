//
//  ViewController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 27.09.2024.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerNavigationController = TrackersNavigationController()
        let statisticsNavigationController = StatisticsNavigationsController()
        
        trackerNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Tab Logo Trackers"),
            selectedImage: nil
        )
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Tab Logo Statistics"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackerNavigationController, statisticsNavigationController]
    }

}
