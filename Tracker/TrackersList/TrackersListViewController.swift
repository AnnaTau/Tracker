//
//  TrackersListViewController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 03.10.2024.
//

import UIKit

final class TrackersListViewController: UIViewController {
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var filteredTrackers: [Tracker] = []
    private(set) var currentDate: Date = Date()
    private let addTrackerButton: UIButton = .init()
    private let datePicker: UIDatePicker = .init()
    private let params: TrackersLayoutParams = TrackersLayoutParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 10
    )
    
    private let placeHolderImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Empty Trackers List"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var placeHolder: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [placeHolderImage, placeHolderLabel])
        stackView.addSubview(placeHolderImage)
        stackView.addSubview(placeHolderLabel)
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
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
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = UISearchController()

        view.addSubviews([placeHolder, trackerCollectionView])
        addConstraints()
        
        //TODO заглушка для категорий
        let newCategory = TrackerCategory(name: "Важное", trackers: [])
        categories.append(newCategory)
        updateCollectionFor(date: currentDate)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            placeHolderImage.widthAnchor.constraint(equalToConstant: 80),
            placeHolderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeHolder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeHolder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeHolder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeHolder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func updateCollectionFor(date: Date) {
        filteredTrackers = filterTrackers(by: date, trackers: categories[safe: 0]?.trackers ?? [])
        trackerCollectionView.isHidden = filteredTrackers.isEmpty
        placeHolder.isHidden = !filteredTrackers.isEmpty
        trackerCollectionView.reloadData()
    }
    
    private func filterTrackers(by date: Date, trackers: [Tracker]) -> [Tracker] {
        let calendar = Calendar.current
        var dayOfWeek = calendar.component(.weekday, from: date)
        dayOfWeek = (dayOfWeek == 1) ? 7 : dayOfWeek - 1
        return trackers.filter { tracker in
            if tracker.isHabit {
                guard let weekDay = Weekday.at(numberOfDay: dayOfWeek),
                      let schedule = tracker.schedule
                else { return false }
                return schedule.toWeekdays().contains(weekDay)
            } else {
                guard let date = tracker.date else { return false }
                return calendar.isDate(date, inSameDayAs: date)
            }
            
        }
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateCollectionFor(date: currentDate)
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
    func didCreateNewHabit(record: Tracker) {
        guard let category = categories[safe: 0] else {return}
        let trackers = category.trackers + [record]
        categories.remove(at: 0)
        categories.append(TrackerCategory(name: category.name, trackers: trackers))
        updateCollectionFor(date: currentDate)
        print("did create new habit \(record)")
    }
}

extension TrackersListViewController: TrackerCollectionCellDelegate {
    //возвращаем количество дней
    func recordAdded(for tracker: Tracker, date: Date) -> Int {
        let record = TrackerRecord(trackerId: tracker.id, date: date)
        let isListContainsTracker = completedTrackers.contains(
            where: {$0.trackerId == record.trackerId && Calendar.current.isDate($0.date, inSameDayAs: record.date)}
        )
        
        if !isListContainsTracker {
            completedTrackers.append(record)
            if !tracker.isHabit {
                return 1
            }
            return completedTrackers.filter { $0.trackerId == tracker.id }.count
        }
        
        let index = completedTrackers.firstIndex(
            where: {$0.trackerId == record.trackerId && Calendar.current.isDate($0.date, inSameDayAs: record.date)}
        )
        
        if let index {
            completedTrackers.remove(at: index)
            let count = completedTrackers.filter { $0.trackerId == tracker.id }.count
            return count
        } else {
            let record = TrackerRecord(trackerId: tracker.id, date: date)
            completedTrackers.append(record)
            return completedTrackers.filter { $0.trackerId == tracker.id }.count
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension TrackersListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return filteredTrackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
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
        
        let tracker = filteredTrackers[indexPath.item]
        let record = TrackerRecord(trackerId: tracker.id, date: currentDate)
        let isListContainsTracker = completedTrackers.contains(
            where: {$0.trackerId == record.trackerId && Calendar.current.isDate($0.date, inSameDayAs: record.date)}
        )
        
        if !tracker.isHabit {
            let count = isListContainsTracker ? 1 : 0
            cell.configure(with: tracker, selectedDate: currentDate, count: count, isDone: isListContainsTracker)
        } else {
            let count = completedTrackers.filter { $0.trackerId == tracker.id }.count
            cell.configure(with: tracker, selectedDate: currentDate, count: count, isDone: isListContainsTracker)
        }
        
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
            headerView.translatesAutoresizingMaskIntoConstraints = false
            let label = UILabel(frame: headerView.bounds)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = categories[safe: indexPath.row]?.name
            label.textAlignment = .left
            label.textColor = .ypBlack
            label.font = UIFont.boldSystemFont(ofSize: 19)
            headerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                headerView.heightAnchor.constraint(equalToConstant: 54),
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
        return CGSize(width: cellWidth,
                      height: 148)
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
        10
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
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}
