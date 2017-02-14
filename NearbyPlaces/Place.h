//
//  Place.h
//  NearbyPlaces
//
//  Created by Adrian Kubała on 14.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Place : NSObject

@property (copy, nonnull, nonatomic) NSString *name;
@property (copy, nullable, nonatomic) NSString *address;
@property (nonatomic) NSInteger distance;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonnull, nonatomic) UIImage *photo;

@end
