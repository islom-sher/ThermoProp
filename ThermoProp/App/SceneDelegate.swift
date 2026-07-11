//
//  SceneDelegate.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/6/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasCompletedOnboarding {
            window.rootViewController = Tabbar()
        } else {
            let onboardingVC = OnboardingViewController()
            
            onboardingVC.onCompletion = {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                
                let mainVC = Tabbar()
                window.rootViewController = mainVC
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
            window.rootViewController = onboardingVC
        }
        
//        let onboardingVC = OnboardingViewController()
//        window.rootViewController = onboardingVC
        self.window = window
        window.makeKeyAndVisible()
    }
}
