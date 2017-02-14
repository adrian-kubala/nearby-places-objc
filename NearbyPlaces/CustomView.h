//
//  CustomView.h
//  NearbyPlaces
//
//  Created by Adrian Kubała on 14.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface CustomView : NSObject

- (instancetype)initWithView:(UIView *)view;
- (void)drawViewByBezierPathWithOffset:(CGFloat)leftBottomCornerOffset color:(UIColor *)color;

@end
NS_ASSUME_NONNULL_END
