//
//  InvitationViewController.swift
//  EventSharing
//
//  Created by certimeter on 22/05/23.
//

import UIKit

protocol InvitationViewDelegate: InvitationPresenter {
    func getMadedInvitations(_ viewController: InvitationViewController)
    func deleteInvitation(_ viewController: InvitationViewController, _ invitationId: Int) 
    func getRecievedInvitations(_ viewController: InvitationViewController)
    func markAsRead(_ viewController: InvitationViewController, _ invitationId: Int)
    func acceptInvite(_ viewController: InvitationViewController, _ invitationId: Int)
    func eventSelected(_ viewController: InvitationViewController, _ eventId: Int)
}

class InvitationViewController: UIViewController {
    
    @IBOutlet weak var segmentationController: UISegmentedControl!
    @IBOutlet weak var noInvitation: UIView!
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: InvitationViewDelegate?
    var isRecieved = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Invitations"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
            NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 25)!
        ]
        
        navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "chevron.backward.circle")
        tableView.dataSource = self
        tableView.delegate = self
        //view.bringSubviewToFront(noInvitation)
        tableView.register(UINib(nibName: "InvitationTableViewCell", bundle: nil), forCellReuseIdentifier: "invitationCell")
        delegate?.getRecievedInvitations(self)
    }

    @IBAction func switchToRecieved(_ sender: Any) {
        if isRecieved {
            delegate?.getMadedInvitations(self)
        } else {
            delegate?.getRecievedInvitations(self)
        }
    }
    
}

extension InvitationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRecieved {
            guard let recieved = delegate?.recieved?.count else {
                self.noInvitation.alpha = 1
                return 0
            }
            if recieved == 0 {
                self.noInvitation.alpha = 1
            }
            return recieved
        } else {
            guard let maded = delegate?.maded?.count else {
                self.noInvitation.alpha = 1
                return 0 }
            if maded == 0 {
                self.noInvitation.alpha = 1
            }
            return maded
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invitationCell", for: indexPath) as! InvitationTableViewCell
        if isRecieved {
            guard let recieved = delegate?.recieved else { return InvitationTableViewCell() }
            cell.cellDescription.text = "\(recieved[indexPath.row].user2name) invited you to attend \(recieved[indexPath.row].eventTitle) "
            cell.userImage.image = UIImage(data: recieved[indexPath.row].user1Image)
            cell.accepted.alpha = 0
        } else {
            guard let maded = delegate?.maded else { return InvitationTableViewCell() }
            cell.cellDescription.text = "You invited \(maded[indexPath.row].user2name) to attend \(maded[indexPath.row].eventTitle) "
            cell.userImage.image = UIImage(data: maded[indexPath.row].user1Image)
            if maded[indexPath.row].state == "Accepted" {
                UIView.animate(withDuration: 0.5,
                               delay: 0.2,
                               options: [.curveEaseInOut, .transitionCurlDown]) {
                    cell.accepted.alpha = 1
                    self.view.layoutIfNeeded()
                }
            } else {
                cell.accepted.alpha = 0
            }
        }
        
        return cell
    }
    
    
}

extension InvitationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //MARK: Delete/Refuse invite
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (_, _, _) in
            if self.isRecieved {
                guard let invitationId = self.delegate?.recieved?[indexPath.row].id else { return }
                self.delegate?.deleteInvitation(self, invitationId)
                self.delegate?.markAsRead(self, invitationId)
            } else {
                guard let invitationId = self.delegate?.maded?[indexPath.row].id else { return }
                self.delegate?.deleteInvitation(self, invitationId)
                self.delegate?.markAsRead(self, invitationId)
            }
        }
        
        if isRecieved {
            deleteAction.title = "Refuse"
        }
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeConfig.performsFirstActionWithFullSwipe = true
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //MARK: Accept invite
        let acceptAction = UIContextualAction(style: .normal, title: "Accept") { _, _, _ in
            guard let invitationId = self.delegate?.recieved?[indexPath.row].id else { return }
            self.delegate?.acceptInvite(self, invitationId)
        }
        acceptAction.backgroundColor = .systemGreen
        let swipeConfig = UISwipeActionsConfiguration(actions: [acceptAction])
        swipeConfig.performsFirstActionWithFullSwipe = true
        return isRecieved ? swipeConfig : nil
    }
    //MARK: Mark as readed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isRecieved {
            guard let invitationId = delegate?.recieved?[indexPath.row].id else { return }
            guard let eventId = delegate?.recieved?[indexPath.row].eventId else { return }
            delegate?.recieved?[indexPath.row].newInvitation = false
            delegate?.markAsRead(self, invitationId)
            delegate?.eventSelected(self, eventId)
        }
    }
}
