//
//  OnboardingController.swift
//  Tracker
//
//  Created by Анна Рыкунова on 10.03.2025.
//

import UIKit

final class OnboardingController: UIPageViewController {
    private lazy var pages: [OnboardingPageViewController] = configPages()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: false, completion: nil)
        }
    }
    
    private func configPages() -> [OnboardingPageViewController] {
        let firstPage = OnboardingPageViewController()
        firstPage.configure(
            backgroundImageName: "OnboardingBackground1",
            labelText: NSLocalizedString("onboarding.first.title", comment: "")
        )
        let secondPage = OnboardingPageViewController()
        secondPage.configure(
            backgroundImageName: "OnboardingBackground2",
            labelText: NSLocalizedString("onboarding.second.title", comment: "")
        )
        return [firstPage, secondPage]
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingController: UIPageViewControllerDataSource{
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentPage = viewController as? OnboardingPageViewController,
              let currentIndex = pages.firstIndex(of: currentPage)
        else { return nil }
        let previousIndex = currentIndex - 1
        return previousIndex >= 0 ? pages[previousIndex] : nil
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentPage = viewController as? OnboardingPageViewController,
              let currentIndex = pages.firstIndex(of: currentPage)
        else { return nil }
        let nextIndex = currentIndex + 1
        return nextIndex < pages.count ? pages[nextIndex] : nil
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
           let currentViewController = viewControllers?.first as? OnboardingPageViewController,
           let currentIndex = pages.firstIndex(of: currentViewController)
        else { return }
        pages[currentIndex].pageControl.currentPage = currentIndex
    }
}
