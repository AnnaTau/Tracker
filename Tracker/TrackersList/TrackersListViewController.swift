//
//  TrackersListViewController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 03.10.2024.
//

import UIKit

final class TrackersListViewController: UIViewController {
    private let trackerStore = TrackerStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private let trackerCategoryStore = TrackerCategoryStore.shared
    private var collectionHelper: TrackerCollectionHelper?
    private lazy var currentDate: Date = {
        Date().startOfDay()
    }()
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
    
    private lazy var trackerCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .ypWhite
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        collectionView.register(TrackerCollectionCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageButton = UIImage(named: "Add tracker")
        addTrackerButton.setImage(imageButton, for: .normal)
        addTrackerButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale.current
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.title = NSLocalizedString("trackers.title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = UISearchController()

        view.addSubviews([placeholder, trackerCollectionView])
        addConstraints()
        configureStore()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureStore() {
        trackerStore.delegate = self
        collectionHelper = TrackerCollectionHelper()
        collectionHelper?.fetchTrackers(for: currentDate) { [weak self] in
            guard let self else { return }
            if let trackersViewModel = self.collectionHelper {
                let isHidden = trackersViewModel.numberOfSections() > 0
                self.trackerCollectionView.isHidden = !isHidden
                self.placeholder.isHidden = isHidden
            }
        }
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date.startOfDay()
        collectionHelper?.fetchTrackers(for: currentDate){ [weak self] in
            guard let self,
                  let numberOfSections = collectionHelper?.numberOfSections()
            else { return }
            self.trackerCollectionView.reloadData()
            let isHidden = numberOfSections > 0
            self.trackerCollectionView.isHidden = !isHidden
            self.placeholder.isHidden = isHidden
        }
        dismiss(animated: true)
    }
    
    @objc func addButtonTapped() {
        guard let navController = self.navigationController else { return }
        navController.modalPresentationStyle = .automatic
        let choseTypeController = ChoseTypeViewController()
        choseTypeController.delegate = self
        present(choseTypeController, animated: true)
    }
    
}

extension TrackersListViewController: ChoseTypeViewDelegate {
    func newHabitTapped(vc: ChoseTypeViewController) {
        vc.dismiss(animated: true)
        let newHabitController = NewHabitController(habitType: .habit)
        newHabitController.delegate = self
        present(newHabitController, animated: true)
    }
    
    func newIrregularEventTapped(vc: ChoseTypeViewController) {
        vc.dismiss(animated: true)
        let newHabitController = NewHabitController(habitType: .event)
        newHabitController.delegate = self
        present(newHabitController, animated: true)
    }
}

extension TrackersListViewController: NewHabitDelegate {
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
            label.textColor = .ypBlack
            label.font = UIFont.boldSystemFont(ofSize: 19)
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
        collectionHelper?.fetchTrackers(for: currentDate) { [weak self] in
            guard let self else { return }
            if let trackersViewModel = self.collectionHelper {
                let isHidden = trackersViewModel.numberOfSections() > 0
                self.trackerCollectionView.isHidden = !isHidden
                self.placeholder.isHidden = isHidden
            }
        }
        trackerCollectionView.performBatchUpdates({
            if !update.deletedSections.isEmpty {
                trackerCollectionView.deleteSections(update.deletedSections)
            }
            if !update.insertedSections.isEmpty {
                trackerCollectionView.insertSections(update.insertedSections)
            }
            for (section, items) in update.insertedItems {
                let indexPaths = items.map { IndexPath(item: $0, section: section) }
                trackerCollectionView.insertItems(at: indexPaths)
            }
            for (section, items) in update.deletedItems {
                let indexPaths = items.map { IndexPath(item: $0, section: section) }
                trackerCollectionView.deleteItems(at: indexPaths)
            }
            for (section, items) in update.updatedItems {
                let indexPaths = items.map { IndexPath(item: $0, section: section) }
                trackerCollectionView.reloadItems(at: indexPaths)
            }
            for move in update.movedItems {
                trackerCollectionView.moveItem(at: move.from, to: move.to)
            }
        }, completion: nil)
    }
}
