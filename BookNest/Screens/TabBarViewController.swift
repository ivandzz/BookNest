//
//  TabBarViewController.swift
//  BookNest
//
//  Created by Іван Джулинський on 09.08.2025.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        self.tabBar.tintColor = .label
        self.tabBar.barTintColor = .systemBackground
        
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.delegate = self
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let profileVC = UINavigationController(rootViewController: UIViewController())
        profileVC.delegate = self
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 1)
        
        self.setViewControllers([homeVC, profileVC], animated: true)
    }
}

extension TabBarViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let rootVC = navigationController.viewControllers.first {
            let shouldHideTabBar = viewController !== rootVC
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                self.tabBar.alpha = shouldHideTabBar ? 0 : 1
            }
        }
    }
}
