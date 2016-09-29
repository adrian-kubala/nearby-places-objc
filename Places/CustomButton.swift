//
//  CustomButton.swift
//  Places
//
//  Created by Adrian on 28.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
  override func drawRect(rect: CGRect) {
    drawButton()
    setupImageView()
//    changeImagePosition()
  }
  
  func drawButton() {
    let customView = CustomView(view: self)
    customView.drawViewByBezierPath(5.0)
  }
  
  func setupImageView() {
    let imgView = UIImageView()
    imgView.image = UIImage(named: "tick")
    imgView.changeTintColor(UIColor.whiteColor())
    setImage(imgView.image, forState: .Normal)
  }
  
//  func changeImagePosition() {
//    transform = CGAffineTransformMakeScale(-1, 1)
//    titleLabel?.transform = CGAffineTransformMakeScale(-1, 1)
//    imageView?.transform = CGAffineTransformMakeScale(-1, 1)
//  }
}
