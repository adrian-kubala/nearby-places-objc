//
//  CustomView.m
//  NearbyPlaces
//
//  Created by Adrian Kubała on 14.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import "CustomView.h"

@interface CustomView ()

@property (nonnull, nonatomic) UIView *view;

@end

@implementation CustomView

-(instancetype)initWithView:(UIView *)view {
  self = [super init];
  
  if (self) {
    _view = view;
  }
  
  return self;
}

-(void)drawViewByBezierPathWithOffset:(CGFloat)leftBottomCornerOffset color:(UIColor *)color {
  UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
  [bezierPath moveToPoint:self.view.bounds.origin];
  
  CGFloat maxX = CGRectGetMaxX(self.view.bounds);
  CGFloat maxY = CGRectGetMaxY(self.view.bounds);
  CGPoint origin = self.view.bounds.origin;
  
  [bezierPath addLineToPoint:CGPointMake(maxX, origin.y)];
  [bezierPath addLineToPoint:CGPointMake(maxX, maxY)];
  [bezierPath addLineToPoint:CGPointMake(origin.x, maxY - leftBottomCornerOffset)];
  [bezierPath closePath];
  
  [color setFill];
  [bezierPath fill];
  
  [color setStroke];
  [bezierPath stroke];
}

@end
