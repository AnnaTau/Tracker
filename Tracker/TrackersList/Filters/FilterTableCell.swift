//
//  FilterTableCell.swift
//  Tracker
//
//  Created by Анна Рыкунова on 30.03.2025.
//

import UIKit

final class FilterTableCell: UITableViewCell {
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .commonFont
        return label
    }()
    
    let selectedImageView: UIImageView = {
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
        contentView.addSubviews([label, selectedImageView])
        NSLayoutConstraint.activate([
            selectedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            selectedImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedImageView.widthAnchor.constraint(equalToConstant: 24),
            selectedImageView.heightAnchor.constraint(equalToConstant: 24),
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configure(text: String, isSelected: Bool) {
        label.text = text
        selectedImageView.image = isSelected ? UIImage(named: "Done") : nil
        contentView.backgroundColor = .cellBackground
    }
}
