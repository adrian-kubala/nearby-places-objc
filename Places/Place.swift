//
//  Place.swift
//  Places
//
//  Created by Adrian on 15.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import Foundation
import GooglePlaces

class Place {
    var name: String = ""
    var address: String = ""
    var distance: Int = 0
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
    
    init(gmsPlace: GMSPlace, userLocation: CLLocationCoordinate2D) {
        name = gmsPlace.name
        if let formattedAddress = gmsPlace.formattedAddress {
            address = formattedAddress
        }
        distance = getDistance(gmsPlace.coordinate, from: userLocation)
    }
    
    func getDistance(place: CLLocationCoordinate2D, from otherPlace: CLLocationCoordinate2D) -> Int {
        let firstLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let secondLocation = CLLocation(latitude: otherPlace.latitude, longitude: otherPlace.longitude)
        
        let distanceInMeters = firstLocation.distanceFromLocation(secondLocation)
        distance = Int(distanceInMeters)
        return distance
    }
}
