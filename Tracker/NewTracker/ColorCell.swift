//
//  ColorCell.swift
//  Tracker
//
//  Created by Анна Рыкунова on 23.12.2024.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    private var color: UIColor? {
        didSet { colorCell.backgroundColor = color }
    }
    private lazy var colorCell: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: UIColor) {
        self.color = color
    }
    
    private func setup() {
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.addSubviews([colorCell])
        
        NSLayoutConstraint.activate([
            colorCell.widthAnchor.constraint(equalToConstant: 40),
            colorCell.heightAnchor.constraint(equalToConstant: 40),
            colorCell.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorCell.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func selectCell() {
        layer.borderWidth = 3
        layer.cornerRadius = 8
        layer.borderColor = color?.withAlphaComponent(0.3).cgColor
    }
    
    func clearSelection() {
        layer.borderWidth = 0
        layer.borderColor = .none
    }
}
