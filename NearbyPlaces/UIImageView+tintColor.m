//
//  UIImageView+tintColor.m
//  NearbyPlaces
//
//  Created by Adrian Kubała on 13.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import "UIImageView+tintColor.h"

@implementation UIImageView (tintColor)

-(void)changeTintColor:(UIColor *)color {
  self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.tintColor = color;
}

@end
