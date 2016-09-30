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
  @IBOutlet weak var searchBar: CustomSearchBar!
  @IBOutlet weak var mapView: CustomMapView!
  @IBOutlet weak var placesView: UITableView!
  @IBOutlet weak var labelView: UIView!
  @IBOutlet weak var placesViewHeight: NSLayoutConstraint!
  
  var locationManager = CLLocationManager()
  var placesClient = GMSPlacesClient()
  var nearbyPlaces: [Place] = []
  var typedPlaces: [Place] = []
  
  var userLocation: CLLocationCoordinate2D {
    guard let location = locationManager.location?.coordinate else {
      print("Retrieving location error")
      return CLLocationCoordinate2D()
    }
    return location
  }
  var placemark: CLPlacemark?
  
  private var requestTimer = NSTimer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationItem()
    setupMapView()
    setupLocationManager()
    setupPlacesClient()
    setupTableView()
    setupSearchBar()
  }
  
  func setupNavigationItem() {
    let navigationItem = self.navigationItem as! CustomNavigationitem
    navigationItem.setupIcon("map-location")
  }
  
  func setupMapView() {
    mapView.delegate = self
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
    guard let location = userLocation.location else {
      return
    }
    
    self.mapView.setupMapRegion(location)
    setupGeocoder(location)
    showNearbyPlaces()
  }
  
  func setupGeocoder(location: CLLocation) {
    let geocoder = CLGeocoder()
    let completionHandler: CLGeocodeCompletionHandler = { (placemarks, error) -> Void in
      if let placemark = placemarks?.first {
        self.searchBar.updateSearchText(with: placemark)
        self.placemark = placemark
      }
    }
    geocoder.reverseGeocodeLocation(location, completionHandler: completionHandler)
  }
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKPointAnnotation {
      let identifier = "placePin"
      var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
      if pinView == nil {
        pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        pinView?.image = UIImage(named: "map-location")
      } else {
        pinView?.annotation = annotation
      }
      return pinView
    }
    
    return nil
  }
  
  func setupTableView() {
    placesView.delegate = self
    placesView.dataSource = self
  }
  
  // MARK: - UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchBar.isActive() {
      return typedPlaces.count
    }
    return nearbyPlaces.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCellWithIdentifier("placeView") as? PlaceView else {
      return UITableViewCell()
    }
    
    let row = indexPath.row
    let data = chooseData(row)
    cell.setupWithData(data)
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let coordinate = chooseData(indexPath.row).coordinate
    
    mapView.removeAnnotationsIfNeeded()
    mapView.setupAnnotationWithCoordinate(coordinate)
    updateMapRegion()
    clearSearchBarText()
    resizeTable()
  }
  
  func updateMapRegion() {
    if searchBar.isActive() {
      fitRegionToAnnotations()
    } else {
      mapView.setupMapRegion(locationManager.location!)
    }
  }
  
  func fitRegionToAnnotations() {
    if mapView.annotations.isEmpty == false {
      mapView.showAnnotations(mapView.annotations, animated: true)
    }
  }
  
  func clearSearchBarText() {
    searchBar.text?.removeAll()
    searchBarShouldEndEditing(searchBar)
  }
  
  @IBAction func centerMapView(sender: AnyObject) {
    guard let userLocation = locationManager.location else {
      return
    }
    
    mapView.setupMapRegion(userLocation)
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
    searchBar.setupSearchBar()
    searchBar.delegate = self
  }
  
  // MARK: - UISearchBarDelegate
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    requestTimer.invalidate()
    requestTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(PlacesViewController.makeRequestForPlaces), userInfo: nil, repeats: false)
  }
  
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    self.searchBar.changeSearchIcon()
    resizeTable()
    searchBar.text?.removeAll()
  }
  
  func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
    if self.searchBar.isActive() {
      searchBar.resignFirstResponder()
      return true
    }
    return false
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    self.searchBar.changeSearchIcon()
    resizeTable()
    self.searchBar.updateSearchText(with: placemark!)
    typedPlaces.removeAll()
  }
  
  func makeRequestForPlaces() {
    guard let searchText = searchBar.text where searchText.isEmpty == false else {
      searchBarShouldEndEditing(searchBar)
      return
    }
    
    print(searchText)
    
    let bounds = setupQueryBounds(userLocation)
    placesClient.autocompleteQuery(searchText, bounds: bounds, filter: nil, callback: { (predictions, error) -> Void in
      guard let predictions = predictions where error == nil else {
        print("Autocomplete error: \(error!.localizedDescription)")
        return
      }
      
      self.typedPlaces = []
      for prediction in predictions {
        guard let placeID = prediction.placeID else {
          continue
        }
        
        self.setupPlaceByID(placeID, location: self.userLocation)
      }
    })
  }
  
  func setupPlaceByID(placeID: String, location: CLLocationCoordinate2D) {
    placesClient.lookUpPlaceID(placeID, callback: {(place, error) -> Void in
      if let predictedPlace = place {
        self.checkForPlacePhotos(predictedPlace, location: location)
      }
    })
  }
  
  func setupQueryBounds(location: CLLocationCoordinate2D) -> GMSCoordinateBounds {
    let northEast = CLLocationCoordinate2DMake(location.latitude + 0.001, location.longitude + 0.001)
    let southWest = CLLocationCoordinate2DMake(location.latitude - 0.001, location.longitude - 0.001)
    return GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
  }
  
  func setupAutocompleteFilter() -> GMSAutocompleteFilter {
    let filter = GMSAutocompleteFilter()
    filter.country = "PL"
    return filter
  }
  
  func showNearbyPlaces() {
    placesClient.currentPlaceWithCallback({ (placeLikelihoods, error) -> Void in
      guard let placeLikelihoods = placeLikelihoods where error == nil else {
        print("Nearby places error: \(error!.localizedDescription)")
        return
      }
      
      self.nearbyPlaces = []
      for likelihood in placeLikelihoods.likelihoods {
        let nearbyPlace = likelihood.place
        self.checkForPlacePhotos(nearbyPlace, location: self.userLocation)
      }
    })
  }
  
  func checkForPlacePhotos(place: GMSPlace, location: CLLocationCoordinate2D) {
    placesClient.lookUpPhotosForPlaceID(place.placeID, callback: { (photos, error) -> Void in
      guard error == nil else {
        print(error!.localizedDescription)
        return
      }
      
      self.setupPlaceWithPhoto(place, photo: photos?.results.first, location: location)
    })
  }
  
  func setupPlaceWithPhoto(place: GMSPlace, photo: GMSPlacePhotoMetadata?, location: CLLocationCoordinate2D) {
    guard let photo = photo else {
      let place = Place(name: place.name, address: place.formattedAddress, coordinate: place.coordinate, photo: UIImage(named: "av-location")!, userLocation: location)
      self.updatePlaces(with: place)
      
      return
    }
    
    placesClient.loadPlacePhoto(photo, callback: {(placePhoto, error) -> Void in
      guard error == nil else {
        print(error!.localizedDescription)
        return
      }
      
      let place = Place(name: place.name, address: place.formattedAddress, coordinate: place.coordinate, photo: UIImage(), userLocation: location)
      
      let croppedImage = placePhoto?.cropToBounds(width: 40, height: 40)
      let scaledImage = croppedImage!.scaleImage(width: 40)
      place.photo = scaledImage
      
      self.updatePlaces(with: place)
    })
  }
  
  func updatePlaces(with place: Place) {
    if searchBar.isActive() {
      typedPlaces.append(place)
    } else {
      nearbyPlaces.append(place)
    }
    sortPlacesByDistance()
    placesView.reloadData()
  }
  
  func sortPlacesByDistance() {
    if searchBar.isActive() {
      typedPlaces.sortInPlace({
        $0.distance < $1.distance
      })
    } else {
      nearbyPlaces.sortInPlace({
        $0.distance < $1.distance
      })
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    resizeTable()
  }
  
  func resizeTable() {
    let frameHeight = view.frame.maxY
    if searchBar.isActive() {
      placesViewHeight.constant = frameHeight - searchBar.frame.maxY
    } else {
      placesViewHeight.constant = frameHeight - labelView.frame.maxY
    }
    placesView.reloadData()
    animateTableResizing()
  }
  
  func animateTableResizing() {
    UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
      self.placesView.layoutIfNeeded()
      }, completion: nil)
  }
  
  func chooseData(row: Int) -> Place {
    if searchBar.isActive() {
      return typedPlaces[row]
    }
    return nearbyPlaces[row]
  }
}
