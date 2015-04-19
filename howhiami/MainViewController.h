//
//  MainViewController.h
//  howhiami
//
//  Created by Matthew Helm on 4/5/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

double hithere;


@interface MainViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSString *firstUnitLabel;
@property (nonatomic) NSString *secondUnitLabel;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic) CLLocationDirection *currentHeading;

@end




