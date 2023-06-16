//
//  InvitationPresenter.swift
//  EventSharing
//
//  Created by certimeter on 23/05/23.
//

import Foundation
import UIKit

final class InvitationPresenter: UserListDelegate {
    
    let userService = UserService()
    var users: [User]?
    var invitationList: [String]?
    var event: Event?
    var maded: [Invitation]?
    var recieved: [Invitation]?
    var operationFlag = true
    
    func addUserToInvitationList(_ user: User) {
        let email = user.email
        if invitationList == nil {
            invitationList = []
        }
        invitationList?.append(email)
    }
    
    func removeUserFromInvitationList(_ user: User) {
        let email = user.email
        invitationList = invitationList?.filter(){ $0 != email }
    }
    
    func sendInvite(_ viewController: UserListViewController) {
        guard let invitation = invitationList else { print("no invitation"); return }
        guard let user = UserDefaultsManager.shared.value else { return }
        guard let eventId = event?.id else { return }
        if invitation.count > 0 {
            userService.sendInvitation(user, invitation, eventId.description) {
                result in
                if result == "saved" {
                    self.presentAlert(viewController, title: "Invite send")
                } else {
                    self.presentAlert1(viewController, title: result)
                }
            }
        } else {
            print("invite someone")
            return
        }
    }
    
    func presentAlert(_ viewController: UIViewController, title: String) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let attributedString = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 20) ?? UIFont.systemFont(ofSize: 22.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.addAction(UIAlertAction(title: "Ok", style: .default){
            (action: UIAlertAction) in
            alert.dismiss(animated: true)
            viewController.dismiss(animated: true)
        })
        viewController.present(alert, animated: true)
    }
    
    func presentAlert1(_ viewController: UIViewController, title: String) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let attributedString = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 20) ?? UIFont.systemFont(ofSize: 22.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        viewController.present(alert, animated: true)
    }

}

extension InvitationPresenter: InvitationViewDelegate {
    func eventSelected(_ viewController: InvitationViewController, _ eventId: Int) {
        if PresenterManager.homePresenter?.takeEvent(eventId) == nil {
            PresenterManager.eventPresenter?.eventService.getEvent(eventId) { event in
                guard let event = event else { return }
                let infoViewController = InfoEventViewController()
                infoViewController.delegate = PresenterManager.eventPresenter
                infoViewController.owner_id = event.owner
                self.userService.getUserName(userId: event.owner) { username in
                    infoViewController.event = event
                    infoViewController.event?.owner = username
                    viewController.present(infoViewController, animated: true)
                }
            }
        } else {
            guard let event = PresenterManager.homePresenter?.takeEvent(eventId) else { return }
            let infoViewController = InfoEventViewController()
            infoViewController.delegate = PresenterManager.eventPresenter
            infoViewController.owner_id = event.owner
            userService.getUserName(userId: event.owner) { username in
                infoViewController.event = event
                infoViewController.event?.owner = username
                viewController.present(infoViewController, animated: true)
            }
        }
    }
    
    func acceptInvite(_ viewController: InvitationViewController, _ invitationId: Int) {
        if operationFlag {
            operationFlag = false
            userService.setInvitationState(invitationId.description, "Accepted") { result in
                if result != "ok"{
                    self.presentAlert1(viewController, title: result)
                }
                viewController.delegate?.markAsRead(viewController, invitationId)
                viewController.delegate?.getRecievedInvitations(viewController)
                self.operationFlag = true
            }
        }
    }
    
    func markAsRead(_ viewController: InvitationViewController, _ invitationId: Int) {
        userService.setAsRead(invitationId.description) {
            result in
            if result == "ok"{
                if let profileController = PresenterManager.profilePresenter!.profileViewController {
                    PresenterManager.profilePresenter?.mustUpdate = true
                    PresenterManager.profilePresenter?.performGetUserInfo(profileController)
                }
                viewController.tableView.reloadData()
            }
        }
    }
    
    func deleteInvitation(_ viewController: InvitationViewController, _ invitationId: Int) {
        if operationFlag {
            operationFlag = false
            userService.deleteInvitation(invitationId.description) { result in
                if result == "ok" {
                    if viewController.isRecieved {
                        viewController.delegate?.getRecievedInvitations(viewController)
                    } else {
                        viewController.delegate?.getMadedInvitations(viewController)
                    }
                    if let profileController = PresenterManager.profilePresenter!.profileViewController {
                        PresenterManager.profilePresenter?.mustUpdate = true
                        PresenterManager.profilePresenter?.performGetUserInfo(profileController)
                    }
                }
                self.operationFlag = true
            }
        }
        
    }
    
    func getMadedInvitations(_ viewController: InvitationViewController) {
        guard let userId = UserDefaultsManager.shared.value else { return }
        userService.madedInvitation(userId) {
            result in
            viewController.isRecieved = false
            self.maded = result
            viewController.noInvitation.alpha = 0
            viewController.tableView.reloadData()
        }
    }
    
    func getRecievedInvitations(_ viewController: InvitationViewController) {
        guard let userId = UserDefaultsManager.shared.value else { return }
        userService.recievedInvitation(userId) { result in
            viewController.isRecieved = true
            self.recieved = result
            viewController.noInvitation.alpha = 0
            viewController.tableView.reloadData()
        }
    }
    
    
    
}
