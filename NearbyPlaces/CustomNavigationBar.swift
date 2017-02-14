//
//  CustomNavigationBar.swift
//  Places
//
//  Created by Adrian on 29.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {
  override func draw(_ rect: CGRect) {
    drawNavigationBar()
  }
  
  func drawNavigationBar() {
    let customView = CustomView(view: self)
    customView.drawByBezierPath(withOffset: 5.0, color: barTintColor!)
  }
}
