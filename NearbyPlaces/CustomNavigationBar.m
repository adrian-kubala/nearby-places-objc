//
//  CustomNavigationBar.m
//  NearbyPlaces
//
//  Created by Adrian Kubała on 15.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import "CustomNavigationBar.h"
#import "CustomView.h"

@implementation CustomNavigationBar

- (void)drawRect:(CGRect)rect {
  [self drawNavigationBar];
}

- (void)drawNavigationBar {
  CustomView *customView = [[CustomView alloc] initWithView:self];
  [customView drawViewByBezierPathWithOffset:5.0 color:self.barTintColor];
}

@end
