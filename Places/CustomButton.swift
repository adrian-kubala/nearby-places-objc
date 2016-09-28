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
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func drawRect(rect: CGRect) {
    let bezierPath = UIBezierPath()
    bezierPath.moveToPoint(bounds.origin)
    bezierPath.addLineToPoint(CGPoint(x: bounds.maxX, y: bounds.origin.y))
    bezierPath.addLineToPoint(CGPoint(x:bounds.maxX, y: bounds.maxY))
    bezierPath.addLineToPoint(CGPoint(x: bounds.origin.x, y: bounds.maxY - CGFloat(5)))
    bezierPath.closePath()
    
    let color = UIColor.blackColor()
    color.setStroke()
    
    bezierPath.stroke()
    bezierPath.fill()
  }
}
