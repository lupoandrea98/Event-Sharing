//
//  ProfilePresenter.swift
//  EventSharing
//
//  Created by certimeter on 12/04/23.
//

import Foundation
import UIKit
import FirebaseAuth

final class ProfilePresenter {
    
    let userService = UserService()
    var userInfo: User?
    var mustUpdate = true
    var profileViewController: ProfileViewController?
    
    func start(_ tabBarController: UITabBarController, _ tabBarItem: UITabBarItem) {
        print("Profile presenter inizializzato")
        let profileViewController = ProfileViewController()
        profileViewController.delegate = self
        profileViewController.tabBarItem = tabBarItem
        
        var viewControllers = tabBarController.viewControllers ?? []
        viewControllers.append(profileViewController)
        tabBarController.setViewControllers(viewControllers, animated: true)
    }
    
    func startProfile() -> ProfileViewController {
        let profileController = ProfileViewController()
        profileController.delegate = self
        self.profileViewController = profileController
        return profileController
    }
    
    func presentAlert(_ viewController: UIViewController, _ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let attributedString = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 20) ?? UIFont.systemFont(ofSize: 22.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.red
        ])
        let attributedMessage = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 16) ?? UIFont.systemFont(ofSize: 16.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        viewController.present(alert, animated: true)
    }
    
}

extension ProfilePresenter: ProfileViewDelegate {
    func presentInvitation(_ viewController: ProfileViewController) {
        if PresenterManager.invitationPresenter == nil {
            PresenterManager.invitationPresenter = InvitationPresenter()
        }
        let invitationViewController = InvitationViewController()
        invitationViewController.delegate = PresenterManager.invitationPresenter
        viewController.navigationController?.pushViewController(invitationViewController, animated: true)
    }
    
    func presentList(_ viewController: ProfileViewController, _ requestedList: String) {
        let listViewController = EventListViewController()
        listViewController.requestedList = requestedList
        listViewController.delegate = PresenterManager.eventPresenter
        PresenterManager.eventPresenter?.eventListViewController = listViewController
        if let sheet = listViewController.sheetPresentationController {
            sheet.detents = [ .medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        viewController.present(listViewController, animated: true)
    }
    
    func userModify(_ viewController: ProfileViewController, username: String, email: String, image: UIImage) {
        PresenterManager.mainPresenter?.presentModifUser(viewController, username: username, email: email, image: image)
    }
    // MARK: Get user info
    func performGetUserInfo(_ viewController: ProfileViewController) {
        if mustUpdate {
            userService.getUserInfo(userId: UserDefaultsManager.shared.value!) {
                user in
                self.userInfo = user
                viewController.profileImage?.image = UIImage(data: user.image ?? Data())
                viewController.usernameLabel?.text = user.username
                viewController.emailLabel?.text = user.email
                if viewController.favouriteNumber?.text != user.favourites.description {
                    viewController.favouriteNumber?.text = user.favourites.description
                    //Se la eventListViewController è aperta allora l'aggiorna altrimenti no
                    if let eventListController = PresenterManager.eventPresenter?.eventListViewController {
                        eventListController.delegate?.getList(eventListController, "favourites")
                    }
                }
                if viewController.purchasedNumber?.text != user.purchased.description{
                    viewController.purchasedNumber?.text = user.purchased.description
                    if let eventListController = PresenterManager.eventPresenter?.eventListViewController {
                        eventListController.delegate?.getList(eventListController, "partecipated")
                    }
                }
                
                viewController.createdNumber?.text = user.created.description
                if let eventListController = PresenterManager.eventPresenter?.eventListViewController {
                    eventListController.delegate?.getList(eventListController, "created")
                }
                
                viewController.invitationNumber?.text = user.invitation.description
                if user.newInvitation {
                    viewController.newNotification?.alpha = 1
                } else {
                    viewController.newNotification?.alpha = 0
                }
                
                self.mustUpdate = false
            }
        }
        
    }
    // MARK: Logout
    func performLogout(_ viewController: ProfileViewController) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let attributedString = NSAttributedString(string: "Are you sure you want to logout?", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 20) ?? UIFont.systemFont(ofSize: 22.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        alert.setValue(attributedString, forKey: "attributedTitle")
        
        let actionYes = UIAlertAction(title: "Yes", style: .default) {
            (action:UIAlertAction) in
            
            let authListener = Auth.auth().addStateDidChangeListener { (auth, user) in
                if user == nil {
                  // L'utente è stato scollegato con successo
                  print("Logout eseguito correttamente")
                }
            }

            do{
                try Auth.auth().signOut()
            }catch{
                print("LogOut error \(error)")
            }
            //Rimuovo l'userId dalla sessione locale
            UserDefaultsManager.shared.value = ""
            //Stacco il listener creato in precedenza
            Auth.auth().removeStateDidChangeListener(authListener)

            PresenterManager.mainPresenter?.presentLogin()
        }
        alert.addAction(actionYes)
        alert.addAction(UIAlertAction(title: "No", style: .destructive))
        viewController.present(alert, animated: true)
    }
}
// MARK: Modify delegate
extension ProfilePresenter: ModifyViewDelegate {
    func performModify(_ viewController: SignInViewController, username: String, email: String, oldPassword: String, password: String, image: UIImage?) {
        
        if username == "" {
            viewController.usernameTextField.layer.borderColor = UIColor.systemRed.cgColor
            presentAlert(viewController, "Error", "Insert Username")
            return
        }
        
        if email == "" {
            viewController.emailTextField.layer.borderColor = UIColor.systemRed.cgColor
            presentAlert(viewController, "Error", "Insert valid Email")
            return
        }
        
        userService.updateUserInfo(userInfo, username: username, email: email, oldPassword: oldPassword, password: password, image: image) {
            result in
            if result == "true" {
                self.presentAlert(viewController, "User updated", "")
                guard let parent = viewController.parentView else {
                    print("Error parentView of modifyView")
                    return
                }
                PresenterManager.profilePresenter?.mustUpdate = true
                viewController.parentView?.delegate?.performGetUserInfo(parent)
            } else {
                self.presentAlert(viewController, "Error", result)
            }
            
        }
    }
}
