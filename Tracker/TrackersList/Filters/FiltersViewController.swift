//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 30.03.2025.
//

import UIKit

protocol FiltersDelegateProtocol {
    var currentFilter: Filter { get }
    func didSelectFilter(filter: Filter)
}

final class FiltersViewController: UIViewController {
    private let delegate: FiltersDelegateProtocol
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filters.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .background
        table.register(FilterTableCell.self, forCellReuseIdentifier: "cell")
        table.layer.cornerRadius = 16
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    init(delegate: FiltersDelegateProtocol) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupLayout()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.trackEvent(event: .open, params: ["screen": "\(AnalyticsEventData.FiltersScreen.name)"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.trackEvent(event: .close, params: ["screen": "\(AnalyticsEventData.FiltersScreen.name)"])
    }
    
    private func setupLayout() {
        view.addSubviews([titleLabel, tableView])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource и UITableViewDelegate
extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Filter.allCases.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = Filter.allCases.count
        if indexPath.row == count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            let maskPath = UIBezierPath(
                roundedRect: cell.bounds,
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 16.0, height: 16.0)
            )
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            cell.layer.mask = maskLayer
        } else {
            cell.layer.mask = nil
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? FilterTableCell else {
            return UITableViewCell()
        }
        let filter = Filter.allCases[indexPath.row]
        let isSelected = filter == delegate.currentFilter
        cell.configure(text: filter.name, isSelected: isSelected)
        cell.backgroundColor = .cellBackground
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnalyticsService.shared.trackEvent(event: .click, params: AnalyticsEventData.FiltersScreen.selectFilter)
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedFilter = Filter.allCases[indexPath.row]
        delegate.didSelectFilter(filter: selectedFilter)
        dismiss(animated: true)
    }
}
