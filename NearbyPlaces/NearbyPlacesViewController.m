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
#import "UIImage+Resizing.h"

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
      GMSPlace *nearbyPlace = likelihood.place;
      [self checkForPlacePhotos:nearbyPlace location:self.userLocation];
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
  GMSCoordinateBounds *bounds = [self setupMapBoundsForLocation:center withSpan:0.0002];
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
  [self resizeTable];
}

- (Place *)chooseDataForRow:(NSUInteger)row {
  if ([self.searchBar isActive]) {
    return self.typedPlaces[row];
  }
  return self.nearbyPlaces[row];
}

- (void)clearSearchBarText {
  self.searchBar.text = @"";
  [self searchBarShouldEndEditing:self.searchBar];
  [self.searchBar updateSearchText:self.currentAddress];
}

// MARK: - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  [self.requestTimer invalidate];
  self.requestTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(makeRequestForPlaces) userInfo:nil repeats:false];
}

- (void)makeRequestForPlaces {
  NSString *searchText = self.searchBar.text;
  if (![searchText length]) {
    [self searchBarShouldEndEditing:self.searchBar];
    return;
  }
  
  NSLog(@"%@", searchText);
  
  GMSCoordinateBounds *bounds = [self setupMapBoundsForLocation:self.userLocation withSpan:0.01];
  [self.placesClient autocompleteQuery:searchText bounds:bounds filter:nil callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
    if (error) {
      NSLog(@"Autocomplete error: %@", error.localizedDescription);
      return;
    }
    
    [self.typedPlaces removeAllObjects];
    for (GMSAutocompletePrediction *prediction in results) {
      NSString *placeID = prediction.placeID;
      if (placeID) {
        [self setupPlaceByID:placeID location:self.userLocation];
      }
    }
  }];
}

- (GMSCoordinateBounds *)setupMapBoundsForLocation:(CLLocationCoordinate2D)location withSpan:(double)span {
  CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(location.latitude + span, location.longitude + span);
  CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(location.latitude - span, location.longitude - span);
  return [[GMSCoordinateBounds alloc] initWithCoordinate:northEast coordinate:southWest];
}

- (void)setupPlaceByID:(NSString *)placeID location:(CLLocationCoordinate2D)location {
  [self.placesClient lookUpPlaceID:placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
    if (result) {
      [self checkForPlacePhotos:result location:location];
    }
  }];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  [self.searchBar changeSearchIcon];
    [self resizeTable];
  self.searchBar.text = @"";
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
  if ([self.searchBar isActive]) {
    [searchBar resignFirstResponder];
    return true;
  } else {
    return false;
  }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
  [self.searchBar changeSearchIcon];
  [self resizeTable];
  [self.searchBar updateSearchText:self.currentAddress];
  [self.typedPlaces removeAllObjects];
}

- (void)checkForPlacePhotos:(GMSPlace *)place location:(CLLocationCoordinate2D)location {
  [self.placesClient lookUpPhotosForPlaceID:place.placeID callback:^(GMSPlacePhotoMetadataList * _Nullable photos, NSError * _Nullable error) {
    if (error) {
      NSLog(@"%@", error.localizedDescription);
      return;
    }
    
    [self setupPlaceWithPhoto:place photo:photos.results.firstObject location:location];
  }];
}

- (void)setupPlaceWithPhoto:(GMSPlace *)place photo:(nullable GMSPlacePhotoMetadata *)photo location:(CLLocationCoordinate2D)location {
  if (photo) {
    Place *place = [[Place alloc] initWithName:place.name address:place.address coordinate:place.coordinate photo:[UIImage imageNamed:@"av-location"] userLocation:location];
    [self updatePlacesWithPlace:place];
    return;
  }
  
  [self.placesClient loadPlacePhoto:photo callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
    if (error) {
      NSLog(@"%@", error.localizedDescription);
      return;
    }
    
    Place *place = [[Place alloc] initWithName:place.name address:place.address coordinate:place.coordinate photo:[[UIImage alloc] init] userLocation:location];
    
    UIImage *croppedImage = [photo cropToWidth:40 height:40];
    UIImage *scaledImage = [croppedImage scaleImage:40];
    place.photo = scaledImage;
    
    [self updatePlacesWithPlace:place];
  }];
}

- (void)updatePlacesWithPlace:(Place *)place {
  if ([self.searchBar isActive]) {
    [self.typedPlaces addObject:place];
  } else {
    [self.nearbyPlaces addObject:place];
  }
  
  [self  sortPlacesByDistance];
  [self.placesView reloadData];
}

- (void)sortPlacesByDistance {
  if ([self.searchBar isActive]) {
    [self.typedPlaces sortUsingComparator:^NSComparisonResult(Place * _Nonnull obj1, Place * _Nonnull obj2) {
      return obj1.distance < obj2.distance;
    }];
  } else {
    [self.nearbyPlaces sortUsingComparator:^NSComparisonResult(Place * _Nonnull obj1, Place * _Nonnull obj2) {
      return obj1.distance < obj2.distance;
    }];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
    [self resizeTable];
}

- (void)resizeTable {
  CGFloat frameHeight = CGRectGetMaxY(self.view.frame);
  if ([self.searchBar isActive]) {
    self.placesViewHeight.constant = frameHeight - CGRectGetMaxY(self.searchBar.frame);
  } else {
    self.placesViewHeight.constant = frameHeight - CGRectGetMaxY(self.labelView.frame);
  }
  
  [self.placesView reloadData];
  [self animateTableResizing];
}

- (void)animateTableResizing {
  [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAutoreverse animations:^{
    [self.placesView layoutIfNeeded];
  } completion:nil];
}




//@IBAction func sendImageFromMapView(_ sender: AnyObject) {
//  performSegue(withIdentifier: "showChatVC", sender: nil)
//}

//override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//  guard let destinationVC = segue.destination as? ChatViewController, segue.identifier == "showChatVC" else {
//    return
//  }
//
//  guard let mapViewImage = getImageFromView(mapView) else {
//    return
//  }
//
//  destinationVC.image = mapViewImage
//}
//
//func getImageFromView(_ view: UIView) -> UIImage? {
//  UIGraphicsBeginImageContext(view.bounds.size)
//  guard let context = UIGraphicsGetCurrentContext() else {
//    return nil
//  }
//
//  view.layer.render(in: context)
//  let image = UIGraphicsGetImageFromCurrentImageContext()
//  UIGraphicsEndImageContext()
//  return image
//}

@end
