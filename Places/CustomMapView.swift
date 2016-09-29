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
  func setupMapRegion(location: CLLocation) {
    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
    let region = MKCoordinateRegion(center: center, span: span)
    
    setRegion(region, animated: true)
  }
  
  func setupAnnotationWithCoordinate(coordinate: CLLocationCoordinate2D) {
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    addAnnotation(annotation)
  }
  
  func removeAnnotationsIfNeeded() {
    if annotations.count > 0 {
      removeAnnotations(annotations)
    }
  }
}
