//
//  CustomButton.m
//  NearbyPlaces
//
//  Created by Adrian Kubała on 15.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import "CustomButton.h"
#import "CustomView.h"
#import "UIImageView+TintColor.h"

@implementation CustomButton

- (void)drawRect:(CGRect)rect {
  [self drawButton];
  [self setupImageView];
}

- (void)drawButton {
  CustomView *customView = [[CustomView alloc] initWithView:self];
  [customView drawViewByBezierPathWithOffset:5.0 color:[UIColor blackColor]];
}

- (void)setupImageView {
  UIImageView *imgView = [[UIImageView alloc] init];
  imgView.image = [UIImage imageNamed:@"tick"];
  [imgView changeTintColor:[UIColor whiteColor]];
  [self setImage:imgView.image forState:UIControlStateNormal];
}

@end
