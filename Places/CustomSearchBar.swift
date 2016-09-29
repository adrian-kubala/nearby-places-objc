//
//  CustomSearchBar.swift
//  Places
//
//  Created by Adrian on 29.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import CoreLocation

class CustomSearchBar: UISearchBar {
  
  override func drawRect(rect: CGRect) {
    drawSearchBar()
    
    setupImages()
    setupClearButton()
  }
  
  func drawSearchBar() {
    let customView = CustomView(view: self)
    customView.drawViewByBezierPath(5.0, with: tintColor)
  }
  
  func setupImages() {
    var image = UIImage(named: "loc-clear")
    setImage(image, forSearchBarIcon: .Clear, state: .Normal)
    
    image = UIImage(named: "loc-current")
    setImage(image, forSearchBarIcon: .Search, state: .Normal)
  }
  
  func setupClearButton() {
    let textField = valueForKey("searchField") as? UITextField
    textField?.clearButtonMode = UITextFieldViewMode.WhileEditing
  }
  
  func changeSearchIcon() {
    var image = UIImage()
    if isActive() {
      image = UIImage(named: "loc-search")!
      setImage(image, forSearchBarIcon: .Search, state: .Normal)
    } else {
      image = UIImage(named: "loc-current")!
      setImage(image, forSearchBarIcon: .Search, state: .Normal)
    }
  }
  
  func updateSearchText(with placemark: CLPlacemark) {
    if let street = placemark.thoroughfare, city = placemark.locality, country = placemark.country {
      let separator = ", "
      let formattedAddress = street + separator + city + separator + country
      text = formattedAddress
    }
  }
  
  func isActive() -> Bool {
    return isFirstResponder() ? true : false
  }
}
