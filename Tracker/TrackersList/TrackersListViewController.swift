//
//  TrackersListViewController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 03.10.2024.
//

import UIKit

final class TrackersListViewController: UIViewController {
    let trackerStore = TrackerStore.shared
    let trackerRecordStore = TrackerRecordStore.shared
    let trackerCategoryStore = TrackerCategoryStore.shared
    private(set) var collectionHelper: TrackerCollectionHelper?
    private lazy var currentDate: Date = { Date().startOfDay() }()
    private(set) var currentFilter: Filter = .all
    
    private let addTrackerButton: UIButton = .init()
    private let datePicker: UIDatePicker = .init()
    private let params: TrackersLayoutParams = TrackersLayoutParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9
    )
    
    private let placeholder: PlaceholderView = {
        let view = PlaceholderView()
        view.setText(text: NSLocalizedString("trackers.placeholder.text", comment: ""))
        view.isHidden = true
        return view
    }()
    
    private let placeholderSearch: PlaceholderView = {
        let view = PlaceholderView()
        view.setText(text: NSLocalizedString("trackers.search_placeholder.text", comment: ""))
        view.setImage(byName: "Nothing found")
        view.isHidden = true
        return view
    }()
    
    private lazy var trackerCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .background
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        collectionView.register(TrackerCollectionCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("trackers.filter_button.text", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageButton = UIImage(named: "Add tracker")
        addTrackerButton.setImage(imageButton, for: .normal)
        addTrackerButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale.current
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.title = NSLocalizedString("trackers.title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .background
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self

        view.addSubviews([placeholder, placeholderSearch, trackerCollectionView, filterButton])
        addConstraints()
        configureStore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.trackEvent(event: .open, params: ["screen": "\(AnalyticsEventData.MainScreen.name)"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.trackEvent(event: .close, params: ["screen": "\(AnalyticsEventData.MainScreen.name)"])
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeholderSearch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderSearch.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderSearch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderSearch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureStore() {
        trackerStore.delegate = self
        collectionHelper = TrackerCollectionHelper()
        fetchTrackers(for: currentDate)
    }
    
    func updateCollection() {
        switch currentFilter {
        case .all:
            fetchTrackers(for: currentDate)
        case .today:
            fetchTrackers(for: Date())
        case .completed:
            fetchTrackers(for: currentDate, isDone: true)
        case .uncompleted:
            fetchTrackers(for: currentDate, isDone: false)
        }
    }
    
    private func fetchTrackers(for date: Date) {
        collectionHelper?.fetchTrackers(for: date){ [weak self] in
            guard let self,
                  let collectionHelper
            else { return }
            self.trackerCollectionView.reloadData()
            let numberOfSections = collectionHelper.numberOfSections()
            let isHidden = numberOfSections > 0
            self.trackerCollectionView.isHidden = !isHidden
            self.placeholder.isHidden = isHidden
            self.placeholderSearch.isHidden = true
            self.filterButton.isHidden = !isHidden
        }
    }
    
    private func fetchTrackers(for date: Date, isDone: Bool) {
        collectionHelper?.fetchTrackers(for: date, isDone: isDone){ [weak self] in
            guard let self,
                  let numberOfSections = collectionHelper?.numberOfSections()
            else { return }
            self.trackerCollectionView.reloadData()
            let isHidden = numberOfSections > 0
            self.trackerCollectionView.isHidden = !isHidden
            self.placeholder.isHidden = isHidden
            self.placeholderSearch.isHidden = true
        }
    }
    
    private func fetchTrackers(for searchString: String) {
        collectionHelper?.fetchTrackers(for: searchString){ [weak self] in
            guard let self,
                  let numberOfSections = collectionHelper?.numberOfSections()
            else { return }
            self.trackerCollectionView.reloadData()
            let isHidden = numberOfSections > 0
            self.trackerCollectionView.isHidden = !isHidden
            self.placeholderSearch.isHidden = isHidden
            self.placeholder.isHidden = !isHidden
            self.filterButton.isHidden = true
        }
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date.startOfDay()
        fetchTrackers(for: currentDate)
        currentFilter = .all
        dismiss(animated: true)
    }
    
    @objc func addButtonTapped() {
        guard let navController = self.navigationController else { return }
        navController.modalPresentationStyle = .automatic
        let choseTypeController = ChoseTypeViewController()
        choseTypeController.delegate = self
        present(choseTypeController, animated: true)
        AnalyticsService.shared.trackEvent(event: .click, params: AnalyticsEventData.MainScreen.clickAddTracker)
    }
    
    @objc private func filterButtonTapped() {
        let filtersViewController = FiltersViewController(delegate: self)
        filtersViewController.modalPresentationStyle = .pageSheet
        present(filtersViewController, animated: true, completion: nil)
        AnalyticsService.shared.trackEvent(event: .click, params: AnalyticsEventData.MainScreen.clickFilter)
    }
}

extension TrackersListViewController: ChoseTypeViewDelegate {
    func newHabitTapped(vc: ChoseTypeViewController) {
        vc.dismiss(animated: true)
        let newHabitController = NewHabitController(habitType: .habit)
        newHabitController.delegate = self
        present(newHabitController, animated: true)
        AnalyticsService.shared.trackEvent(event: .click, params: AnalyticsEventData.TrackersTypeScreen.clickAddTracker)
    }
    
    func newIrregularEventTapped(vc: ChoseTypeViewController) {
        vc.dismiss(animated: true)
        let newHabitController = NewHabitController(habitType: .event)
        newHabitController.delegate = self
        present(newHabitController, animated: true)
        AnalyticsService.shared.trackEvent(event: .click, params: AnalyticsEventData.TrackersTypeScreen.clickAddIrregularEvent)
    }
}

extension TrackersListViewController: NewHabitDelegate {
    func didEditHabit(tracker: Tracker, category: String) {
        trackerStore.editTracker(tracker: tracker, category: category)
    }
    
    func didCreateNewHabit(tracker: Tracker, category: String) {
        trackerStore.addTracker(tracker: tracker, category: category)
    }
}

extension TrackersListViewController: TrackerCollectionCellDelegate {    
    //возвращаем количество дней
    func recordAdded(for tracker: Tracker, date: Date) -> Int {
        let record = TrackerRecord(trackerId: tracker.id, date: date)
        if trackerRecordStore.findRecordBy(date: record.date, trackerId: record.trackerId) != nil {
            trackerRecordStore.deleteRecord(record)
        } else {
            trackerRecordStore.addRecord(record)
            if !tracker.isHabit {
                return 1
            }
        }
        return trackerRecordStore.findRecordsBy(trackerId: tracker.id).count
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension TrackersListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        collectionHelper?.numberOfRowsInSection(section) ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionHelper?.numberOfSections() ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell", for: indexPath
        ) as? TrackerCollectionCell else {
            return UICollectionViewCell()
        }
        guard let tracker = collectionHelper?.object(at: indexPath) else {
            return UICollectionViewCell()
        }
        let count = trackerRecordStore.findRecordsBy(trackerId: tracker.id).count
        let isDone = trackerRecordStore.findRecordBy(date: currentDate, trackerId: tracker.id) != nil
        cell.configure(with: tracker, selectedDate: currentDate, count: count, isDone: isDone)
        
        cell.delegate = self
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            )
            let label = UILabel(frame: headerView.bounds)
            label.translatesAutoresizingMaskIntoConstraints = false
            guard let sectionTitle = collectionHelper?.titleForSection(indexPath.section) else {
                return UICollectionReusableView()
            }
            label.text = sectionTitle
            label.textAlignment = .left
            label.textColor = .commonFont
            label.font = UIFont.boldSystemFont(ofSize: 19)
            headerView.subviews.forEach { $0.removeFromSuperview() }
            headerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 28),
                label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            ])
            
            return headerView
        }
        return UICollectionReusableView()
    }
}

extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: cellWidth * 0.8)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: params.leftInset, bottom: 10, right: params.rightInset)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat{
        6
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 50)
    }
}

extension TrackersListViewController: TrackerStoreDelegate {
    func store(didChangeContentWith update: IndexUpdate) {
        updateCollection()
    }
}

extension TrackersListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            fetchTrackers(for: searchText)
        } else {
            fetchTrackers(for: currentDate)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        fetchTrackers(for: currentDate)
    }
}

extension TrackersListViewController: FiltersDelegateProtocol {
    func didSelectFilter(filter: Filter) {
        self.currentFilter = filter
        switch filter {
        case .today:
            currentDate = Date().startOfDay()
            datePicker.date = currentDate
            fetchTrackers(for: currentDate)
        case .all:
            fetchTrackers(for: currentDate)
        case .completed:
            fetchTrackers(for: currentDate, isDone: true)
        case .uncompleted:
            fetchTrackers(for: currentDate, isDone: false)
        }
    }
}
