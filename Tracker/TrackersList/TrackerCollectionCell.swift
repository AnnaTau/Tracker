//
//  TrackerCollectionCell.swift
//  Tracker
//
//  Created by Анна Рыкунова on 11.11.2024.
//

import UIKit

protocol TrackerCollectionCellDelegate: AnyObject {
    func recordAdded(for tracker: Tracker, date: Date) -> Int
}

final class TrackerCollectionCell: UICollectionViewCell {
    var delegate: TrackerCollectionCellDelegate?
    
    private var tracker: Tracker?
    private var selectedDate: Date?
    private var count: Int = 0
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    func configure(with tracker: Tracker, selectedDate: Date, count: Int, isDone: Bool) {
        self.tracker = tracker
        self.selectedDate = selectedDate
        self.count = count
        
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        cellView.backgroundColor = tracker.color
        
        daysLabel.text = formatDaysText(count)
        setupPlusButton(isDone: isDone, color: tracker.color)
    }
    
    private func setupLayout() {
        cellView.addSubviews([emojiLabel, nameLabel])
        contentView.addSubviews([cellView, daysLabel, plusButton])
        
        NSLayoutConstraint.activate([
            
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -12),
            
            plusButton.topAnchor.constraint(equalTo: cellView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            daysLabel.topAnchor.constraint(equalTo: cellView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlusButton(isDone: Bool, color: UIColor) {
        let buttonImage = isDone ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "plus.circle.fill")
        
        plusButton.setImage(buttonImage, for: .normal)
        plusButton.tintColor = color
        plusButton.alpha = isDone ? 0.7 : 1
        
        plusButton.contentVerticalAlignment = .fill
        plusButton.contentHorizontalAlignment = .fill
        plusButton.imageView?.contentMode = .scaleAspectFit
        plusButton.imageEdgeInsets = .zero
    }
        
    @objc private func plusButtonTapped() {
        guard let tracker,
              let selectedDate,
              let delegate
        else { return }
        let newCount = delegate.recordAdded(for: tracker, date: selectedDate)
        let isDone = newCount > count
        setupPlusButton(isDone: isDone, color: tracker.color)
        
        count = newCount
        daysLabel.text = formatDaysText(count)
    }
    
    private func formatDaysText(_ count: Int) -> String {
        let lastNumber = count % 10
        let lastTwoNumbers = count % 100
        
        if lastTwoNumbers >= 11 && lastTwoNumbers <= 19 {
            return "\(count) дней"
        } else if lastNumber == 1 {
            return "\(count) день"
        } else if lastNumber >= 2 && lastNumber <= 4 {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
}
