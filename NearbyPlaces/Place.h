//
//  Place.h
//  NearbyPlaces
//
//  Created by Adrian Kubała on 14.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN
@interface Place : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nullable, nonatomic) NSString *address;
@property (nonatomic) NSInteger distance;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) UIImage *photo;

- (instancetype)initWithName:(NSString *)name
                     address:(nullable NSString *)address
                          coordinate:(CLLocationCoordinate2D)coordinate
                               photo:(UIImage *)photo
                        userLocation:(CLLocationCoordinate2D)userLocation;

- (NSInteger)getDistanceFrom:(CLLocationCoordinate2D)place to:(CLLocationCoordinate2D)otherPlace;

@end
NS_ASSUME_NONNULL_END
