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
  [self setupLocationManager];
  [self setupLocationManager];
  [self setupPlacesClient];
  [self setupNavigationItem];
  [self setupMapView];
  [self setupTableView];
  [self setupSearchBar];
}

- (void)setupProperties {
  self.nearbyPlaces = [[NSMutableArray<Place *> alloc] init];
  self.typedPlaces = [[NSMutableArray<Place *> alloc] init];
  self.currentAddress = [[NSMutableString alloc] init];
  self.requestTimer = [[NSTimer alloc] init];
  [self.centerLocationButton setHidden:YES];
}

- (void)setupLocationManager {
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  [self.locationManager requestWhenInUseAuthorization];
  [self.locationManager startUpdatingLocation];
}

- (void)setupPlacesClient {
  self.placesClient = [GMSPlacesClient sharedClient];
}

- (void)setupNavigationItem {
  CustomNavigationitem *navigationItem = (CustomNavigationitem *) self.navigationItem;
  [navigationItem setupIcon:@"map-location"];
}

- (void)setupMapView {
  self.mapView.delegate = self;
}

- (void)setupTableView {
  self.placesView.dataSource = self;
  self.placesView.delegate = self;
}

- (void)setupSearchBar {
  [self.searchBar setupSearchBar];
  self.searchBar.delegate = self;
}

// MARK: - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
  [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  switch (status) {
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusNotDetermined:
    case kCLAuthorizationStatusRestricted:
      NSLog(@"Authorization error");
      break;
      
    default:
      [self.locationManager startUpdatingLocation];
      break;
  }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  [self.locationManager startUpdatingLocation];
  NSLog(@"%@", error.localizedDescription);
}



@end
