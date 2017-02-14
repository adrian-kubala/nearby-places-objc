//
//  UIImage+Resizing.h
//  NearbyPlaces
//
//  Created by Adrian Kubała on 14.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resizing)

- (nonnull instancetype)cropToWidth:(double)width height:(double)height;
- (nonnull instancetype)scaleImage:(double)width;

@end
