//
//  CustomNavigationitem.swift
//  Places
//
//  Created by Adrian on 29.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class CustomNavigationitem: UINavigationItem {
  func setupIcon(name: String) {
    var image = UIImage(named: name)
    image = image?.imageWithRenderingMode(.AlwaysOriginal)
    
    let locationImage = UIBarButtonItem(image: image, style: .Plain, target: nil, action: nil)
    let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    leftBarButtonItems = [flexibleSpace, locationImage]
  }
}
