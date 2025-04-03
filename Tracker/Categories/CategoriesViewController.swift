//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 12.03.2025.
//

import UIKit

protocol CategoriesViewDelegate: AnyObject {
    func didSelectCategory(category: String)
}

final class CategoriesViewController: UIViewController {
    weak var delegate: CategoriesViewDelegate?
    var selectedCategory: String?
    private var viewModel: TrackerCategoryViewModel?
    
    init(viewModel: TrackerCategoryViewModel = TrackerCategoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("categories.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .commonFont
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .background
        table.register(CategoryTableViewCell.self, forCellReuseIdentifier: "cell")
        table.layer.cornerRadius = 16
        table.isScrollEnabled = false
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    private lazy var addNewCategory: UIButton = {
        let button = UIButton(type: .system)
        let text = NSLocalizedString("categories.button.add", comment: "")
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.darkButtonFont, for: .normal)
        button.backgroundColor = .darkBackground
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let placeHolderView: PlaceholderView = {
        let view = PlaceholderView()
        view.setText(text: NSLocalizedString("categories.placeholder.text", comment: ""))
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupLayout()
        viewModel?.trackerCategoriesBinding = updateTableView
        viewModel?.fetchTrackerCategories()
    }
    
    private func updateTableView(categories: [String?]) {
        tableView.reloadData()
        let isHidden = categories.isEmpty
        tableView.isHidden = isHidden
        placeHolderView.isHidden = !isHidden
    }
    
    private func setupLayout() {
        view.addSubviews([titleLabel, tableView, addNewCategory, placeHolderView])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addNewCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addNewCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addNewCategory.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addNewCategory.heightAnchor.constraint(equalToConstant: 60),
            
            placeHolderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeHolderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeHolderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeHolderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addNewCategory.topAnchor, constant: -24)
        ])
    }
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = self
        newCategoryViewController.modalPresentationStyle = .pageSheet
        present(newCategoryViewController, animated: true, completion: nil)
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.trackerCategories.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = viewModel?.trackerCategories.count ?? 0
        cell.layer.mask = nil
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
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoryTableViewCell
        else { return UITableViewCell() }
        guard let title = viewModel?.trackerCategories[indexPath.row] else {
            print("Title is nil")
            return UITableViewCell()
        }
        cell.configure(text: title, isSelected: title == selectedCategory)
        cell.backgroundColor = .cellBackground
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let category = viewModel?.trackerCategories[indexPath.row] {
            self.selectedCategory = category
            delegate?.didSelectCategory(category: category)
        }
        dismiss(animated: true)
    }
}

extension CategoriesViewController: NewCategoryDelegate {
    func didTapCreateButton(category: String) {
        viewModel?.addTrackerCategory(category: category)
    }
}
