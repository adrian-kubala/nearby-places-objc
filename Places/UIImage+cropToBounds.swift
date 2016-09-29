//
//  UIImage+cropToBounds.swift
//  Places
//
//  Created by Adrian on 29.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
extension UIImage {
  func cropToBounds(width width: Double, height: Double) -> UIImage {
    let contextImage = UIImage(CGImage: CGImage!)
    let contextSize = contextImage.size
    
    var posX = CGFloat(0.0)
    var posY = CGFloat(0.0)
    var cgWidth = CGFloat(width)
    var cgHeight = CGFloat(height)
    
    if contextSize.width > contextSize.height {
      posX = ((contextSize.width - contextSize.height) / 2)
      posY = 0
      cgWidth = contextSize.height
      cgHeight = contextSize.height
    } else {
      posX = 0
      posY = ((contextSize.height - contextSize.width) / 2)
      cgWidth = contextSize.width
      cgHeight = contextSize.width
    }
    
    let rect = CGRectMake(posX, posY, cgWidth, cgHeight)
    
    // Create bitmap image from context using the rect
    let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let newImage = UIImage(CGImage: imageRef, scale: scale, orientation: imageOrientation)
    
    return newImage
  }
}
