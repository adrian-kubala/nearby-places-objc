//
//  ViewController.swift
//  Places
//
//  Created by Adrian on 15.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

class PlacesViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nearbyPlacesLabel: UILabel!
    @IBOutlet weak var placesView: UITableView!
    @IBOutlet weak var placesViewHeight: NSLayoutConstraint!
    
    let locationManager = CLLocationManager()
    
    var places: [Place] = []
    var searchedPlaces: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        showNearbyPlaces()
    }
    
    func searchIsActive() -> Bool {
        return searchBar.text?.isEmpty == false ? true : false
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    func showNearbyPlaces() {
        let placesClient = GMSPlacesClient()
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error?.localizedDescription)")
                return
            }
            
            guard let placeLikelihoods = placeLikelihoods else {
                return
            }
            
            for likelihood in placeLikelihoods.likelihoods {
                let gmsPlace = likelihood.place
                
                guard let userLocation = self.locationManager.location?.coordinate else {
                    continue
                }
                
                let place = Place(gmsPlace: gmsPlace, userLocation: userLocation)
                self.places.append(place)
            }
        })
        sortPlacesByDistance()
        reloadTableinMainThreadAsync()
    }
    
    func sortPlacesByDistance() {
        places.sortInPlace({
            $0.distance < $1.distance
        })
    }
    
    func reloadTableinMainThreadAsync() {
        self.placesView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTableViewContraints()
    }
    
    func updateTableViewContraints() {
        let frameHeight = view.frame.maxY
        if searchIsActive() {
            placesViewHeight.constant = frameHeight - searchBar.frame.maxY
        } else {
            placesViewHeight.constant = frameHeight - nearbyPlacesLabel.frame.maxY
        }
    }
    
    func setupMapView() {
        guard let userCoordinate = locationManager.location?.coordinate else {
            return
        }
        
        let mapCamera = MKMapCamera(lookingAtCenterCoordinate: userCoordinate, fromEyeCoordinate: userCoordinate, eyeAltitude: 400.0)
        let annotation = MKPointAnnotation()
        annotation.coordinate = userCoordinate
        
        mapView.mapType = MKMapType.Standard
        mapView.addAnnotation(annotation)
        mapView.setCamera(mapCamera, animated: true)
    }
    
    func chooseData(row: Int) -> Place {
        if searchIsActive() {
            return searchedPlaces[row]
        }
        return places[row]
    }
    
    @IBAction func reloadTable(sender: AnyObject) {
        reloadTableinMainThreadAsync()
    }
    
}

extension PlacesViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        guard let userLocation = location else {
            return
        }
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
        
        setupMapView()
        
        let point = MKPointAnnotation()
        
        point.coordinate = userLocation.coordinate
        point.title = "Current location"
        
        mapView.addAnnotation(point)
        locationManager.stopUpdatingLocation()
    }
}

extension PlacesViewController: UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

extension PlacesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIsActive() {
            return searchedPlaces.count
        }
        return places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("placesView", forIndexPath: indexPath)
        
        let row = indexPath.row
        let data = chooseData(row)
        
        cell.textLabel?.text = data.name
        if data.distance > 0 {
            cell.detailTextLabel?.text = String(data.distance) + " m" + " | " + data.address
        } else {
            cell.detailTextLabel?.text = data.address
        }
        return cell
    }
}

extension PlacesViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let placesClient = GMSPlacesClient()
        let filter = GMSAutocompleteFilter()
        filter.country = "PL"
        let center = locationManager.location?.coordinate
        let northEast = CLLocationCoordinate2DMake(center!.latitude + 0.001, center!.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center!.latitude - 0.001, center!.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        //        let config = GMSPlacePickerConfig(viewport: viewport)
        //        let placePicker = GMSPlacePicker(config: config)
        placesClient.autocompleteQuery(searchText, bounds: viewport, filter: filter, callback: { (predictions, error) -> Void in
            guard let predictions = predictions else {
                return
            }
            
            var predicatedPlaces: [Place] = []
            for prediction in predictions {
                let placeName = prediction.attributedPrimaryText.string
                let placeSubname = prediction.attributedSecondaryText?.string
                if let subname = placeSubname {
                    predicatedPlaces.append(Place(name: placeName, address: subname))
                } else {
                    predicatedPlaces.append(Place(name: placeName, address: ""))
                }
            }
            
            self.searchedPlaces = predicatedPlaces
            self.updateTableViewContraints()
        })
    }
}
