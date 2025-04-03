//
//  StatisticController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 04.10.2024.
//

import UIKit

final class StatisticsController: UIViewController {
    let statisticsStore = StatisticsStore.shared
    private var countOfCompletedTrackers: Int = 0
    private lazy var placeHolderView: PlaceholderView = {
        let view = PlaceholderView()
        view.setText(text: NSLocalizedString("statistics.placeholder.text", comment: ""))
        view.setImage(byName: "Empty Statistics")
        view.isHidden = true
        return view
    }()
    
    private lazy var completedTrackersView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let item = StatisticsItemView(
            value: "\(statisticsStore.countCompletedTrackers())",
            description: NSLocalizedString("statistics.trackersCompleted", comment: "")
        )
        view.addSubviews([item])
        NSLayoutConstraint.activate([
            item.topAnchor.constraint(equalTo: view.topAnchor),
            item.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            item.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            item.heightAnchor.constraint(equalToConstant: 90)
        ])
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("statistics.title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .background
        
        view.addSubviews([placeHolderView, completedTrackersView])
        addConstrains()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadStatistics()
    }
    
    private func addConstrains() {
        NSLayoutConstraint.activate([
            placeHolderView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeHolderView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            completedTrackersView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            completedTrackersView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            completedTrackersView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            completedTrackersView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func loadStatistics() {
        countOfCompletedTrackers = statisticsStore.countCompletedTrackers()
        let isShowStatistics = countOfCompletedTrackers > 0
        if isShowStatistics {
            reloadCount()
        }
        completedTrackersView.isHidden = !isShowStatistics
        placeHolderView.isHidden = isShowStatistics
        
    }
    
    private func reloadCount() {
        completedTrackersView.subviews.forEach { $0.removeFromSuperview() }
        let item = StatisticsItemView(
            value: "\(countOfCompletedTrackers)",
            description: NSLocalizedString("statistics.trackersCompleted", comment: "")
        )
        completedTrackersView.addSubviews([item])
        NSLayoutConstraint.activate([
            item.topAnchor.constraint(equalTo: completedTrackersView.topAnchor, constant: 77),
            item.leadingAnchor.constraint(equalTo: completedTrackersView.leadingAnchor, constant: 16),
            item.trailingAnchor.constraint(equalTo: completedTrackersView.trailingAnchor, constant: -16),
            item.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}
