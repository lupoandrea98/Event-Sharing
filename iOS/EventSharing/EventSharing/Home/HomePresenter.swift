import Foundation
import MapKit
import UIKit
import CoreLocation

final class HomePresenter {
    
    let eventService = EventService()
    let userService = UserService()
    var homeViewController: HomeViewController?
    var mustUpdate: Bool = true
    var startLocation: Bool = true
    var events: [Event]?
    var allEvents: [Event]?
    var currentRegion: MKCoordinateRegion?
    
    func startBarController(_ viewController: UIViewController) {
        let barController = TabBarViewController()
        viewController.navigationController?.setViewControllers([barController], animated: true)
        barController.delegate = barController
    }
    
    func startBarController(onWindow: UIWindow) {
        let barController = TabBarViewController()
        barController.delegate = barController
        onWindow.rootViewController = barController
    }
    
    func startHome() -> HomeViewController{
        let homeController = HomeViewController()
        homeController.delegate = self
        self.getEvents(homeController)
        self.homeViewController = homeController
        PresenterManager.mainPresenter?.loader(homeController)
        return homeController
    }
    
    func convertCoordinatesToAddress(latitude: Double, longitude: Double, completion: @escaping(_ address: String) -> ()){
        let geocoder = CLGeocoder()

        let location = CLLocation(latitude: latitude, longitude: longitude)

        geocoder.reverseGeocodeLocation(location) {
            (placemarks, error) in
            
            guard error == nil else {
                print("Errore nel convertire le coordinate in un indirizzo: \(error!.localizedDescription)")
                return
            }

            if let placemark = placemarks?.first {
                let address = "\(placemark.locality ?? ""), \(placemark.country ?? "")"
                DispatchQueue.main.async {
                    completion(address)
                }
            }
        }
    }
    
    func takeEvent(_ eventId: Int) -> Event? {
        guard let evs = events else {
            print("Impossibile recuperare gli eventi")
            return nil
        }
        for event in evs{
            print(event.id)
            if event.id == eventId {
                return event
            }
        }
    
        return nil
    }
    
    func getHomeViewController() -> HomeViewController? {
        guard let controller = self.homeViewController else {
            return nil
        }
        return controller
        
    }
    
}

extension HomePresenter: HomeViewDelegate {

    func getEventsByZone(_ viewController: HomeViewController) {

        guard let region = currentRegion else { return }
        
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + region.span.latitudeDelta/2, longitude: region.center.longitude - region.span.longitudeDelta/2)
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - region.span.latitudeDelta/2, longitude: region.center.longitude + region.span.longitudeDelta/2)
        if mustUpdate {
            eventService.getEventsByZone(topLeft.latitude, topLeft.longitude, bottomRight.latitude, bottomRight.longitude) { events in
                self.events = events
                self.popolateMapView(viewController)
                viewController.tableView.reloadData()
                //NotificationCenter.default.post(name: Notification.Name("eventsModified"), object: nil)
                PresenterManager.mainPresenter?.stopLoader()
                self.mustUpdate = false
                UIView.animate(withDuration: 0.4) {
                    viewController.searchHereButton.alpha = 0
                }
            }
            self.getEvents(viewController)
        }
    }
    
    func popolateMapView(_ viewController: HomeViewController) {
        guard let events = self.events else {
            print("Eventi non ancora caricati!")
            return
        }
        viewController.mapView.removeAnnotations(viewController.mapView.annotations)
        for event in events {
            if event.latitude != 0 || event.longitude != 0 {
                let coordinates = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
                let mapItem = EventMapAnnotation(coordinate: coordinates, title: event.title, date: event.date, eventId: event.id)
                viewController.mapView.addAnnotation(mapItem)
            }
        }
    }
    
    
    func getEvents(_ viewController: HomeViewController) {
        if mustUpdate {
            eventService.getEvents() {
                events in
                self.allEvents = events
                //self.popolateMapView(viewController)
                //viewController.tableView.reloadData()
                NotificationCenter.default.post(name: Notification.Name("eventsModified"), object: nil)
            }
        }
    }
    
    func convertCoordinates(_ cell: EventTableViewCell, _ latitude: Double, _ longitude: Double){
        convertCoordinatesToAddress(latitude: latitude, longitude: longitude) {
            address in
            cell.address.text = address
        }
    }
    
    func numberOfRows(_: HomeViewController) -> Int {
        guard let events = events else { return 0 }
        return events.count
    }
    
    func dataForCell(index: Int) -> Event? {
        guard let event = self.events?[index] else { return nil }
        return event
        
    }
    
    func selectedRow(_ viewController: HomeViewController, index: Int) {
        print("rowSelected \(index)")
        guard let event = events?[index] else {
            print("evento non valido")
            return
        }
        PresenterManager.mainPresenter?.presentInfoEvent(viewController, event: event, nil)
    }
    
    func presentEventInfo(_ viewController: HomeViewController, _ eventId: Int) {
        let events = events?.filter{ $0.id == eventId }
        guard let event = events?[0] else {
            print("nessun evento trovato")
            return
        }
        PresenterManager.mainPresenter?.presentInfoEvent(viewController, event: event, nil)
    }
    
    func switchToMapView(_ viewController: HomeViewController, _ sender: UISegmentedControl) {
        viewController.searchHereButton.alpha = 0
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5) {
                viewController.mapSection.isHidden = true
                viewController.tableView.isHidden = false
                viewController.view.layoutIfNeeded()
            }
        }else if sender.selectedSegmentIndex == 1 {
            
            UIView.animate(withDuration: 0.5) {
                viewController.mapSection.isHidden = false
                viewController.tableView.isHidden = true
                viewController.view.layoutIfNeeded()
            }
        }
    }
    
    func deleteLocalEvent(_ eventId: Int) {
        guard let ev = events else {
            return
        }
        self.events = ev.filter{ $0.id != eventId }
    }
}


