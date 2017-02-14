//
//  PlaceView.m
//  NearbyPlaces
//
//  Created by Adrian Kubała on 14.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import "PlaceView.h"

@implementation PlaceView

- (void)setupWithPlace:(Place *)place {
  [self setupName:place.name];
  [self setupAddress:place.address distance:place.distance];
  [self setupPhoto:place.photo];
}

- (void)setupName:(NSString *)name {
  self.name.text = name;
}

- (void)setupAddress:(nullable NSString *)address distance:(NSInteger)distance {
  if (!address) {
    return;
  }
  
  if (distance < 1000) {
    self.address.text = [[NSString alloc] initWithFormat:@"%ld m | %@", distance, address];
  } else {
    double distanceInKm = distance / 1000;
    self.address.text = [[NSString alloc] initWithFormat:@"%.2f km | %@",distanceInKm, address];
  }
}

- (void)setupPhoto:(nonnull UIImage *)photo {
  self.photo.layer.cornerRadius = photo.size.width / 2;
  self.photo.clipsToBounds = true;
  self.photo.image = photo;
}

@end
