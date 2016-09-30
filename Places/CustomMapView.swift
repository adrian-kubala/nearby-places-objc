//
//  CustomMapView.swift
//  Places
//
//  Created by Adrian on 29.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import MapKit

class CustomMapView: MKMapView {
  let pinView = UIImageView(image: UIImage(named: "map-location"))
  
  override func drawRect(rect: CGRect) {
    setupAnnotation()
  }
  
  func setupMapRegion(location: CLLocation) {
    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    setupRegion(center)
  }
  
  func setupMapRegionWithCoordinate(coordinate: CLLocationCoordinate2D) {
    setupRegion(coordinate)
  }
  
  private func setupRegion(center: CLLocationCoordinate2D) {
    let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
    let region = MKCoordinateRegion(center: center, span: span)
    
    setRegion(region, animated: true)
  }
  
  private func setupAnnotation() {
    addSubview(pinView)
    centerPin()
  }
  
  private func centerPin() {
    pinView.center = convertPoint(center, fromView: superview)
  }
  
  func hideAnnotationIfNeeded() {
    pinView.hidden = true
  }
  
  func showAnnotation() {
    pinView.hidden = false
  }
}
