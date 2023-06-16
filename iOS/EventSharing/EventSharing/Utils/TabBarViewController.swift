//
//  BarViewController.swift
//  EventSharing
//
//  Created by certimeter on 13/04/23.
//

import UIKit
import SwiftUI

class TabBarViewController: UITabBarController {
    
    var maskView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        maskView.backgroundColor = .black.withAlphaComponent(0.5)
//        let activityIndicator = UIActivityIndicatorView()
//        NSLayoutConstraint.activate([
//          activityIndicator.topAnchor.constraint(equalTo: maskView.topAnchor),
//          activityIndicator.leadingAnchor.constraint(equalTo: maskView.leadingAnchor),
//          activityIndicator.heightAnchor.constraint(equalTo: maskView.heightAnchor),
//          activityIndicator.widthAnchor.constraint(equalTo: maskView.widthAnchor)
//        ])
//        maskView.addSubview(activityIndicator)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "Background")
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        PresenterManager.profilePresenter = ProfilePresenter()
        PresenterManager.homePresenter = HomePresenter()
        PresenterManager.eventPresenter = EventPresenter()
        PresenterManager.scannerPresenter = ScannerPresenter()
        
        guard let profileController = PresenterManager.profilePresenter?.startProfile() else {
            print("impossibile inizializzare il profilo")
            return
        }
        guard let homeController = PresenterManager.homePresenter?.startHome() else {
            print("impossibile inizializzare la home")
            return
        }
        guard let createController = PresenterManager.eventPresenter?.startCreate() else {
            print("impossibile inizializzare la createEvent")
            return
        }
        guard let scannerController = PresenterManager.scannerPresenter?.startScanner() else {
            print("impossibile inizializzare scanner")
            return
        }
                
        let profileViewController = UINavigationController(rootViewController: profileController)
        let homeViewController = homeController
        let createViewController = UINavigationController(rootViewController: createController)
        let scannerViewController = UINavigationController(rootViewController: scannerController)
        let exploreSwiftUIController = UIHostingController(rootView: Explore(model: EventModelData()))
        
        createViewController.tabBarItem = UITabBarItem(title: "Create", image: UIImage(systemName: "plus"), tag: 0)
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)
        scannerViewController.tabBarItem = UITabBarItem(title: "Scanner", image: UIImage(systemName: "qrcode"), tag: 3)
        exploreSwiftUIController.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "safari"), tag: 4)
        
        self.setViewControllers([createViewController, scannerViewController, homeViewController, exploreSwiftUIController, profileViewController], animated: true)
        self.selectedIndex = 2
        tabBar.unselectedItemTintColor = UIColor.white

    }

}

extension TabBarViewController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        if let profileViewController = viewController as? ProfileViewController {
//            if selectedViewController != profileViewController {
//                present(profileViewController, animated: true)
//            }
//        }
//        if let homeViewController = viewController as? HomeViewController {
//            if selectedViewController != homeViewController {
//                present(homeViewController, animated: true)
//            }
//        }
//    }
}
