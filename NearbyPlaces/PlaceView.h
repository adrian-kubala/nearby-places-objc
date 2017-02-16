//
//  PlaceView.h
//  NearbyPlaces
//
//  Created by Adrian Kubała on 14.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Place;

@interface PlaceView : UITableViewCell

@property (weak, nonatomic, null_unspecified) IBOutlet UILabel *name;
@property (weak, nonatomic, null_unspecified) IBOutlet UILabel *address;
@property (weak, nonatomic, null_unspecified) IBOutlet UIImageView *photo;

- (void)setupWithPlace:(nonnull Place *)place;

@end
