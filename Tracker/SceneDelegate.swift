//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Анна Рыкунова on 27.09.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if OnboardingHelper.shared.isOnboarded {
            window?.rootViewController = TabBarViewController()
        } else {
            let pageViewController = OnboardingController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal,
                options: nil
            )
            window?.rootViewController = pageViewController
        }
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}

