//
//  PlacesViewController.h
//  NearbyPlaces
//
//  Created by Adrian Kubała on 16.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

@class CustomSearchBar;
@class CustomMapView;

@interface NearbyPlacesViewController : UIViewController

@property (weak, nonatomic, null_unspecified) IBOutlet CustomSearchBar *searchbar;
@property (weak, nonatomic, null_unspecified) IBOutlet CustomMapView *mapView;
@property (weak, nonatomic, null_unspecified) IBOutlet UITableView *tableView;
@property (weak, nonatomic, null_unspecified) IBOutlet UIView *labelView;
@property (weak, nonatomic, null_unspecified) IBOutlet NSLayoutConstraint *placesViewHeight;
@property (weak, nonatomic, null_unspecified) IBOutlet UIButton *centerLocationButton;

@property (nonatomic, nonnull) CLLocationManager *locationManager;
@property (nonatomic, nonnull) GMSPlacesClient *placesClient;
@property (nonatomic, nonnull) NSMutableArray *nearbyPlaces;
@property (nonatomic, nonnull) NSMutableArray *typedPlaces;

@property (readonly, nonatomic) CLLocationCoordinate2D userLocation;

@property (nonatomic, nullable) CLPlacemark *placemark;
@property (nonatomic, nonnull) NSMutableString *currentAddress;

@end
