//
//  ScheduleController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 30.10.2024.
//

import UIKit

protocol ScheduleDelegate: AnyObject {
    func daysWasChosen(_ days: [Weekday])
}

final class ScheduleController: UIViewController {
    
    var chosenDays = [Weekday]()
    weak var delegate: ScheduleDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .ypWhite
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.layer.cornerRadius = 16
        table.isScrollEnabled = false
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        configureView()
    }
    
    private func configureView() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(7*75)),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneButtonTapped() {
        delegate?.daysWasChosen(chosenDays)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func switchTapped(_ sender: UISwitch) {
        guard let day = Weekday.at(numberOfDay: sender.tag) else { return }
        if sender.isOn {
            chosenDays.append(day)
        } else {
            if let index = chosenDays.firstIndex(of: day) {
                chosenDays.remove(at: index)
            }
        }
    }
    
}

extension ScheduleController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 7 - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let day = Weekday.at(numberOfDay: indexPath.row + 1)
        else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = day.rawValue
        
        let switchView = UISwitch()
        switchView.isOn = chosenDays.contains(where: {
            $0.rawValue == day.rawValue
        })

        switchView.tag = indexPath.row + 1
        switchView.addTarget(self, action: #selector(switchTapped(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        cell.backgroundColor = .ypLightGrey
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
