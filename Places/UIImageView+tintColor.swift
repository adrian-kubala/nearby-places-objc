//
//  UIImageView+tintColor.swift
//  Places
//
//  Created by Adrian on 28.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

extension UIImageView {
  func changeTintColor(color: UIColor) {
    image = image?.imageWithRenderingMode(.AlwaysTemplate)
    tintColor = color
  }
}