//
//  CustomView.swift
//  Places
//
//  Created by Adrian on 28.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

@IBDesignable
class CustomView {
  private let view: UIView
  
  init(view: UIView) {
    self.view = view
  }
  
  func drawViewByBezierPath(leftBottomCornerOffset: CGFloat) {
    let bezierPath = UIBezierPath()
    bezierPath.moveToPoint(view.bounds.origin)
    bezierPath.addLineToPoint(CGPoint(x: view.bounds.maxX, y: view.bounds.origin.y))
    bezierPath.addLineToPoint(CGPoint(x: view.bounds.maxX, y: view.bounds.maxY))
    bezierPath.addLineToPoint(CGPoint(x: view.bounds.origin.x, y: view.bounds.maxY - leftBottomCornerOffset))
    bezierPath.closePath()
    
    bezierPath.fill()
  }
}
