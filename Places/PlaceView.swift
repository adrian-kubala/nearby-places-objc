//
//  PlaceView.swift
//  Places
//
//  Created by Adrian on 25.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import GooglePlaces

class PlaceView: UITableViewCell {
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var photo: UIImageView!
  
  func setupWithData(place: Place) {
    setupName(place.name)
    setupAddress(place.address, distance: place.distance)
    setupPhoto(place.photo)
  }
  
  private func setupName(name: String) {
    self.name.text = name
  }
  
  private func setupAddress(address: String?, distance: Int) {
    guard let address = address else {
      return
    }
    
    if distance < 1000 {
      self.address.text = String(distance) + " m" + " | " + address
    } else {
      let distanceInKM = Double(distance) / 1000
      self.address.text = String(format: "%.2f", distanceInKM) + " km" + " | " + address
    }
  }
  
  private func setupPhoto(photo: UIImage) {
    self.photo.layer.cornerRadius = photo.size.width/2
    self.photo.clipsToBounds = true
    self.photo.image = photo
  }
}
