//
//  NewHabitController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 27.10.2024.
//

import UIKit

protocol NewHabitDelegate: AnyObject {
    func didCreateNewHabit(tracker: Tracker, category: String)
}

final class NewHabitController: UIViewController {
    var delegate: NewHabitDelegate?
    private var chosenDays: Weekdays = Weekdays()
    private let habitType: HabitType
    private var selectedCategory: String?
    var emoji: String?
    var color: UIColor?
    var emojiIndexPath: IndexPath?
    var colorIndexPath: IndexPath?
    lazy var isHabit: Bool = {
        switch habitType {
        case .habit: return true
        case .event: return false
        }
    }()
    lazy var dateForEvent: Date? = {
        guard habitType == .event else { return nil }
        return Date().startOfDay()
    }()
    let sections: [NewTrackerSection] = [.emojis, .colors]
    let params: NewTrackerLayoutParams = NewTrackerLayoutParams(
        leftOrRightInset: 16,
        topOrBottomInset: 24,
        cellSpacing: 10,
        itemsInRow: 6
    )
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIStackView = {
        let contentView = UIStackView()
        contentView.axis = .vertical
        return contentView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = habitType.value
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = NSLocalizedString("tracker.placeholder.name", comment: "")
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypLightGrey
        let indent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = indent
        textField.leftViewMode = .always
        textField.rightView = indent
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .ypWhite
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.layer.cornerRadius = 16
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.isScrollEnabled = false
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    private let categoryCell: UITableViewCell = {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = NSLocalizedString("tracker.title.category", comment: "")
        cell.accessoryType = .disclosureIndicator
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.backgroundColor = .ypLightGrey
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .ypBlack
        cell.textLabel?.textColor = .ypBlack
        return cell
    }()
    
    private let scheduleCell: UITableViewCell = {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = NSLocalizedString("tracker.title.schedule", comment: "")
        cell.accessoryType = .disclosureIndicator
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.backgroundColor = .ypLightGrey
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .ypBlack
        cell.textLabel?.textColor = .ypBlack
        return cell
    }()
    
    private lazy var colorAndEmojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .ypWhite
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "emojiAndColorHeader"
        )

        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "colorCell")
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("tracker.button.cancel", comment: ""), for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("tracker.button.create", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGrey
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    init(habitType: HabitType) {
        self.habitType = habitType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        view.backgroundColor = .ypWhite
        
        view.addSubviews([scrollView])
        contentView.addSubviews([titleLabel, trackerNameTextField, tableView, colorAndEmojiCollectionView, buttonsStackView])
        scrollView.addSubviews([contentView])
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(habitType.countOfCells * 75)),
            
            colorAndEmojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            colorAndEmojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorAndEmojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorAndEmojiCollectionView.heightAnchor.constraint(equalToConstant: 520),
            
            buttonsStackView.topAnchor.constraint(equalTo: colorAndEmojiCollectionView.bottomAnchor, constant: 16),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func isReadyToSave(text: String?) -> Bool {
        guard let text,
              !text.isEmpty,
              text.count <= 38,
              let color,
              let emoji,
              let selectedCategory
        else { return false }
        switch habitType {
        case .habit:
            return chosenDays.rawValue != 0
        case .event:
            return true
        }
    }
    
    func updateSaveButton() {
        createButton.isEnabled = isReadyToSave(text: trackerNameTextField.text)
        createButton.backgroundColor = isReadyToSave(text: trackerNameTextField.text) ? .ypBlack : .ypGrey
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = trackerNameTextField.text,
              !name.isEmpty,
              let delegate,
              let color,
              let emoji,
              let selectedCategory
        else {
            print("Error saving new habit")
            return
        }
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            isHabit: isHabit,
            schedule: chosenDays,
            date: dateForEvent
        )
        delegate.didCreateNewHabit(tracker: tracker, category: selectedCategory)
        dismiss(animated: true, completion: nil)
    }
}

extension NewHabitController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let categoryViewController = CategoriesViewController()
            categoryViewController.delegate = self
            categoryViewController.selectedCategory = selectedCategory
            categoryViewController.modalPresentationStyle = .pageSheet
            present(categoryViewController, animated: true, completion: nil)
        } else {
            let scheduleViewController = ScheduleController()
            scheduleViewController.chosenDays = chosenDays
            scheduleViewController.delegate = self
            scheduleViewController.modalPresentationStyle = .pageSheet
            present(scheduleViewController, animated: true, completion: nil)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == habitType.countOfCells - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

extension NewHabitController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        habitType.countOfCells
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if indexPath.row == 0 {
            return categoryCell
        } else {
            return scheduleCell
        }
    }
}

extension NewHabitController: ScheduleDelegate {
    func daysWasChosen(_ days: Weekdays) {
        self.chosenDays = days
        var shortNamesOfDays = ""
        if chosenDays == .all {
            shortNamesOfDays = NSLocalizedString("weekdays.short.all", comment: "")
        } else {
            for day in chosenDays {
                if shortNamesOfDays != "" {
                    shortNamesOfDays = shortNamesOfDays + ", " + day.shortName
                } else {
                    shortNamesOfDays = day.shortName
                }
            }
        }
        scheduleCell.detailTextLabel?.text = shortNamesOfDays
        if !chosenDays.isEmpty {
            updateSaveButton()
        }
    }
}

extension NewHabitController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let text = currentText.replacingCharacters(in: stringRange, with: string)
        let isReady = isReadyToSave(text: text)
        createButton.backgroundColor = isReady ? .ypBlack : .ypGrey
        createButton.isEnabled = isReady
        return text.count <= 38
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewHabitController: CategoriesViewDelegate {
    func didSelectCategory(category: String) {
        selectedCategory = category
        categoryCell.detailTextLabel?.text = category
        updateSaveButton()
    }
}
