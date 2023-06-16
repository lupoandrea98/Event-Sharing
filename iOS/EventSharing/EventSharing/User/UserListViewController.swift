//
//  UserListViewController.swift
//  EventSharing
//
//  Created by certimeter on 23/05/23.
//

import UIKit

protocol UserListDelegate: Any {
    func addUserToInvitationList(_ user: User)
    func removeUserFromInvitationList(_ user: User)
    func sendInvite(_ viewController: UserListViewController)
}

class UserListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var sendButton: UIButton!
    weak var delegate: InvitationPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.layer.cornerRadius = 10
        stackView.layer.cornerRadius = 10
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 20
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.allowsMultipleSelection = true
        
    }

    @IBAction func sendinvite(_ sender: Any) {
        delegate?.sendInvite(self)
    }
 
}

extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let usersCount = delegate?.users?.count else { return 0 }
        return usersCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        guard let user = delegate?.users?[indexPath.row] else { return UserTableViewCell() }
        cell.username.text = user.username
        cell.userImage.image = UIImage(data: user.image!)
        
        return cell
    }
}

extension UserListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = delegate?.users?[indexPath.row] else { return }
        delegate?.addUserToInvitationList(user)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let user = delegate?.users?[indexPath.row] else { return }
        delegate?.removeUserFromInvitationList(user)
    }
}
