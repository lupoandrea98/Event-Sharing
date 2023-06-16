import UIKit

protocol ProfileViewDelegate: AnyObject {
    
    func performGetUserInfo(_ viewController: ProfileViewController)
    func performLogout(_ viewController: ProfileViewController)
    func userModify(_ viewController: ProfileViewController, username: String, email: String, image: UIImage)
    func presentList(_ viewController: ProfileViewController, _ requestedList: String)
    func presentInvitation(_ viewController: ProfileViewController)
    
}

class ProfileViewController: UIViewController {
    
    weak var delegate: ProfileViewDelegate?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var purchasedEventB: UIButton!
    @IBOutlet weak var favouriteEventB: UIButton!
    @IBOutlet weak var myEventB: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var purchasedNumber: UILabel!
    @IBOutlet weak var createdNumber: UILabel!
    @IBOutlet weak var favouriteNumber: UILabel!
    @IBOutlet weak var invitationButton: UIButton!
    @IBOutlet weak var invitationNumber: UILabel!
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var newNotification: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myEventB.layer.cornerRadius = 10;
        favouriteEventB.layer.cornerRadius = 10;
        purchasedEventB.layer.cornerRadius = 10;
        profileImage.layer.cornerRadius = 10;
        modifyButton.layer.cornerRadius = 6;

        usernameLabel.textColor = UIColor.systemBlue
        usernameLabel.font = UIFont(name: "Helvetica-Bold", size: 28)
        
        self.title = "Profile"
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
            NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 25)!
        ]
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .done, target: self, action: #selector(logoutClick))
        
        PresenterManager.profilePresenter?.mustUpdate = true
        delegate?.performGetUserInfo(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        delegate?.performGetUserInfo(self)
    }
    
    func presentAlert(_ viewController: UIViewController, _ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let attributedString = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 20) ?? UIFont.systemFont(ofSize: 22.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        viewController.present(alert, animated: true)
    }
    
    @objc func logoutClick(){
        delegate?.performLogout(self)
    }

    @IBAction func modifyUser(_ sender: Any) {
        delegate?.userModify(self, username: usernameLabel.text ?? "", email: emailLabel.text ?? "", image: profileImage.image ?? UIImage())
    }
    
    @IBAction func presentFavourites(_ sender: Any) {
        if favouriteNumber.text == "0" {
            presentAlert(self, "No favourite events saved", "")
        }
        delegate?.presentList(self, "favourites")
    }
    
    @IBAction func presentPrenotated(_ sender: Any) {
        if purchasedNumber.text == "0" {
            presentAlert(self, "No events booked", "")
        }
        delegate?.presentList(self, "partecipated")
    }
    
    @IBAction func presentCreated(_ sender: Any) {
        if createdNumber.text == "0" {
            presentAlert(self, "No events created", "")
        }
        delegate?.presentList(self, "created")
    }
    
    // MARK: Present invitations
    @IBAction func presentInvitations(_ sender: Any) {
        
        delegate?.presentInvitation(self)

    }
    
}
