//
//  ChooseLocationViewController.swift
//  EventSharing
//
//  Created by certimeter on 18/04/23.
//

import UIKit
import MapKit

protocol ChooseLocationViewControllerDelegate: AnyObject {
    func savePlacemark(_ placemark: MKPlacemark)
}

class ChooseLocationViewController: UIViewController {
    
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTable: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var tableConstraint: NSLayoutConstraint!
    @IBOutlet weak var chooseConstraint: NSLayoutConstraint!
    var bySearching: Bool = false
    
    weak var delegate: ChooseLocationViewControllerDelegate?
    var chooseLocationButton: UIButton? = nil
    let searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var placemark: MKPlacemark? 
    var locationManager = CLLocationManager() 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.setImage(UIImage(systemName: "location.magnifyingglass"), for: UISearchBar.Icon.search, state: UIControl.State.normal)
        searchBar.delegate = self
        //searchBar.setValue("Choose", forKey: "cancelButtonText")
        searchBar.setShowsCancelButton(false, animated: false)
        searchResultsTable.dataSource = self
        searchResultsTable.delegate = self
        searchCompleter.delegate = self
        chooseButton.layer.cornerRadius = 18
        mapView.showsUserLocation = true
        if placemark != nil {
            mapView.setCenter(placemark?.coordinate ?? CLLocationCoordinate2D(), animated: true)
            guard let place = placemark else { return }
            guard let title = place.title else { return }
            mapView.addAnnotation(SimpleMapAnnotation(coordinate: place.coordinate, title: title))
        } else {
            mapView.setCenter(locationManager.location?.coordinate ?? CLLocationCoordinate2D(), animated: true)
            if let userLocation = mapView.userLocation.location {
                let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
                let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
        }
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        longTapGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longTapGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboardAndTable))
        mapView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func closeKeyboardAndTable() {
        UIView.animate(withDuration: 0.5) {
            self.tableConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
        view.endEditing(true)
    }

    @objc func addAnnotation(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            bySearching = false
            view.endEditing(true)
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            let point = gesture.location(in: mapView)
            let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
            print("coordinates\(coordinates)")
            PresenterManager.eventPresenter?.convertCoordinatesToPlacemark(latitude: coordinates.latitude, longitude: coordinates.longitude, completion: { address in
                guard let place = address else { return }
                self.placemark = MKPlacemark(placemark: place)
                guard let placemark = self.placemark else { return }
                self.mapView.addAnnotation(placemark)
                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
            })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
       
        let fromCoordinateSpace = UIScreen.main.coordinateSpace
        let toCoordinateSpace: UICoordinateSpace = view
        let convertedKeyboardFrame = fromCoordinateSpace.convert(keyboardFrame, from: toCoordinateSpace)
        let keyboardHeight = convertedKeyboardFrame.size.height
        let bottomOffset = view.safeAreaInsets.bottom
        chooseConstraint.constant = keyboardHeight - bottomOffset + 10
        UIView.animate(withDuration: 0.3) {
           self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        chooseConstraint.constant = 15
    }
    
    @IBAction func chooseAction(_ sender: Any) {
        guard let placemark = self.placemark else {
            print("impossibile salvare dati della posizione")
            return
        }
        if bySearching {
            chooseLocationButton?.setTitle(placemark.name, for: .normal)
        } else {
            chooseLocationButton?.setTitle("\(placemark.locality ?? "")  \(placemark.country ?? "")", for: .normal)
        }
        delegate?.savePlacemark(placemark)
        chooseLocationButton?.setImage(UIImage(systemName: "location.fill"), for: .normal)
        self.dismiss(animated: true)
    }
}

extension ChooseLocationViewController: UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        UIView.animate(withDuration: 0.5) {
            self.tableConstraint.isActive = false
            self.view.layoutIfNeeded()          
        }
        searchCompleter.queryFragment = searchText
    }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = searchCompleter.results
        searchResultsTable.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Errore nell'autocompletatmento: \(error.localizedDescription)")
    }
    
}

extension ChooseLocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        
        return cell
    }
}

extension ChooseLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bySearching = true
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        search.start {
            (response, error) in
            
            guard let title = response?.mapItems[0].placemark.title else {
                return
            }
            
            guard let placemark = response?.mapItems[0].placemark else {
                return
            }
            
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            
            self.placemark = placemark
            self.mapView.addAnnotation(placemark)
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            self.searchBar.text = "\(title)"
            UIView.animate(withDuration: 0.5) {
                self.tableConstraint.isActive = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
