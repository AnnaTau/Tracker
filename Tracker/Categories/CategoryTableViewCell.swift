//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Анна Рыкунова on 12.03.2025.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .commonFont
        return label
    }()
    
    private let selectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "cell")
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubviews([trackerLabel, selectionImageView])
        NSLayoutConstraint.activate([
            selectionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            selectionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionImageView.widthAnchor.constraint(equalToConstant: 24),
            selectionImageView.heightAnchor.constraint(equalToConstant: 24),
            
            trackerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(text: String, isSelected: Bool) {
        trackerLabel.text = text
        selectionImageView.image = isSelected ? UIImage(named: "Done") : nil
        backgroundColor = .cellBackground
    }
}
