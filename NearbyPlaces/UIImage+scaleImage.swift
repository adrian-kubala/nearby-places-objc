//
//  UIImage+scaleImage.swift
//  Places
//
//  Created by Adrian on 29.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

extension UIImage {
  func scaleImage(width: Double) -> UIImage {
    let newWidth = CGFloat(width)
    let scale = newWidth / size.width
    let newHeight = size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
}
