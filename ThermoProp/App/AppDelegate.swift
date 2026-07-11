//
//  AppDelegate.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/5/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = .systemGray
        return true
    }

    // MARK: - Scene Session Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) { }
    
    func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        let selectedTintColor = UIColor(red: 0.11, green: 0.62, blue: 0.46, alpha: 1)
        
        // Set the color for the selected icon and title
        appearance.stackedLayoutAppearance.selected.iconColor = selectedTintColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedTintColor]
        
        // Set the color for the unselected icon and title
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 17.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

