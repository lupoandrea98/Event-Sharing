//
//  EventListViewController.swift
//  EventSharing
//
//  Created by certimeter on 27/04/23.
//

import UIKit

protocol EventListViewControllerDelegate: AnyObject {
    func getList(_ viewController: EventListViewController, _ requestedList: String)
    func numberOfRows(_ viewController: EventListViewController, _ requestedList: String) -> Int
    func dataForCell(index: Int, _ requestedList: String) -> Event?
    func selectedRow(_ viewController: EventListViewController, index: Int, _ requestedList: String)
}

class EventListViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: EventListViewControllerDelegate?
    var requestedList: String?                          // 'created'  'partecipated'  'favourites'
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 20
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 20
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "eventCell")
        tableView.backgroundColor = .clear
        guard let request = requestedList else {
            print("Requested List not valid")
            return
        }
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.90
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
          blurView.topAnchor.constraint(equalTo: view.topAnchor),
          blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
          blurView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        delegate?.getList(self, request)
    }
    
    @IBAction func closeList(_ sender: Any) {
        self.dismiss(animated: true)
    }

}

extension EventListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let request = requestedList else {
            print("Requested List not valid")
            return 0
        }
        guard let rows = delegate?.numberOfRows(self, request) else { return 0 }
        if rows == 0 {
            alertLabel.alpha = 1
        } else {
            alertLabel.alpha = 0
        }
        return rows
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        guard let request = requestedList else {
            print("Requested List not valid")
            return cell
        }
        guard let event = delegate?.dataForCell(index: indexPath.row, request) else {
            print("Errore nel recuperare dati dell'evento")
            return cell
        }
        cell.eventTitle.text = event.title
        cell.address.text = event.address
        if event.address == "Online" {
            cell.locationIcon.image = UIImage(systemName: "network")
        } else {
            cell.locationIcon.image = UIImage(systemName: "mappin.and.ellipse")
        }
        guard let eventImage = event.image else {
            return cell
        }
        cell.backgroundImage.image = UIImage(data: eventImage)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let request = requestedList else {
            print("Requested List not valid")
            return
        }
        delegate?.selectedRow(self, index: indexPath.row, request)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
