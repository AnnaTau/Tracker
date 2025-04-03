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
    private var isPinned: Bool = false
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .lightFont
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Pin"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .commonFont
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var cellView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    func configure(with tracker: Tracker, selectedDate: Date, count: Int, isDone: Bool) {
        self.tracker = tracker
        self.selectedDate = selectedDate
        self.count = count
        self.isPinned = tracker.isPinned
        
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        cellView.backgroundColor = tracker.color
        
        daysLabel.text = formatDaysText(count)
        setupPlusButton(isDone: isDone, color: tracker.color)
        
        setupLayout()
        pinImageView.isHidden = !isPinned
    }
    
    private func setupLayout() {
        cellView.addSubviews([emojiLabel, nameLabel])
        contentView.addSubviews([cellView, daysLabel, plusButton])
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(contentsOf: [
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emojiLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -12),
        ])
        
        if isPinned {
            cellView.addSubviews([pinImageView])
            constraints.append(contentsOf: [
                pinImageView.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 12),
                pinImageView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -4),
                pinImageView.widthAnchor.constraint(equalToConstant: 24),
                pinImageView.heightAnchor.constraint(equalToConstant: 24),
            ])
        }
        
        constraints.append(contentsOf: [
            plusButton.topAnchor.constraint(equalTo: cellView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            daysLabel.topAnchor.constraint(equalTo: cellView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        AnalyticsService.shared.trackEvent(event: .click, params: AnalyticsEventData.MainScreen.clickTracker)
    }
    
    private func formatDaysText(_ count: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of days"),
            count
        )
    }
    
}
