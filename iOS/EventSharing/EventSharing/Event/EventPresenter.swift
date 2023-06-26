import Foundation
import UIKit
import MapKit
    
final class EventPresenter: CreateViewControllerDelegate, ChooseLocationViewControllerDelegate {
    
    let eventService = EventService()
    let userService = UserService()
    var locationChanged: Bool = false
    var infoViewController: InfoEventViewController?
    var eventListViewController: EventListViewController?
    private var placemark: MKPlacemark? 
    private var createdEvents: [Event]?
    private var partecipateEvents: [Event]?
    private var favouritesEvents: [Event]?
    // MARK: CREATE AND CHOOSE DELEGATE
    func presentLocationSearch(_ viewController: CreateViewController, _ chooseLocationButton: UIButton){
        
        let locationViewController = ChooseLocationViewController()
        locationViewController.delegate = PresenterManager.eventPresenter
        locationViewController.chooseLocationButton = chooseLocationButton
        if self.placemark != nil {
            locationViewController.placemark = self.placemark
        }
        if let sheet = locationViewController.sheetPresentationController {
            sheet.detents = [ .medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        viewController.present(locationViewController, animated: true, completion: nil)
    }
    
    func setLocationChanged(_ isLocationChanged: Bool) {
        self.locationChanged = isLocationChanged
    }
    
    func containsOnlyNumbers(input: String) -> Bool {
        let regex = "^[0-9]*$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: input)
    }
    
    func isValidURL(_ urlString: String) -> Bool {
        if urlString == "" { return true }
        guard NSURL(string: urlString) != nil else { return false }
        let regEx = "((?:http|https)://)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format:"SELF MATCHES %@", regEx).evaluate(with: urlString)
    }
    
    func savePlacemark(_ placemark: MKPlacemark) {
        self.locationChanged = true
        self.placemark = placemark
        print("Location salvata: \(placemark.title ?? "niente placemark")")
    }
    
    func presentAlert(_ viewController: UIViewController, title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default))
        viewController.present(alert, animated: true)
    }

    func saveNewEvent(_ viewController: CreateViewController, title: String, image: UIImage? , date: String, category: String, description: String, maxPartecipant: String?, externalLink: String) {
        
        if title == "" {
            presentAlert(viewController, title: "Insert title", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.eventTitle.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        if category == "" {
            presentAlert(viewController, title: "Insert category", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.categoryTextField.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        if !containsOnlyNumbers(input: maxPartecipant ?? "") {
            presentAlert(viewController, title: "Number of partecipant not valid", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.maxPartecipantField.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        if description == "" {
            presentAlert(viewController, title: "Insert a description", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.eventDescription.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        var webSite = externalLink
        if webSite != "" && !webSite.hasPrefix("https://") {
            if !webSite.hasPrefix("http://"){
                webSite = "https://" + externalLink
            }
        }
        if !isValidURL(webSite) {
            presentAlert(viewController, title: "Insert valid URL", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.linkTextField.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        
        if date == "" {
            presentAlert(viewController, title: "Insert a date", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.dateField.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        
        var imageStr = ""
        if let imageData = image?.pngData() {
            imageStr = imageData.base64EncodedString()
        }

        var maxPeople = 0
        if let num = Int(maxPartecipant ?? "") {
            maxPeople = num
        }
        
        guard let owner = UserDefaultsManager.shared.value else {
            presentAlert(viewController, title: "Error", message: "User not valid, please login again", action: "Ok")
            PresenterManager.mainPresenter?.presentLogin()
            return
        }
        var address = ""
        if placemark?.locality == nil || placemark?.country == nil {
            address = placemark?.name ?? ""
        } else {
            address = "\(placemark?.locality ?? ""), \(placemark?.country ?? "")"
        }
        
        eventService.saveNewEvent(title: title, image: imageStr, date: date, latitude: placemark?.coordinate.latitude ?? 0, longitude: placemark?.coordinate.longitude ?? 0, address: address, category: category, description: description, owner: owner, maxPartecipant: maxPeople , externalLink: webSite) {
                result in
            if result == "true" {
                self.presentAlert(viewController, title: "Success", message: "Event saved", action: "Ok")
                self.resetInputCreate(viewController)
                PresenterManager.homePresenter?.mustUpdate = true
                PresenterManager.homePresenter?.homeViewController?.delegate?.getEventsByZone(PresenterManager.homePresenter!.homeViewController!)
                PresenterManager.profilePresenter?.mustUpdate = true
                if let profileController = PresenterManager.profilePresenter!.profileViewController {
                    PresenterManager.profilePresenter?.performGetUserInfo(profileController)
                }
                
            } else {
                self.presentAlert(viewController, title: "Error", message: "Event not saved correctly", action: "Ok")

            }
        }
    }
    // MARK: Update Event
    func updateEvent(_ viewController: CreateViewController, title: String, image: UIImage?, date: String, category: String, description: String, maxPartecipant: String?, externalLink: String, eventId: Int, oldLatitude: Double, oldLongitude: Double, address: String) {
        var latitude = oldLatitude
        var longitude = oldLongitude
        var addr = address
        if locationChanged {
            latitude = placemark?.coordinate.latitude ?? 0
            longitude = placemark?.coordinate.longitude ?? 0
            if placemark?.locality == "" || placemark?.country == "" {
                addr = placemark?.title ?? ""
            } else {
                addr = "\(placemark?.locality ?? ""), \(placemark?.country ?? "")"
            }
        }
        if title == "" {
            presentAlert(viewController, title: "Insert title", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.eventTitle.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        
        if category == "" {
            presentAlert(viewController, title: "Insert a category", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.categoryTextField.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        if !containsOnlyNumbers(input: maxPartecipant ?? "") {
            presentAlert(viewController, title: "Number of partecipant not valid", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.maxPartecipantField.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        
        var imageStr = ""
        if let imageData = image?.pngData() {
            imageStr = imageData.base64EncodedString()
        }
        
        if description == "" {
            presentAlert(viewController, title: "Insert a description", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.eventDescription.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        
        var webSite = externalLink
        if webSite != "" && !webSite.hasPrefix("https://") {
            if !webSite.hasPrefix("http://"){
                webSite = "https://" + externalLink
            }
        }
        if !isValidURL(webSite) {
            presentAlert(viewController, title: "Insert valid URL", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.linkTextField.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        
        if date == ""{
            presentAlert(viewController, title: "Insert a date", message: "", action: "Ok")
            UIView.animate(withDuration: 0.2) {
                viewController.dateField.layer.borderColor = UIColor.systemRed.cgColor
            }
            return
        }
        
        guard let owner = UserDefaultsManager.shared.value else {
            presentAlert(viewController, title: "Error", message: "User not valid, please login again", action: "Ok")
            PresenterManager.mainPresenter?.presentLogin()
            return
        }
        
        
        var maxPeople = 0
        if let num = Int(maxPartecipant ?? "") {
            maxPeople = num
        }
   
        eventService.updateEvent(title: title, image: imageStr, date: date, latitude: latitude, longitude: longitude, address: addr, category: category, description: description, owner: owner, maxPartecipant: maxPeople, externalLink: webSite, eventId: eventId) {
            result in
            if result == "true" {
                PresenterManager.homePresenter?.mustUpdate = true
                PresenterManager.homePresenter?.homeViewController?.delegate?.getEventsByZone(PresenterManager.homePresenter!.homeViewController!)
                PresenterManager.profilePresenter?.mustUpdate = true
                if let profileController = PresenterManager.profilePresenter!.profileViewController {
                    PresenterManager.profilePresenter?.performGetUserInfo(profileController)
                }
                self.resetInputCreate(viewController)
                let alert = UIAlertController(title: "Event updated", message: "", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default) {
                    (action: UIAlertAction) in
                    PresenterManager.eventPresenter?.infoViewController?.delegate?.updateData(PresenterManager.eventPresenter!.infoViewController!, eventId: eventId)
                    viewController.dismiss(animated: true)
                }
                alert.addAction(alertAction)
                viewController.present(alert, animated: true)
                
            } else {
                self.presentAlert(viewController, title: "Error", message: result, action: "Ok")

            }
        }
    }
    
    // MARK: ResetCreate
    func resetInputCreate(_ viewController: CreateViewController) {
        viewController.eventImage.image = UIImage()
        viewController.eventTitle.text = ""
        viewController.chooseLocation.setTitle("Choose Location", for: .normal)
        viewController.chooseLocation.setImage(UIImage(systemName: "location.magnifyingglass"), for: .normal)
        viewController.eventDescription.text = ""
        viewController.categoryTextField.text = ""
        viewController.maxPartecipantField.text = ""
        viewController.dateField.text = ""
        viewController.linkTextField.text = ""
        viewController.descriptionPlaceholder.alpha = 1
        viewController.imageConstraint.isActive = true
        viewController.eventTitle.layer.borderColor = UIColor.systemBlue.cgColor
        viewController.categoryTextField.layer.borderColor = UIColor.systemBlue.cgColor
        viewController.eventDescription.layer.borderColor = UIColor.systemBlue.cgColor
        viewController.linkTextField.layer.borderColor = UIColor.systemBlue.cgColor
        viewController.dateField.layer.borderColor = UIColor.systemBlue.cgColor
        viewController.maxPartecipantField.layer.borderColor = UIColor.systemBlue.cgColor
        
        self.placemark = nil
    }

    func startCreate() -> CreateViewController{
        let createViewController = CreateViewController()
        createViewController.delegate = self
        return createViewController
    }

}
// MARK: INFO DELEGATE
extension EventPresenter: InfoEventViewControllerDelegate {
    func showUsersList(_ viewController: InfoEventViewController) {
        PresenterManager.mainPresenter?.presentUserList(viewController)
    }
    
    func updateData(_ viewController: InfoEventViewController, eventId: Int) {
        if PresenterManager.homePresenter?.takeEvent(eventId) == nil {
            eventService.getEvent(eventId) { event in
                viewController.update = true
                viewController.event = event
                viewController.viewDidAppear(true)
            }
        } else {
            guard let event = PresenterManager.homePresenter?.takeEvent(eventId) else { return }
            viewController.update = true
            viewController.event = event
            viewController.viewDidAppear(true)
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: String.Encoding.ascii) else { return nil }
            if let QRFilter = CIFilter(name: "CIQRCodeGenerator") {
                QRFilter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 4, y: 4)
                if let outputQR = QRFilter.outputImage?.transformed(by: transform) {
                    return UIImage(ciImage: outputQR)
                }
            }
        return nil
       
    }
    
    
    func convertCoordinatesToPlacemark(latitude: Double, longitude: Double, completion: @escaping(_ address: CLPlacemark?) -> ()){
        let geocoder = CLGeocoder()

        let location = CLLocation(latitude: latitude, longitude: longitude)

        geocoder.reverseGeocodeLocation(location) {
            (placemarks, error) in
            
            guard error == nil else {
                print("Errore nel convertire le coordinate in un indirizzo: \(error!.localizedDescription)")
                return
            }
            if latitude == 0 && longitude == 0 {
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    completion(placemark)
                }
            }
        }
    }
    
    func eventModification(_ viewController: InfoEventViewController, eventId: Int, placemark: CLPlacemark?) {
        if PresenterManager.homePresenter?.takeEvent(eventId) == nil {
            eventService.getEvent(eventId) { event in
                if let place = placemark{
                    self.placemark = MKPlacemark(placemark: place)
                }
                let modifyViewController = CreateViewController()
                modifyViewController.event = event
                modifyViewController.delegate = PresenterManager.eventPresenter
                modifyViewController.isModify = true
                viewController.present(modifyViewController, animated: true)
            }
        } else {
            guard let event = PresenterManager.homePresenter?.takeEvent(eventId) else { return }
            if let place = placemark{
                self.placemark = MKPlacemark(placemark: place)
            }
            let modifyViewController = CreateViewController()
            modifyViewController.event = event
            modifyViewController.delegate = PresenterManager.eventPresenter
            modifyViewController.isModify = true
            viewController.present(modifyViewController, animated: true)
        }
       
        
    }
    // MARK: Remove Partecipation
    func removePartecipation(_ viewController: InfoEventViewController, eventId: Int?) {
        guard let event = eventId else {
            print("Evento non valido")
            return
        }
//        guard var numPartecipant = viewController.event?.num_partecipant else { return }
//        numPartecipant -= 1

        eventService.removePartecipation(event) {
            result in
            if result == "true" {
                viewController.partecipate.image = UIImage(systemName: "plus.app")
                viewController.isPartecipate = false
                PresenterManager.homePresenter?.mustUpdate = true
                if let homeViewController = PresenterManager.homePresenter?.homeViewController {
                    PresenterManager.homePresenter?.getEventsByZone(homeViewController)
                }
                PresenterManager.profilePresenter?.mustUpdate = true
                if let profileController = PresenterManager.profilePresenter!.profileViewController {
                    PresenterManager.profilePresenter?.performGetUserInfo(profileController)
                }
                viewController.partecipate.isUserInteractionEnabled = true
                viewController.update = true
                if var numPartecipant = viewController.event?.num_partecipant {
                    numPartecipant -= 1
                    viewController.event?.num_partecipant = numPartecipant
                }
                viewController.viewDidAppear(true)
                //self.updateData(viewController, eventId: event)
            } else {
               // numPartecipant += 1
                self.presentAlert(viewController, title: "Error", message: result, action: "Ok")
            }
//            if viewController.event?.max_partecipnt == 0 {
//                viewController.numPeople.text = "\(numPartecipant) partecipant"
//            } else {
//                viewController.numPeople.text = "\(numPartecipant) partecipant of \(viewController.event?.max_partecipnt ?? 0)"
//            }
        }
    }
    
    // MARK: Add partecipation
    func partecipateToEvent(_ viewController: InfoEventViewController, eventId: Int) {
//        guard var numPartecipant = viewController.event?.num_partecipant else { return }
//        numPartecipant += 1
        eventService.addPartecipation(eventId) {
            result in
            if result == "true" {
                viewController.partecipate.image = UIImage(systemName: "plus.app.fill")
                viewController.isPartecipate = true
                PresenterManager.homePresenter?.mustUpdate = true
                if let homeViewController = PresenterManager.homePresenter?.homeViewController {
                    PresenterManager.homePresenter?.getEventsByZone(homeViewController)
                }
                PresenterManager.profilePresenter?.mustUpdate = true
                if let profileController = PresenterManager.profilePresenter!.profileViewController {
                    PresenterManager.profilePresenter?.performGetUserInfo(profileController)
                }
                viewController.partecipate.isUserInteractionEnabled = true
                viewController.update = true
                if var numPartecipant = viewController.event?.num_partecipant {
                    numPartecipant += 1
                    viewController.event?.num_partecipant = numPartecipant

                }
                viewController.viewDidAppear(true)
                //self.updateData(viewController, eventId: eventId)
            } else {
                //numPartecipant -= 1
                self.presentAlert(viewController, title: "Error", message: result, action: "Ok")
            }
//            if viewController.event?.max_partecipnt == 0 {
//                viewController.numPeople.text = "\(numPartecipant) partecipant"
//            } else {
//                viewController.numPeople.text = "\(numPartecipant) partecipant of \(viewController.event?.max_partecipnt ?? 0)"
//            }
        }
    }
    
    func addToFavourites(_ viewController: InfoEventViewController, eventId: Int) {
        eventService.addToFavourites(eventId) {
            result in
            if result == "true" {
                viewController.addToFavourite.image = UIImage(systemName: "heart.fill")
                viewController.isFavourite = true
                PresenterManager.homePresenter?.mustUpdate = true
                if let homeViewController = PresenterManager.homePresenter?.homeViewController {
                    PresenterManager.homePresenter?.getEventsByZone(homeViewController)
                }
                PresenterManager.profilePresenter?.mustUpdate = true
                if let profileController = PresenterManager.profilePresenter!.profileViewController {
                    PresenterManager.profilePresenter?.performGetUserInfo(profileController)
                }
                viewController.addToFavourite.isUserInteractionEnabled = true
            } else {
                self.presentAlert(viewController, title: "Error", message: result, action: "Ok")
            }
        }
    }
    
    func removeFromFavourites(_ viewController: InfoEventViewController, eventId: Int?) {
        guard let event = eventId else {
            print("Evento non valido")
            return
        }
        
        eventService.removeFromFavourite(event) { result in
            if result == "true" {
                viewController.addToFavourite.image = UIImage(systemName: "heart")
                viewController.isFavourite = false
                PresenterManager.homePresenter?.mustUpdate = true
                if let homeViewController = PresenterManager.homePresenter?.homeViewController {
                    PresenterManager.homePresenter?.getEventsByZone(homeViewController)
                }
                PresenterManager.profilePresenter?.mustUpdate = true
                if let profileController = PresenterManager.profilePresenter!.profileViewController {
                    PresenterManager.profilePresenter?.performGetUserInfo(profileController)
                }
                viewController.addToFavourite.isUserInteractionEnabled = true
            } else {
                self.presentAlert(viewController, title: "Error", message: result, action: "Ok")
            }
        }
    }
    
    func checkPartecipate(_ viewController: InfoEventViewController, eventId: Int?) {
        guard let event = eventId else {
            print("Evento non valido")
            return
        }
        guard let user = UserDefaultsManager.shared.value else {
            print("Impossibile recuperare l'UserID")
            return
        }
        eventService.checkPartecipate(event, user) {
            result in
            if result {
                //L'utente partecipa all'evento icona piena
                viewController.partecipate.image = UIImage(systemName: "plus.app.fill")
                viewController.isPartecipate = true
            } else {
                //L'utente non partecipa all'evento icona vuota
                viewController.partecipate.image = UIImage(systemName: "plus.app")
                viewController.isPartecipate = false
            }
        }
    }
    
    
    func checkFavourites(_ viewController: InfoEventViewController, eventId: Int?) {
        guard let event = eventId else {
            print("Evento non valido")
            return
        }
        guard let user = UserDefaultsManager.shared.value else {
            print("Impossibile recuperare l'UserID")
            return
        }
        eventService.checkFavourites(event, user) {
            result in
            if result {
                //L'utente partecipa all'evento icona piena
                viewController.addToFavourite.image = UIImage(systemName: "heart.fill")
                viewController.isFavourite = true
            } else {
                //L'utente non partecipa all'evento icona vuota
                viewController.addToFavourite.image = UIImage(systemName: "heart")
                viewController.isFavourite = false
            }
        }
    }
    
    
    
    func deleteEvent(_ viewController: InfoEventViewController, eventId: Int) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let attributedString = NSAttributedString(string: "Are you sure you want to delete the event?", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 20) ?? UIFont.systemFont(ofSize: 22.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        alert.setValue(attributedString, forKey: "attributedTitle")
        let alertAction = UIAlertAction(title: "Yes", style: .default) {
            (action: UIAlertAction) in
            self.eventService.deleteEvent(eventId) {
                result in
                if result == "true" {
                    let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
                    let attributedString = NSAttributedString(string: "Event deleted", attributes: [
                        NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18) ?? UIFont.systemFont(ofSize: 22.0, weight: .bold),
                        NSAttributedString.Key.foregroundColor: UIColor.black
                    ])
                    alert.setValue(attributedString, forKey: "attributedTitle")
                    let alertAction = UIAlertAction(title: "Ok", style: .default) {
                        (action: UIAlertAction) in
                        viewController.dismiss(animated: true)
                        
                        viewController.parentView?.delegate?.deleteLocalEvent(eventId)
                        if let annotations = viewController.parentView?.mapView.annotations {
                            for event in annotations {
                                let ev = event as? EventMapAnnotation
                                if ev?.eventId == eventId {
                                    viewController.parentView?.mapView.removeAnnotation(event)
                                }
                            }
                        }
                        viewController.parentView?.tableView.reloadData()
                    }
                    alert.addAction(alertAction)
                    viewController.present(alert, animated: true)
                    if let homeViewController = PresenterManager.homePresenter?.homeViewController {
                        PresenterManager.homePresenter?.mustUpdate = true
                        homeViewController.delegate?.getEventsByZone(homeViewController)
                    }
                    if let profileController = PresenterManager.profilePresenter!.profileViewController {
                        PresenterManager.profilePresenter?.mustUpdate = true
                        PresenterManager.profilePresenter?.performGetUserInfo(profileController)
                    }
                } else {
                    self.presentAlert(viewController, title: "Error", message: result, action: "Ok")
                }
            }
        }
        let alertAction1 = UIAlertAction(title: "No!", style: .destructive)
        alert.addAction(alertAction)
        alert.addAction(alertAction1)
        viewController.present(alert, animated: true)
    }
}
// MARK: EVENT LIST DELEGATE
extension EventPresenter: EventListViewControllerDelegate {
    func numberOfRows(_ viewController: EventListViewController, _ requestedList: String) -> Int {
        switch requestedList{
        case "created":
            guard let created = createdEvents else { return 0 }
            return created.count
        case "partecipated":
            guard let partecipate = partecipateEvents else { return 0 }
            return partecipate.count
        case "favourites":
            guard let favourites = favouritesEvents else { return 0 }
            return favourites.count
        default:
            self.presentAlert(viewController, title: "Wrong request", message: "", action: "Ok")
            return 0
        }
    }
    
    func dataForCell(index: Int, _ requestedList: String) -> Event? {
        switch requestedList{
        case "created":
            guard let created = createdEvents?[index] else { return nil }
            return created
        case "partecipated":
            guard let partecipate = partecipateEvents?[index] else { return nil }
            return partecipate
        case "favourites":
            guard let favourite = favouritesEvents?[index] else { return nil }
            return favourite
        default:
            return nil
        }
    }
    
    func selectedRow(_ viewController: EventListViewController, index: Int, _ requestedList: String) {
        var event: Event?
        switch requestedList{
        case "created":
            event = createdEvents?[index]
        case "partecipated":
            event = partecipateEvents?[index]
        case "favourites":
            event = favouritesEvents?[index]
        default:
            return
        }
        guard let event = event else { return }
        let infoViewController = InfoEventViewController()
        self.infoViewController = infoViewController
        infoViewController.delegate = PresenterManager.eventPresenter
        infoViewController.owner_id = event.owner
        userService.getUserName(userId: event.owner) { username in
            infoViewController.event = event
            infoViewController.event?.owner = username
            viewController.present(infoViewController, animated: true)
        }
    }
    
    func getList(_ viewController: EventListViewController, _ requestedList: String) {
        guard let userId = UserDefaultsManager.shared.value else {
            print("Impossibile recuperare l'UserID")
            return
        }
        eventService.getEventList(requestedList, userId) {
            events in
            switch requestedList{
            case "created":
                self.createdEvents = events
                guard let tableView = viewController.tableView else { return }
                tableView.reloadData()
            case "partecipated":
                self.partecipateEvents = events
                guard let tableView = viewController.tableView else { return }
                tableView.reloadData()
            case "favourites":
                self.favouritesEvents = events
                guard let tableView = viewController.tableView else { return }
                tableView.reloadData()
            default:
                self.presentAlert(viewController, title: "Wrong request", message: "", action: "Ok")
            }
        }
    }
    
    
}
