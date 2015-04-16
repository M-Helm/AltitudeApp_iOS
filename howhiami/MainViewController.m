//
//  MainViewController.m
//  howhiami
//
//  Created by Matthew Helm on 4/5/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "MainViewController.h"
#import "DBManager.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface MainViewController ()

@end

@implementation MainViewController

NSString *firstUnitLabel;
NSString *secondUnitLabel;
DBManager *dbManager;
CLLocation *currentLoc;
CLLocationDirection *currentHeading;

UIView *altView;
UIView *factView;
UIView *barometerView;
UIView *compassView;
UIView *acclView;
UIView *utilView;

UILabel *altLabel;
UILabel *factLabel;
UILabel *barometerLabel;
UILabel *compassLabel;
UILabel *acclLabel;
UILabel *utilLabel;


NSString *fact;


- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    dbManager = [[DBManager alloc] init];
    currentLoc = [[CLLocation alloc] init];
    
    self.locationManager.delegate  = self;
    self.locationManager.distanceFilter = 10.0f;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    if(IS_OS_8_OR_LATER) {
        [_locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        _locationManager.headingFilter = 5;
        [_locationManager startUpdatingHeading];
    }
    
    firstUnitLabel = @"meters";
    secondUnitLabel = @"feet";

    //[dbManager dropTable:@"facts"];
    [dbManager getInitFacts];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    float xCo = self.view.bounds.size.width;
    //float yCo = self.view.bounds.size.height;
    
    altView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, xCo-20, 115)];
    altView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    altView.layer.borderWidth = 3;
    altView.layer.cornerRadius = 15;
    
    altLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, xCo-30, 100)];
    altLabel.layer.masksToBounds = YES;
    //altLabel.backgroundColor = [UIColor lightGrayColor];
    altLabel.textAlignment = NSTextAlignmentCenter;
    altLabel.font = [UIFont systemFontOfSize:35];
    
    [altView addSubview:altLabel];
    [self.view addSubview:altView];
    
    factView = [[UIView alloc] initWithFrame:CGRectMake(10, 225, xCo-120, 140)];
    factView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    factView.layer.borderWidth = 3;
    factView.layer.cornerRadius = 15;
    factView.layer.masksToBounds = YES;

    factLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, xCo-130, 75)];
    factLabel.lineBreakMode = NSLineBreakByWordWrapping;
    factLabel.textAlignment =  NSTextAlignmentLeft;
    factLabel.numberOfLines = 6;
    
    [factView addSubview:factLabel];
    [self.view addSubview:factView];
    
    barometerView = [[UIView alloc] initWithFrame:CGRectMake(xCo-100, 225, 90, 90)];
    barometerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    barometerView.layer.borderWidth = 3;
    barometerView.layer.cornerRadius = 15;
    barometerView.layer.masksToBounds = YES;
    
    barometerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 80)];
    //barometerLabel.backgroundColor = [UIColor lightGrayColor];
    barometerLabel.textAlignment = NSTextAlignmentCenter;
    barometerLabel.font = [UIFont systemFontOfSize:25];
    barometerLabel.text = @"NA";
    
    UILabel *barometerTitle = [[UILabel alloc] initWithFrame:CGRectMake(2,2,76,15)];
    barometerTitle.textAlignment = NSTextAlignmentCenter;
    barometerTitle.font = [UIFont systemFontOfSize:11];
    barometerTitle.text = @"Pressure";
    
    [barometerLabel addSubview:barometerTitle];
    [barometerView addSubview:barometerLabel];
    [self.view addSubview:barometerView];
    
    compassView = [[UIView alloc] initWithFrame:CGRectMake(xCo-100, 325, 90, 90)];
    compassView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    compassView.layer.borderWidth = 3;
    compassView.layer.cornerRadius = 15;
    compassView.layer.masksToBounds = YES;
    
    compassLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 80)];
    //compassLabel.backgroundColor = [UIColor lightGrayColor];
    compassLabel.textAlignment = NSTextAlignmentCenter;
    compassLabel.font = [UIFont systemFontOfSize:25];
    
    UILabel *compassTitle = [[UILabel alloc] initWithFrame:CGRectMake(2,2,76,15)];
    compassTitle.textAlignment = NSTextAlignmentCenter;
    compassTitle.font = [UIFont systemFontOfSize:11];
    compassTitle.text = @"Heading";
    
    [compassLabel addSubview:compassTitle];
    
    [compassView addSubview:compassLabel];
    
    [self.view addSubview:compassView];
    
    acclView = [[UIView alloc] initWithFrame:CGRectMake(xCo-100, 425, 90, 90)];
    acclView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    acclView.layer.borderWidth = 3;
    acclView.layer.cornerRadius = 15;
    acclView.layer.masksToBounds = YES;
    
    acclLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 80)];
    //acclLabel.backgroundColor = [UIColor lightGrayColor];
    acclLabel.textAlignment = NSTextAlignmentCenter;
    acclLabel.font = [UIFont systemFontOfSize:25];
    acclLabel.text = @"NA";
    
    
    UILabel *acclTitle = [[UILabel alloc] initWithFrame:CGRectMake(2,2,76,15)];
    acclTitle.textAlignment = NSTextAlignmentCenter;
    acclTitle.font = [UIFont systemFontOfSize:11];
    acclTitle.text = @"Accelerometer";
    
    [acclLabel addSubview:acclTitle];
    
    [acclView addSubview:acclLabel];
    
    
    [self.view addSubview:acclView];
    
    utilView = [[UIView alloc] initWithFrame:CGRectMake(10, 375, xCo-120, 140)];
    utilView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    utilView.layer.borderWidth = 3;
    utilView.layer.cornerRadius = 15;
    compassView.layer.masksToBounds = YES;
    [self.view addSubview:utilView];
    
    [self updateLabels:true];
    
}

- (void)updateLabels:(BOOL)changeFact{
    currentLoc = _locationManager.location;
    altLabel.text = [self deviceAltitude];
    if(changeFact)fact = [dbManager getFact:(int)currentLoc.altitude];
    NSString *factText = [NSString stringWithFormat:@"That's %i %@... %@",(int)(currentLoc.altitude * 3.28084), secondUnitLabel, fact];
    factLabel.text = factText;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)deviceAltitude {
    NSLog(@"alt: %f ts: %@", _locationManager.location.altitude, _locationManager.location.timestamp);
    return [NSString stringWithFormat:@"%i %@",
            (int)_locationManager.location.altitude, firstUnitLabel];
            //(int)(_locationManager.location.altitude * 3.28084), secondUnitLabel];
}
-(void)updateHeadingDisplays{
    NSString *accl = [NSString stringWithFormat:@"%i",(int)currentHeading];
    acclLabel.text = accl;
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@, count: %i", [locations lastObject], [locations count]);
    if([fact length] < 10){
        [self updateLabels:true];
        return;
    }
    if([locations count] > 1){
        int i = [locations count] - 1;
        CLLocation *lstLoc = locations[i];
        currentLoc = [locations lastObject];
        double d = lstLoc.altitude - currentLoc.altitude;
        if(d > 9)[self updateLabels:true];
        if(d < -9)[self updateLabels:true];
        [self updateLabels:false];
        return;
    }
    [self updateLabels:true];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);

    currentHeading = &theHeading;
    compassLabel.text = [NSString stringWithFormat:@"%i", (int)newHeading.magneticHeading];
    //[self updateHeadingDisplays];
}


@end
