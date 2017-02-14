//
//  Place.m
//  NearbyPlaces
//
//  Created by Adrian Kubała on 14.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import "Place.h"

@implementation Place

-(instancetype)initWithName:(NSString *)name
                    address:(NSString *)address
                 coordinate:(CLLocationCoordinate2D)coordinate
                      photo:(UIImage *)photo
               userLocation:(CLLocationCoordinate2D)userLocation {
  self = [super init];
  
  if (self) {
    _name = name;
    _address = address;
    _coordinate = coordinate;
    _photo = photo;
    _distance = [self getDistanceFrom:coordinate to:userLocation];
  }
  
  return self;
}

-(NSInteger)getDistanceFrom:(CLLocationCoordinate2D)place to:(CLLocationCoordinate2D)otherPlace {
  CLLocation *firstLocation = [[CLLocation alloc] initWithLatitude:place.latitude longitude:place.longitude];
  CLLocation *secondLocation = [[CLLocation alloc] initWithLatitude:otherPlace.latitude longitude:otherPlace.longitude];
  
  int distanceInMeters = [secondLocation distanceFromLocation:firstLocation];
  return distanceInMeters;
}

@end
