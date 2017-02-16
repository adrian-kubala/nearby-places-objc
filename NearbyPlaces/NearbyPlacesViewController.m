//
//  PlacesViewController.m
//  NearbyPlaces
//
//  Created by Adrian Kubała on 16.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import "NearbyPlacesViewController.h"
#import "Place.h"
#import "PlaceView.h"
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

// MARK: - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  if (userLocation.location) {
    [self.mapView setupMapRegion:userLocation.location];
    [self setupGeocoderWithLocation:userLocation.location];
    [self showNearbyPlaces];
  }
}

- (void) showNearbyPlaces {
  [self.placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList * _Nullable likelihoodList, NSError * _Nullable error) {
    if (error) {
      NSLog(@"Nearby places error: %@", error.localizedDescription);
      return;
    }
    
    [self.nearbyPlaces removeAllObjects];
    for (GMSPlaceLikelihood *likelihood in likelihoodList.likelihoods) {
      Place *nearbyPlace = (Place *) likelihood.place;
      //      TO-DO
      //      self.checkForPlacePhotos(nearbyPlace, location: self.userLocation)
    }
  }];
  
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
    NSString *identifier = @"placePin";
    MKAnnotationView * pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (pinView) {
      pinView.annotation = annotation;
    } else {
      pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
      
      [pinView setImage:[UIImage imageNamed:@"map-location"]];
    }
    
    return pinView;
  } else {
    return nil;
  }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  CLLocationCoordinate2D center = mapView.centerCoordinate;
  GMSCoordinateBounds *bounds; //let bounds = setupMapBounds(center, span: 0.0002)
  BOOL userIsInsideBounds = [bounds containsCoordinate:self.userLocation];
  
  if (userIsInsideBounds) {
    [self.mapView hideAnnotationIfNeeded];
    [self.centerLocationButton setHidden:YES];
    [self.searchBar setupCurrentLocationIcon];
  } else {
    [self.mapView showAnnotation];
    [self.mapView setupMapRegionWithCoordinate:center];
    [self.searchBar setupSearchIcon];
    [self.centerLocationButton setHidden:NO];
    
    CLLocation *annotationLocation = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    [self setupGeocoderWithLocation:annotationLocation];
  }
}

- (void) setupGeocoderWithLocation:(CLLocation *)location {
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
    CLPlacemark *placemark = [placemarks firstObject];
    if (placemark) {
      [self.searchBar updateSearchTextWith:placemark];
      self.placemark = placemark;
    }
  }];
}

//@IBAction func centerMapView(_ sender: AnyObject) {
//  guard let userLocation = locationManager.location else {
//    return
//  }
//  
//  mapView.setupMapRegion(userLocation)
//  centerLocationButton.isHidden = true
//}

// MARK: - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.searchBar.isActive) {
    return self.typedPlaces.count;
  } else {
    return self.nearbyPlaces.count;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  PlaceView *cell = (PlaceView *) [tableView dequeueReusableCellWithIdentifier:@"placeView"];
  
  NSUInteger row = indexPath.row;
  Place *place = [self chooseDataForRow:row];
  [cell setupWithPlace:place];
  
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Place *place = [self chooseDataForRow:indexPath.row];
  NSString *address = place.address;
  CLLocationCoordinate2D coordinate = place.coordinate;
  
  [self.mapView setupMapRegionWithCoordinate:coordinate];
  self.currentAddress = [address mutableCopy];
  [self clearSearchBarText];
//  [self resizeTable];
}

- (Place *)chooseDataForRow:(NSUInteger)row {
  if ([self.searchBar isActive]) {
    return self.typedPlaces[row];
  }
  return self.nearbyPlaces[row];
}

- (void)clearSearchBarText {
  self.searchBar.text = @"";
//  _ = searchBarShouldEndEditing(searchBar)
  [self.searchBar updateSearchText:self.currentAddress];
}


@end
