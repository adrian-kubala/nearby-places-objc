//
//  UIImage+scaleImage.m
//  NearbyPlaces
//
//  Created by Adrian Kubała on 14.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import "UIImage+scaleImage.h"

@implementation UIImage (scaleImage)

- (instancetype)scaleImage:(double)width {
  CGFloat scale = width / self.size.width;
  CGFloat newHeight = self.size.height * scale;
  
  UIGraphicsBeginImageContext(CGSizeMake(width, newHeight));
  [self drawInRect:CGRectMake(0, 0, width, newHeight)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newImage;
}

@end
