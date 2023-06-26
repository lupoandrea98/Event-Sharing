import UIKit
import SwiftUI

class TabBarViewController: UITabBarController {
    
    var maskView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        #warning("Controllare che funzioni anche su telefono")
//        profileController.viewDidLoad();
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

