//
//  UIImage+scaleImage.swift
//  Places
//
//  Created by Adrian on 29.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

extension UIImage {
  func scaleImage(width width: Double) -> UIImage {
    let newWidth = CGFloat(width)
    let scale = newWidth / size.width
    let newHeight = size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
}