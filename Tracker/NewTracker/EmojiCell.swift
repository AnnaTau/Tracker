//
//  EmojiCell.swift
//  Tracker
//
//  Created by Анна Рыкунова on 23.12.2024.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    private var emoji: String? {
        didSet { emojiLabel.text = emoji }
    }
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    func configure(with emoji: String) {
        self.emoji = emoji
    }
    
    private func setup() {
        contentView.addSubviews([emojiLabel])
        contentView.addSubview(emojiLabel)
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectCell() {
        layer.cornerRadius = 16
        backgroundColor = .ypLightGrey.withAlphaComponent(1.0)
    }
    
    func clearSelection() {
        backgroundColor = .clear
    }
}
