import UIKit
import MapKit
import AVFoundation

protocol InfoEventViewControllerDelegate: AnyObject {
    func deleteEvent(_ viewController: InfoEventViewController, eventId: Int)
    func partecipateToEvent(_ viewController: InfoEventViewController, eventId: Int)
    func removePartecipation(_ viewController: InfoEventViewController, eventId: Int?)
    func addToFavourites(_ viewController: InfoEventViewController, eventId: Int)
    func removeFromFavourites(_ viewController: InfoEventViewController, eventId: Int?)
    func checkPartecipate(_ viewController: InfoEventViewController, eventId: Int?)
    func checkFavourites(_ viewController: InfoEventViewController, eventId: Int?)
    func eventModification(_ viewController: InfoEventViewController, eventId: Int, placemark: CLPlacemark?)
    func convertCoordinatesToPlacemark(latitude: Double, longitude: Double, completion: @escaping(_ address: CLPlacemark?) -> ())
    func generateQRCode(from string: String) -> UIImage?
    func updateData(_ viewController: InfoEventViewController, eventId: Int)
    func showUsersList(_ viewController: InfoEventViewController)
}

class InfoEventViewController: UIViewController {
    
    var event: Event? = nil
    var placemark: CLPlacemark?
    var owner_id: String? = nil
    var delegate: InfoEventViewControllerDelegate? 
    weak var parentView: HomeViewController?
    var isPartecipate: Bool?
    var isFavourite: Bool?
    var update: Bool = false
    var captureSession: AVCaptureSession?
    
    @IBOutlet var imageConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var imageMask: UIView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventOwner: UILabel!
    @IBOutlet weak var eventLocation: UIButton!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var addToFavourite: UIImageView!
    @IBOutlet weak var partecipate: UIImageView!
    @IBOutlet weak var internetSite: UIImageView!
    @IBOutlet weak var showQR: UIImageView!
    @IBOutlet weak var deleteButton: UIImageView!
    @IBOutlet weak var modifyButton: UIImageView!
    @IBOutlet weak var numPeople: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var bottomStack: UIStackView!
    @IBOutlet weak var dateMask: UIView!
    @IBOutlet weak var partecipantMask: UIView!
    @IBOutlet weak var inviteButton: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    var progress = Progress(totalUnitCount: 100)
    var variation: Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eventLocation.layer.cornerRadius = 7
        
        dateMask.layer.borderColor = UIColor.systemBlue.cgColor
        dateMask.layer.borderWidth = 1
        dateMask.layer.cornerRadius = 10
        
        progressBar.progress = 0
        
        if owner_id != UserDefaultsManager.shared.value {
            deleteButton.isHidden = true
            modifyButton.isHidden = true
            bottomStack.layoutIfNeeded()
        }
        delegate?.checkPartecipate(self, eventId: event?.id)
        delegate?.checkFavourites(self, eventId: event?.id)
     
        eventTitle?.text = event?.title
        eventDescription?.text = event?.description
        eventDate?.text = event?.date
        eventOwner?.text = event?.owner
        eventLocation?.setTitle(event?.address, for: .normal)
        if(event?.address == "Online") {
            eventLocation.setImage(UIImage(systemName: "network"), for: .normal)
        }
        if event?.max_partecipnt == 0 {
            numPeople.text = "\(event?.num_partecipant ?? 0) partecipant"
            progress.completedUnitCount = Int64(100)
            progressBar.progressTintColor = UIColor.systemGreen

        } else {
            numPeople.text = "\(event?.num_partecipant ?? 0) partecipant of \(event?.max_partecipnt ?? 0)"
            var partecipant = event?.num_partecipant ?? 0
            var max = event?.max_partecipnt ?? 0
            var puppa = (partecipant*100)/max
            progress.completedUnitCount = Int64(puppa)
            if progress.completedUnitCount >= 90 {
                progressBar.progressTintColor = UIColor.systemRed
            } else if progress.completedUnitCount >= 50 {
                progressBar.progressTintColor = UIColor.systemYellow
            }
        }
        variation = Float(progress.fractionCompleted)
        
        if event?.image == Data() {
            imageConstraint.constant = 175
        }
        if let imageData = event?.image {
            eventImage?.image = UIImage(data: imageData)
        }
        
        let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(deleteEvent))
        deleteButton.isUserInteractionEnabled = true
        deleteButton.addGestureRecognizer(deleteGesture)
        
        let partecipateGesture = UITapGestureRecognizer(target: self, action: #selector(partecipateToEvent))
        partecipate.isUserInteractionEnabled = true
        partecipate.addGestureRecognizer(partecipateGesture)
        
        let favouriteGesture = UITapGestureRecognizer(target: self, action: #selector(addFavourite))
        addToFavourite.isUserInteractionEnabled = true
        addToFavourite.addGestureRecognizer(favouriteGesture)
        
        let modifyGesture = UITapGestureRecognizer(target: self, action: #selector(modification))
        modifyButton.isUserInteractionEnabled = true
        modifyButton.addGestureRecognizer(modifyGesture)
        
        let qrGesture = UITapGestureRecognizer(target: self, action: #selector(showQRCode))
        showQR.isUserInteractionEnabled = true
        showQR.addGestureRecognizer(qrGesture)
        
        let maskGesture = UITapGestureRecognizer(target: self, action: #selector(hideMaskView))
        maskView.isUserInteractionEnabled = true
        maskView.addGestureRecognizer(maskGesture)
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(dismissInfo))
        backButton.isUserInteractionEnabled = true
        backButton.addGestureRecognizer(backGesture)
        
        let inviteGesture = UITapGestureRecognizer(target: self, action: #selector(presentInvite))
        inviteButton.isUserInteractionEnabled = true
        inviteButton.addGestureRecognizer(inviteGesture)
        
        if let url = URL(string: event?.externalLink ?? ""), UIApplication.shared.canOpenURL(url) {
            let linkGesture = UITapGestureRecognizer(target: self, action: #selector(webLink))
            internetSite.isUserInteractionEnabled = true
            internetSite.addGestureRecognizer(linkGesture)
        } else {
            internetSite.isHidden = true
            bottomStack.layoutIfNeeded()
        }
        qrImage.layer.cornerRadius = 20
        
        maskView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.alpha = 0.95
        maskView.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
          blurView.topAnchor.constraint(equalTo: maskView.topAnchor),
          blurView.leadingAnchor.constraint(equalTo: maskView.leadingAnchor),
          blurView.heightAnchor.constraint(equalTo: maskView.heightAnchor),
          blurView.widthAnchor.constraint(equalTo: maskView.widthAnchor)
        ])
        delegate?.convertCoordinatesToPlacemark(latitude: event?.latitude ?? 0, longitude: event?.longitude ?? 0) {
            placemark in
            self.placemark = placemark
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        //guard let up = update else { return }
        if update {
            eventTitle?.text = event?.title
            eventDescription?.text = event?.description
            eventDate?.text = event?.date
            eventLocation?.setTitle(event?.address, for: .normal)
            if(event?.address == "Online") {
                eventLocation.setImage(UIImage(systemName: "network"), for: .normal)
            }
            if event?.max_partecipnt == 0 {
                numPeople.text = "\(event?.num_partecipant ?? 0) partecipant"
                progress.completedUnitCount = Int64(100)
                progressBar.progressTintColor = UIColor.systemGreen
            } else {
                numPeople.text = "\(event?.num_partecipant ?? 0) partecipant of \(event?.max_partecipnt ?? 0)"
                var partecipant = event?.num_partecipant ?? 0
                var max = event?.max_partecipnt ?? 0
                progress.completedUnitCount = Int64((partecipant*100)/max)
                if progress.completedUnitCount > 90 {
                    progressBar.progressTintColor = UIColor.systemRed
                } else if progress.completedUnitCount > 50 {
                    progressBar.progressTintColor = UIColor.systemYellow
                }
            }
            variation = Float(progress.fractionCompleted)
            
            if event?.image == Data() {
                imageConstraint.constant = 175
            } else {
                imageConstraint.constant = 320
            }
            if let imageData = event?.image {
                eventImage?.image = UIImage(data: imageData)
            }
            if let url = URL(string: event?.externalLink ?? ""), UIApplication.shared.canOpenURL(url) {
                let linkGesture = UITapGestureRecognizer(target: self, action: #selector(webLink))
                internetSite.isUserInteractionEnabled = true
                internetSite.addGestureRecognizer(linkGesture)
            } else {
                internetSite.isHidden = true
            }
        }
        update = false
        guard let variation = variation else {
            progressBar.setProgress(0, animated: true)
            return
        }
        progressBar.setProgress(variation, animated: true)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard let captSession = captureSession else { return }
        if !captSession.isRunning {
            DispatchQueue.global(qos: .background).async {
                captSession.startRunning()
            }
        }
    }
    
    @IBAction func mapLinkAction(_ sender: Any) {
        guard let place = self.placemark else { return }
        if event?.address == "Online" { return }
        let destination = MKMapItem(placemark: MKPlacemark(placemark: place))
        destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
    
    @objc func showQRCode() {
        guard let idEvent = event?.id else {
            print("errore nel prendere l'id")
            return
        }
        guard let qr = delegate?.generateQRCode(from: "\(idEvent)") else {
            print("Impossibile trovare qrCode")
            return
        }
        qrImage.image = qr
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.maskView.alpha = 1
        }
        
    }
    
    @objc func hideMaskView() {
        UIView.animate(withDuration: 0.3) {
            self.maskView.alpha = 0
        }
    }

    @objc func deleteEvent() {
        guard let eventId = event?.id else {
            print("nessun id disponibile")
            let alert = UIAlertController(title: "Failed to delete the event", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)
            return
        }
        delegate?.deleteEvent(self, eventId: eventId)
    }
    
    @objc func modification(){
        guard let eventId = event?.id else {
            print("id evento non valido")
            return
        }
        delegate?.eventModification(self, eventId: eventId, placemark: self.placemark)
    }

    
    @objc func partecipateToEvent() {
        partecipate.isUserInteractionEnabled = false
        guard let eventId = event?.id else {
            print("nessun id disponibile")
            let alert = UIAlertController(title: "Error", message: "event not valid", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)
            return
        }
        guard let partecipation = isPartecipate else{
            return
        }
        if partecipation {
            delegate?.removePartecipation(self, eventId: eventId)
        } else {
            delegate?.partecipateToEvent(self, eventId: eventId)
        }

    }
    
    @objc func addFavourite() {
        addToFavourite.isUserInteractionEnabled = false
        guard let eventId = event?.id else {
            print("nessun id disponibile")
            let alert = UIAlertController(title: "Event not valid", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)
            return
        }
        guard let favourite = isFavourite else{
            return
        }
        if favourite {
            delegate?.removeFromFavourites(self, eventId: eventId)
        } else {
            delegate?.addToFavourites(self, eventId: eventId)
        }
    }
    
    @objc func webLink() {
        guard let link = event?.externalLink else {
            presentAlert(self, "Nessun Link", "")
            return
        }
        if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        
    }
    
    @objc func dismissInfo() {
        self.dismiss(animated: true)
    }
    
    @objc func presentInvite() {
        delegate?.showUsersList(self)
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
 
}

