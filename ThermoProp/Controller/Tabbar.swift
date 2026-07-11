//
//  Tabbar.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/6/26.
//

import UIKit

class Tabbar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabbarController()
        
        tabBar.tintColor = UIColor(red: 0.11, green: 0.62, blue: 0.46, alpha: 1)
        tabBar.unselectedItemTintColor = UIColor.systemGray
    }
    
    func setUpTabbarController() {
        let calculatorVC = CalculatorViewController()
        let calculatorNV = UINavigationController(rootViewController: calculatorVC)
        let item1 = UITabBarItem(title: "Calculator", image: UIImage(systemName: "function"), selectedImage: UIImage(systemName: "function"))
        calculatorNV.tabBarItem = item1
        
//        let chartsVC = ChartsViewController()
//        let chartsNV = UINavigationController(rootViewController: chartsVC)
//        let item2 = UITabBarItem(title: "Charts", image: UIImage(systemName: "chart.xyaxis.line"), selectedImage: UIImage(systemName: "chart.xyaxis.line"))
//        chartsNV.tabBarItem = item2
        
        let historyVC = HistoryViewController()
        let historyNV = UINavigationController(rootViewController: historyVC)
        let item3 = UITabBarItem(title: "History", image: UIImage(systemName: "clock"), selectedImage: UIImage(systemName: "clock"))
        
        historyNV.tabBarItem = item3
        
        let settingsVC = SettingsViewController()
        let settingsNV = UINavigationController(rootViewController: settingsVC)
        let item4 = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        settingsNV.tabBarItem = item4
        
        viewControllers = [calculatorNV, historyNV, settingsNV]
    }

}
