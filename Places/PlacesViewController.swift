//
//  PlacesViewController.swift
//
//  Created by Adrian on 23.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

class PlacesViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MKMapViewDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placesView: UITableView!
    @IBOutlet weak var nearbyPlacesLabel: UILabel!
    @IBOutlet weak var placesViewHeight: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    var placesClient = GMSPlacesClient()
    var nearbyPlaces: [Place] = []
    var typedPlaces: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupPlacesClient()
        setupLocationManager()
        setupTableView()
        setupSearchBar()
    }
    
    func setupPlacesClient() {
        placesClient = GMSPlacesClient.sharedClient()
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
// MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Denied, .NotDetermined, .Restricted:
            print("Authorization error")
        default:
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print(error)
    }
    
// MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        setupMapRegion(userLocation)
        showNearbyPlaces()
        if let location = userLocation.location {
            setupGeocoder(location)
        }
    }
    
    func setupMapRegion(location: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    func setupGeocoder(location: CLLocation) {
        let geocoder = CLGeocoder()
        let completionHandler: CLGeocodeCompletionHandler = { (placemarks, error) -> Void in
            if let placemark = placemarks?.first {
                self.updateSearchBarPlaceholder(placemark)
            }
        }
        geocoder.reverseGeocodeLocation(location, completionHandler: completionHandler)
    }
    
    func updateSearchBarPlaceholder(placemark: CLPlacemark) {
        if let street = placemark.thoroughfare, city = placemark.locality, country = placemark.country {
            let separator = ", "
            let formattedAddress = street + separator + city + separator + country
            searchBar.placeholder = formattedAddress
        }
    }
    
    func setupTableView() {
        placesView.delegate = self
        placesView.dataSource = self
    }
    
// MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIsActive() {
            return typedPlaces.count
        }
        return nearbyPlaces.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("place") as? PlaceView else {
            return UITableViewCell()
        }
        
        let row = indexPath.row
        let data = chooseData(row)
        
        cell.name.text = data.name
        if data.distance > 0 {
            cell.address.text = String(data.distance) + " m" + " | " + data.address
        } else {
            cell.detailTextLabel?.text = data.address
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let coordinate = chooseData(indexPath.row).coordinate else {
            return
        }
        
        removeAnnotationsIfNeeded()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func removeAnnotationsIfNeeded() {
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    @IBAction func sendImageFromMapView(sender: AnyObject) {
        performSegueWithIdentifier("showChatVC", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let destinationVC = segue.destinationViewController as? ChatViewController where segue.identifier == "showChatVC" else {
            return
        }
        
        guard let mapViewImage = getImageFromView(mapView) else {
            return
        }
        
        destinationVC.image = mapViewImage
    }
    
    func getImageFromView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContext(view.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        view.layer.renderInContext(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setupSearchBar() {
        searchBar.autocapitalizationType = .None
        searchBar.placeholder = "Current location"
        searchBar.delegate = self
    }
    
// MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(PlacesViewController.makeRequestForPlaces), userInfo: nil, repeats: true)
        resizeTable()
    }
    
    func makeRequestForPlaces() {
        guard let searchText = searchBar.text else {
            return
        }
        
        let filter = GMSAutocompleteFilter()
        filter.country = "PL"
        guard let center = locationManager.location?.coordinate else {
            return
        }
        
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        placesClient.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: { (predictions, error) -> Void in
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
            
            self.typedPlaces = predicatedPlaces
        })
    }
    
    func showNearbyPlaces() {
        placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error?.localizedDescription)")
                return
            }
            
            guard let placeLikelihoods = placeLikelihoods else {
                return
            }
            
            self.nearbyPlaces = []
            for likelihood in placeLikelihoods.likelihoods {
                let gmsPlace = likelihood.place
                
                guard let userLocation = self.locationManager.location?.coordinate else {
                    continue
                }
                
                let place = Place(gmsPlace: gmsPlace, userLocation: userLocation)
                
                self.nearbyPlaces.append(place)
                self.sortPlacesByDistance()
                self.placesView.reloadData()
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        resizeTable()
    }
    
    func resizeTable() {
        let frameHeight = view.frame.maxY
        if searchIsActive() {
            placesViewHeight.constant = frameHeight - searchBar.frame.maxY
        } else {
            placesViewHeight.constant = frameHeight - nearbyPlacesLabel.frame.maxY
        }
        placesView.reloadData()
        animateTableResizing()
    }
    
    func animateTableResizing() {
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.placesView.layoutIfNeeded()
            }, completion: nil)
    }
    
    func sortPlacesByDistance() {
        nearbyPlaces.sortInPlace({
            $0.distance < $1.distance
        })
    }
    
    func chooseData(row: Int) -> Place {
        if searchIsActive() {
            return typedPlaces[row]
        }
        return nearbyPlaces[row]
    }
    
    func searchIsActive() -> Bool {
        return searchBar.text?.isEmpty == false ? true : false
    }
}
