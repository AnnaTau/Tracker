//
//  StatisticsNavigationsController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 07.10.2024.
//

import UIKit

final class StatisticsNavigationsController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = StatisticsController()
        pushViewController(view, animated: true)
    }
    
}
