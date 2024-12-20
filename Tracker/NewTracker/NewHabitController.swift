//
//  NewHabitController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 27.10.2024.
//

import UIKit

protocol NewHabitDelegate: AnyObject {
    func didCreateNewHabit(record: Tracker)
}

final class NewHabitController: UIViewController {
    let habitType: HabitType
    var delegate: NewHabitDelegate?
    var chosenDays = [Weekday]()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = habitType.rawValue
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypLightGrey
        textField.translatesAutoresizingMaskIntoConstraints = false
        let leftIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftIndent
        textField.leftViewMode = .always
        let rightIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.rightView = rightIndent
        textField.rightViewMode = .always
        return textField
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
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .ypWhite
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.layer.cornerRadius = 16
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.isScrollEnabled = false
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let categoryCell: UITableViewCell = {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = "Категория"
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
        cell.textLabel?.text = "Расписание"
        cell.accessoryType = .disclosureIndicator
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.backgroundColor = .ypLightGrey
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .ypBlack
        cell.textLabel?.textColor = .ypBlack
        
        return cell
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGrey
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func configureView() {
        view.backgroundColor = .ypWhite
        
        view.addSubviews([titleLabel, trackerNameTextField, tableView, buttonsStackView])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(habitType.countOfCells * 75)),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = trackerNameTextField.text,
              !name.isEmpty,
              let delegate
        else {return}
        
        let schedule = (habitType == .habit) ? Schedule.regular(Set(chosenDays.map { $0 })) : Schedule.irregular(Date())
        let color = (habitType == .habit) ? UIColor.ypBlue : UIColor.ypRed
        let emoji = (habitType == .habit) ? "😇" : "🏝"
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
        
        delegate.didCreateNewHabit(record: tracker)
        dismiss(animated: true, completion: nil)
    }
}

extension NewHabitController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            //TODO тут будет экран создания категорий
        } else {
            let scheduleViewController = ScheduleController()
            scheduleViewController.chosenDays = chosenDays
            scheduleViewController.delegate = self
            scheduleViewController.modalPresentationStyle = .pageSheet
            present(scheduleViewController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == habitType.countOfCells - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

extension NewHabitController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habitType.countOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return categoryCell
        } else {
            return scheduleCell
        }
    }
}

extension NewHabitController: ScheduleDelegate {
    func daysWasChosen(_ days: [Weekday]) {
        self.chosenDays = days
        var shortNamesOfDays = ""
        for day in chosenDays {
            if shortNamesOfDays != "" {
                shortNamesOfDays = shortNamesOfDays + ", " + day.shortName
            } else {
                shortNamesOfDays = day.shortName
            }
        }
        scheduleCell.detailTextLabel?.text = shortNamesOfDays
        if !chosenDays.isEmpty {
            createButton.backgroundColor = .ypBlack
        }
    }
}

extension NewHabitController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let length = currentText.replacingCharacters(in: stringRange, with: string).count
        switch habitType {
        case .habit:
            if length > 0 && !chosenDays.isEmpty {
                createButton.backgroundColor = .ypBlack
            } else {
                createButton.backgroundColor = .ypGrey
            }
        case .event:
            if length > 0 {
                createButton.backgroundColor = .ypBlack
            } else {
                createButton.backgroundColor = .ypGrey
            }
        }
        return length <= 38
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
