//
//  PlaceView.swift
//  Places
//
//  Created by Adrian on 25.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class PlaceView: UITableViewCell {
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var photo: UIImageView!
  
  func setupWithData(_ place: Place) {
    setupName(place.name)
    setupAddress(place.address, distance: place.distance)
    setupPhoto(place.photo)
  }
  
  fileprivate func setupName(_ name: String) {
    self.name.text = name
  }
  
  fileprivate func setupAddress(_ address: String?, distance: Int) {
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
  
  fileprivate func setupPhoto(_ photo: UIImage) {
    self.photo.layer.cornerRadius = photo.size.width/2
    self.photo.clipsToBounds = true
    self.photo.image = photo
  }
}
