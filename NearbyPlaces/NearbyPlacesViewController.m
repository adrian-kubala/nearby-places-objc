//
//  PlacesViewController.m
//  NearbyPlaces
//
//  Created by Adrian Kubała on 16.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import "NearbyPlacesViewController.h"
#import "NearbyPlaces-Swift.h"

@interface NearbyPlacesViewController ()

@property (nonatomic) NSTimer *requestTimer;

@end

@implementation NearbyPlacesViewController

@synthesize userLocation = _userLocation;

- (CLLocationCoordinate2D)userLocation {
  CLLocationCoordinate2D coordinate = self.locationManager.location.coordinate;
  if (CLLocationCoordinate2DIsValid(coordinate)) {
    return coordinate;
  } else {
    NSLog(@"Retrieving location error");
    return kCLLocationCoordinate2DInvalid;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupProperties];
}

- (void)setupProperties {
  self.locationManager = [[CLLocationManager alloc] init];
  self.placesClient = [[GMSPlacesClient alloc] init];
  self.nearbyPlaces = [[NSMutableArray alloc] init];
  self.typedPlaces = [[NSMutableArray alloc] init];
  self.currentAddress = [[NSMutableString alloc] init];
  self.requestTimer = [[NSTimer alloc] init];
}

@end
