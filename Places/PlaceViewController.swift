//
//  ViewController.swift
//  Places
//
//  Created by Adrian on 15.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import GooglePlacePicker
import MapKit

class PlaceViewController: UIViewController {
    var locationManager = CLLocationManager()
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var placesView: UITableView!
    
    @IBOutlet weak var searchView: UIView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var places: [Place] = []
    var filteredPlaces: [Place] = []
    
//    @IBAction func pickPlace(sender: AnyObject) {
//        let place = Place()
//        
//        let center = CLLocationCoordinate2DMake(place.latitude, place.longitude)
//        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
//        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
//        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
//        let config = GMSPlacePickerConfig(viewport: viewport)
//        let placePicker = GMSPlacePicker(config: config)
//        
//        placePicker.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
//            if let error = error {
//                print("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//            
//            if let place = place {
//                print("Place name \(place.name)")
//                print("Place address \(place.formattedAddress)")
//                print("Place attributions \(place.attributions)")
//            } else {
//                print("No place selected")
//            }
//        })
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupTableView()
        setupSearchController()
        showNearbyPlaces()
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        setupSearchBar()
    }
    
    func setupSearchBar() {
        let searchBar = searchController.searchBar
        searchBar.autocapitalizationType = .None
        searchBar.placeholder = "Current location"
        searchBar.delegate = self
        searchView.addSubview(searchBar)
    }
    
    func setupTableView() {
        placesView.delegate = self
        placesView.dataSource = self
    }
    
    func setupMapView() {
        guard let userCoordinate = locationManager.location?.coordinate else {
            return
        }
        
        let mapCamera = MKMapCamera(lookingAtCenterCoordinate: userCoordinate, fromEyeCoordinate: userCoordinate, eyeAltitude: 400.0)
        let annotation = MKPointAnnotation()
        annotation.coordinate = userCoordinate
        
        //Setup our Map View
        mapView.mapType = MKMapType.Standard
        mapView.addAnnotation(annotation)
        mapView.setCamera(mapCamera, animated: true)
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
                self.sortPlacesByDistance()
                self.placesView.reloadData()
            }
        })
    }
    
    func sortPlacesByDistance() {
        places.sortInPlace({
            $0.distance < $1.distance
        })
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredPlaces = places.filter { place in
            if searchText.isEmpty == false {
                return place.name.lowercaseString.containsString(searchText.lowercaseString)
            }
            return false
        }
        placesView.reloadData()
    }
    
    func chooseData(row: Int) -> Place {
        if searchIsActive(){
            return filteredPlaces[row]
        }
        return places[row]
    }
    
    func searchIsActive() -> Bool {
        return searchController.active && searchController.searchBar.text != "" ? true : false
    }
}

extension PlaceViewController: CLLocationManagerDelegate {
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

extension PlaceViewController: UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

extension PlaceViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIsActive() {
            return filteredPlaces.count
        }
        return places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("place", forIndexPath: indexPath)
        
        let row = indexPath.row
        let data = chooseData(row)
        
        cell.textLabel?.text = data.name
        cell.detailTextLabel?.text = String(data.distance) + " m" + " | " + data.address
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected")
    }
}

extension PlaceViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        let placesClient = GMSPlacesClient()
        
        let center = locationManager.location?.coordinate
        let northEast = CLLocationCoordinate2DMake(center!.latitude + 0.001, center!.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center!.latitude - 0.001, center!.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
//        let config = GMSPlacePickerConfig(viewport: viewport)
//        let placePicker = GMSPlacePicker(config: config)
        placesClient.autocompleteQuery(searchText, bounds: viewport, filter: nil, callback: { (predictions, error) in
            guard let predictions = predictions else {
                return
            }
            
            for prediction in predictions {
                print(prediction.attributedPrimaryText)
            }
            
        })
        filterContentForSearchText(searchText)
    }
}
