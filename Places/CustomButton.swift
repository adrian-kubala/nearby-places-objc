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
  }
  
  func drawButtonByBezierPath() {
    let bezierPath = UIBezierPath()
    bezierPath.moveToPoint(bounds.origin)
    bezierPath.addLineToPoint(CGPoint(x: bounds.maxX, y: bounds.origin.y))
    bezierPath.addLineToPoint(CGPoint(x:bounds.maxX, y: bounds.maxY))
    bezierPath.addLineToPoint(CGPoint(x: bounds.origin.x, y: bounds.maxY - leftBottomCornerOffset))
    bezierPath.closePath()
    
    bezierPath.fill()
  }
}
