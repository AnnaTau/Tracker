//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 12.03.2025.
//

import UIKit

protocol NewCategoryDelegate: AnyObject {
    func didTapCreateButton(category: String)
}

final class NewCategoryViewController: UIViewController {
    weak var delegate: NewCategoryDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("new_category.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .commonFont
        label.textAlignment = .center
        return label
    }()
    
    private lazy var categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("new_category.placeholder", comment: "")
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .ypLightGrey
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.textAlignment = .left
        let indent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = indent
        textField.leftViewMode = .always
        textField.rightView = indent
        textField.rightViewMode = .always
        textField.delegate = self
        textField.addTarget(self, action: #selector(categoryTextFieldChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("new_category.button.done", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGrey
        button.isEnabled = false
        button.setTitleColor(.darkButtonFont, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.trackEvent(event: .open, params: ["screen": "\(AnalyticsEventData.NewCategoryScreen.name)"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.trackEvent(event: .close, params: ["screen": "\(AnalyticsEventData.NewCategoryScreen.name)"])
    }
    
    private func setupLayout() {
        view.addSubviews([titleLabel, categoryTextField, createButton])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        
            categoryTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryTextField.heightAnchor.constraint(equalToConstant: 60),
       
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func categoryTextFieldChanged(_ textField: UITextField) {
        let isEmpty = textField.text?.isEmpty ?? true
        if isEmpty {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGrey
            return
        }
        createButton.isEnabled = true
        createButton.backgroundColor = .darkBackground
    }
    
    @objc private func createButtonTapped() {
        guard let category = categoryTextField.text,
              let delegate
        else { return }
        AnalyticsService.shared.trackEvent(event: .click, params: AnalyticsEventData.NewCategoryScreen.clickCreate)
        delegate.didTapCreateButton(category: category)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate
extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
