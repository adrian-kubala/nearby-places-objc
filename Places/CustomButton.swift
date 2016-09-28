//
//  CustomButton.swift
//  Places
//
//  Created by Adrian on 28.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
  @IBInspectable var leftBottomCornerOffset: CGFloat = 0.0
  
  override func drawRect(rect: CGRect) {
    drawButtonByBezierPath()
    setupImage()
    changeImagePosition()
  }
  
  func drawButtonByBezierPath() {
    let bezierPath = UIBezierPath()
    bezierPath.moveToPoint(bounds.origin)
    bezierPath.addLineToPoint(CGPoint(x: bounds.maxX, y: bounds.origin.y))
    bezierPath.addLineToPoint(CGPoint(x:bounds.maxX, y: bounds.maxY - leftBottomCornerOffset))
    bezierPath.addLineToPoint(CGPoint(x: bounds.origin.x, y: bounds.maxY))
    bezierPath.closePath()
    
    bezierPath.fill()
  }
  
  func setupImage() {
    let img = UIImageView()
    img.image = UIImage(named: "tick")
    img.changeTintColor(UIColor.whiteColor())
    setImage(img.image, forState: .Normal)
  }
  
  func changeImagePosition() {
    transform = CGAffineTransformMakeScale(-1, 1)
    titleLabel?.transform = CGAffineTransformMakeScale(-1, 1)
    imageView?.transform = CGAffineTransformMakeScale(-1, 1)
  }
}
