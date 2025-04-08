//
//  GradientBorderView.swift
//  Tracker
//
//  Created by Анна Рыкунова on 02.04.2025.
//

import UIKit

class GradientBorderView: UIView {
    lazy var borderWidth: CGFloat = 1.0 {
        didSet { updateMaskPath() }
    }
    lazy var gradientColors: [UIColor] = [] {
        didSet { gradientLayer.colors = gradientColors.map { $0.cgColor } }
    }
    lazy var cornerRadius: CGFloat = 8.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            updateMaskPath()
        }
    }
    private let gradientLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientBorder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientBorder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateMaskPath()
    }
    
    private func updateMaskPath() {
        let path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2),
            cornerRadius: cornerRadius
        )
        maskLayer.path = path.cgPath
    }
    
    private func setupGradientBorder() {
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
        
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = borderWidth
        maskLayer.frame = bounds
        gradientLayer.mask = maskLayer
    }
}
