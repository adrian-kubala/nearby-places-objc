//
//  CustomButton.swift
//  Places
//
//  Created by Adrian on 28.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
  override func draw(_ rect: CGRect) {
    drawButton()
    setupImageView()
  }
  
  func drawButton() {
    let customView = CustomView(view: self)
    customView.drawByBezierPath(withOffset: 5.0, color: UIColor.black)
  }
  
  func setupImageView() {
    let imgView = UIImageView()
    imgView.image = UIImage(named: "tick")
    imgView.changeTintColor(UIColor.white)
    setImage(imgView.image, for: UIControlState())
  }
}
