import UIKit
import MapKit

protocol HomeViewDelegate: HomePresenter {
    func getEvents(_ viewController: HomeViewController)
    func getEventsByZone(_ viewController: HomeViewController)
    func convertCoordinates(_ cell: EventTableViewCell, _ latitude: Double, _ longitude: Double)
    func numberOfRows(_ :HomeViewController) -> Int
    func dataForCell(index: Int) -> Event?
    func selectedRow(_ viewController: HomeViewController, index: Int)
    func switchToMapView(_ viewController: HomeViewController, _ sender: UISegmentedControl)
    func deleteLocalEvent(_ eventId: Int)
    func popolateMapView(_ viewController: HomeViewController)
    func presentEventInfo(_ viewController: HomeViewController, _ eventId: Int)
}

class HomeViewController: UIViewController{
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var userLocationButton: UIButton!
    @IBOutlet weak var noEventAlert: UIView!
    @IBOutlet weak var switchMap: UISegmentedControl!
    @IBOutlet weak var mapSection: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchHereButton: UIButton!
    weak var delegate: HomeViewDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        mapView.delegate = self
        mapSection.isHidden = true
        mapView.showsUserLocation = true

        tableView.isHidden = false
        tableView.layer.cornerRadius = 20
        mapView.layer.cornerRadius = 20
        searchHereButton.layer.cornerRadius = 15

        mapSection.layer.shadowColor = UIColor.black.cgColor
        mapSection.layer.shadowOpacity = 0.5
        mapSection.layer.shadowOffset = CGSize(width: -5, height: 5)
        mapSection.layer.shadowRadius = 10
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "eventCell")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard (PresenterManager.mainPresenter?.loader(self)) != nil else {
            print("Non è possibile caricare il loader")
            return
        }
        if locationManager.authorizationStatus == .denied {
            PresenterManager.mainPresenter?.stopLoader()
        }

    }
    
    @IBAction func locationAction(_ sender: Any) {
        centerUserInMap()
    }
    func centerUserInMap() {
        if let userLocation = mapView.userLocation.location {
            mapView.setCenter(userLocation.coordinate, animated: true)
            let span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    
    @IBAction func switchToMap(_ sender: UISegmentedControl) {
        delegate?.switchToMapView(self, sender)
    }
    
    
    @IBAction func searchNewEvents(_ sender: Any) {
        delegate?.currentRegion = mapView.region
        delegate?.mustUpdate = true
        delegate?.getEventsByZone(self)
        
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rows = delegate?.numberOfRows(self) else {
            noEventAlert.alpha = 1
            return 0
            
        }
        if rows == 0 {
            noEventAlert.alpha = 1
        } else {
            noEventAlert.alpha = 0
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        guard let event = delegate?.dataForCell(index: indexPath.row) else {
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
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedRow(self, index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is EventMapAnnotation else { return nil }
        
        let identifier = "EventMapAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView?.annotation = annotation

        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let tmpEvent = view.annotation as? EventMapAnnotation else { return }
        delegate?.presentEventInfo(self, tmpEvent.eventId)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.4) {
            self.searchHereButton.alpha = 1
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if let userLocation = locationManager.location {
                mapView.setCenter(userLocation.coordinate, animated: true)
                let span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
                let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
                delegate?.currentRegion = region
                mapView.setRegion(region, animated: true)
            } else {
                delegate?.currentRegion = mapView.region
            }
            delegate?.getEventsByZone(self)
        
            print("L'utente ha concesso l'autorizzazione all'accesso alla posizione")
        case .denied:
            print("L'utente ha negato l'autorizzazione all'accesso alla posizione")
        case .notDetermined:
            print("L'utente non ha ancora deciso sull'autorizzazione all'accesso alla posizione")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errore nella richiesta di autorizzazione alla posizione: \(error.localizedDescription)")
    }
    
}

