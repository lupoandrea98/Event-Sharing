//
//  MainPresenter.swift
//  EventSharing
//
//  Created by certimeter on 17/04/23.
//

import Foundation
import AVFoundation
import UIKit

class PresenterManager {
    private var window: UIWindow?
    var userService = UserService()
    var loader = UIAlertController()
    var captureSession: AVCaptureSession?
    static var mainPresenter: PresenterManager?
    static var loginPresenter: LoginPresenter?
    static var homePresenter: HomePresenter?
    static var profilePresenter: ProfilePresenter?
    static var eventPresenter: EventPresenter?
    static var scannerPresenter: ScannerPresenter?
    static var invitationPresenter: InvitationPresenter?
    
    init(_ window: UIWindow?) {
        self.window = window
        PresenterManager.mainPresenter = self
    }
    
    func clearBackground(_ view: UIView) {
        if let effectView = view as? UIVisualEffectView {
            effectView.removeFromSuperview()
            return
        }
        
        view.backgroundColor = .clear
        view.subviews.forEach({ (subview) in
            clearBackground(subview)
        })
    }
    
    func loader(_ viewController: UIViewController) {
        guard let mustUpdate = PresenterManager.homePresenter?.mustUpdate else { return }
        if mustUpdate {
            let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
            clearBackground(alert.view)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 125, y: 15, width: 30, height: 30))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.large
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            self.loader = alert
            viewController.present(alert, animated: true)
        }
    }
    func stopLoader() {
        self.loader.dismiss(animated: true, completion: nil)
    }
    
    func presentLogin() {
        let loginViewController = LoginViewController()
        PresenterManager.loginPresenter = LoginPresenter()
        loginViewController.delegate = PresenterManager.loginPresenter
        window?.rootViewController = UINavigationController(rootViewController: loginViewController)
    }
    
    func presentHome() {
        let homeViewController = HomeViewController()
        PresenterManager.homePresenter = HomePresenter()
        homeViewController.delegate = PresenterManager.homePresenter
        window?.rootViewController = UINavigationController(rootViewController: homeViewController)
    }
    
    func presentTabBar() {
        let tabBarController = TabBarViewController()
        window?.rootViewController = tabBarController
    }
    
    func presentSignIn() {
        let signInViewController = SignInViewController()
        signInViewController.signDelegate = PresenterManager.loginPresenter
        window?.rootViewController = UINavigationController(rootViewController: signInViewController)
    }
    
    func presentModifUser(_ viewController: ProfileViewController, username: String, email: String, image: UIImage) {
        let signInViewController = SignInViewController()
        signInViewController.isModify = true
        signInViewController.parentView = viewController
        signInViewController.username = username
        signInViewController.email = email
        signInViewController.profileImage = image
        signInViewController.modifyDelegate = PresenterManager.profilePresenter
        viewController.present(UINavigationController(rootViewController: signInViewController), animated: true)
    }
    
    func presentInfoEvent(_ viewController: HomeViewController, event: Event, _ scannerController: ScannerViewController?){
        let infoViewController = InfoEventViewController()
        infoViewController.delegate = PresenterManager.eventPresenter
        infoViewController.owner_id = event.owner
        infoViewController.parentView = viewController
        if let scanController = scannerController {
            infoViewController.captureSession = scanController.captureSession
        }
        userService.getUserName(userId: event.owner) { username in
            infoViewController.event = event
            infoViewController.event?.owner = username
//            if event.image == Data() {
//                if let sheet = infoViewController.sheetPresentationController {
//                    sheet.detents = [ .medium(), .large() ]
//                    sheet.largestUndimmedDetentIdentifier = .medium
//                }
//            }
            PresenterManager.eventPresenter?.infoViewController = infoViewController
            infoViewController.modalPresentationStyle = .fullScreen
            viewController.present(infoViewController, animated: true)
        }
    }
    
    func presentUserList(_ viewController: InfoEventViewController) {
        PresenterManager.invitationPresenter = InvitationPresenter()
        guard let userId = UserDefaultsManager.shared.value else { return }
        userService.getUsersList(userId: userId) {
            users in
            PresenterManager.invitationPresenter?.users = users
            PresenterManager.invitationPresenter?.event = viewController.event
            let userListViewController = UserListViewController()
            userListViewController.delegate = PresenterManager.invitationPresenter
            userListViewController.modalTransitionStyle = .crossDissolve
            userListViewController.modalPresentationStyle = .formSheet
          
            viewController.present(userListViewController, animated: true)
        }
    }

}
