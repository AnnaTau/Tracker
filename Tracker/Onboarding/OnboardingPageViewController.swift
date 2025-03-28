//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 10.03.2025.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    private var imageName: String = ""
    private var text: String = ""
    private var pageControlCurrentPage: Int = 0
    private var pageControlNumberOfPages: Int = 2
    
    private lazy var imageView: UIImageView = {
        UIImageView()
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("onboarding.button.text", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = CGFloat(16)
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private(set) lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .black
        control.pageIndicatorTintColor = .lightGray
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    func configure(backgroundImageName: String, labelText: String) {
        imageName = backgroundImageName
        text = labelText
        imageView.image = UIImage(named: backgroundImageName)
        label.text = labelText
        pageControl.currentPage = pageControlCurrentPage
        pageControl.numberOfPages = pageControlNumberOfPages
    }
    
    private func setupLayout() {
        view.addSubviews([imageView, label, startButton, pageControl])
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 64),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant:  -50),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -24)
        ])
    }
    
    @objc private func startButtonTapped() {
        let tabBarController = TabBarViewController()
        if let window = UIApplication.shared.windows.first {
            OnboardingHelper.shared.isOnboarded = true
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        } else {
            print("Failed to load Trackers")
        }
    }
}
