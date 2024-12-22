//
//  NavigationController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 05.10.2024.
//

import UIKit

final class TrackersNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = TrackersListViewController()
        pushViewController(view, animated: true)
    }
    
}
