//
//  PlacesViewController.h
//  NearbyPlaces
//
//  Created by Adrian Kubała on 16.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>
#import <MapKit/MapKit.h>

@class CustomSearchBar;
@class CustomMapView;
@class Place;

@interface NearbyPlacesViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic, null_unspecified) IBOutlet CustomSearchBar *searchBar;
@property (weak, nonatomic, null_unspecified) IBOutlet CustomMapView *mapView;
@property (weak, nonatomic, null_unspecified) IBOutlet UITableView *placesView;
@property (weak, nonatomic, null_unspecified) IBOutlet UIView *labelView;
@property (weak, nonatomic, null_unspecified) IBOutlet NSLayoutConstraint *placesViewHeight;
@property (weak, nonatomic, null_unspecified) IBOutlet UIButton *centerLocationButton;

@property (nonatomic, nonnull) CLLocationManager *locationManager;
@property (nonatomic, nonnull) GMSPlacesClient *placesClient;
@property (nonatomic, nonnull) NSMutableArray<Place *> *nearbyPlaces;
@property (nonatomic, nonnull) NSMutableArray<Place *> *typedPlaces;

@property (readonly, nonatomic) CLLocationCoordinate2D userLocation;

@property (nonatomic, nullable) CLPlacemark *placemark;
@property (nonatomic, nonnull) NSMutableString *currentAddress;

@end
