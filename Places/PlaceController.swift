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

class PlaceController: UIViewController {
    var locationManager = CLLocationManager()
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var placesView: UITableView!
    
    @IBOutlet weak var searchView: UIView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var places: [Place] = []
    
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
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        setupSearchBar()
    }
    
    func setupSearchBar() {
        let searchBar = searchController.searchBar
//        view.addSubview(searchBar)
        autoComplete = searchBar
        searchBar.autocapitalizationType = .None
        searchBar.placeholder = "Current location"
        searchBar.delegate = self
    }
    
    func setupTableView() {
        placesView.delegate = self
        placesView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        showNearbyPlaces()
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
}

extension PlaceController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        guard let location = userLocation else {
            return
        }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
        
        let point = MKPointAnnotation()
        
        point.coordinate = location.coordinate
        point.title = "Current location"
        
        mapView.addAnnotation(point)
        
        locationManager.stopUpdatingLocation()
    }
}

extension PlaceController: UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

extension PlaceController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("place", forIndexPath: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = places[row].name
        cell.detailTextLabel?.text = String(places[row].distance) + " m" + " | " + places[row].address
        
        return cell
    }
    
    func sortPlacesByDistance() {
        places = places.sort {
            $0.distance < $1.distance
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected")
    }
}

extension PlaceController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let location = locationManager.location?.coordinate else {
            return
        }
        
        let placesClient = GMSPlacesClient()
        
        let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        //        let config = GMSPlacePickerConfig(viewport: viewport)
        
        placesClient.autocompleteQuery("A", bounds: viewport, filter: nil) { (prediction, error) in
            print(prediction)
        }
    }
}
