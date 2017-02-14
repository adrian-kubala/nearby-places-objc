//
//  UIImage+cropToBounds.m
//  NearbyPlaces
//
//  Created by Adrian Kubała on 14.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import "UIImage+cropToBounds.h"

@implementation UIImage (cropToBounds)

- (instancetype)cropToWidth:(double)width height:(double)height {
  UIImage *contextImage = [[UIImage alloc] initWithCGImage:self.CGImage];
  CGSize contextSize = contextImage.size;
  
  CGFloat posX = 0.0;
  CGFloat posY = 0.0;
  CGFloat cgWidth = width;
  CGFloat cgHeight = height;
  
  if (contextSize.width > contextSize.height) {
    posX = (contextSize.width - contextSize.height) / 2;
    posY = 0;
    cgWidth = contextSize.height;
    cgHeight = contextSize.height;
  } else {
    posX = 0;
    posY = (contextSize.height - contextSize.width) / 2;
    cgWidth = contextSize.width;
    cgHeight = contextSize.width;
  }
  
  CGRect rect = CGRectMake(posX, posY, cgWidth, cgHeight);
  CGImageRef imageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect);
  
  UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
  return newImage;
}

@end
