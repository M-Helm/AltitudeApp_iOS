//
//  MainViewController.m
//  howhiami
//
//  Created by Matthew Helm on 4/5/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "MainViewController.h"
#import "DBManager.h"
#import "ApplicationGlobals.h"
#import "LineChart.h"
#import "NSArray+AltitudeQueue.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface MainViewController ()

@end

@implementation MainViewController

DBManager *dbManager;
ApplicationGlobals *appGlobals;
//NSMutableArray *altQueue;


UIView *altView;
UIView *barometerView;
UIView *compassView;
UIView *acclView;
UIView *factView;
UIView *utilView;
UILabel *altLabel;
UILabel *factLabel;
UILabel *barometerLabel;
UILabel *compassLabel;
UILabel *acclLabel;
UILabel *utilLabel;

NSString *fact;
UIActivityIndicatorView *altSpinner;
UIActivityIndicatorView *barometerSpinner;

- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    dbManager = [DBManager sharedDBManager];
    appGlobals = [ApplicationGlobals sharedAppGlobals];
    //altQueue = [[NSMutableArray alloc] init];
    self.currentLocation = [[CLLocation alloc] init];
    self.lastTimestamp = 0;
    
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
    
    self.firstUnitLabel = @"meters";
    self.secondUnitLabel = @"feet";
    [self initViews];

    //[dbManager dropTable:@"facts"];
    [dbManager getInitFacts];
    
    
    NSArray *array = [dbManager getAltitudeArray];
    for(int i = 0; i<array.count; i++){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"0" forKey:@"timestamp"];
        [dict setObject:[array objectAtIndex:i] forKey:@"altitude"];
        [appGlobals.altitudeArray enqueue:dict];
        //[appGlobals.altitudeArray enqueue:[array objectAtIndex:i]];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //float xCo = self.view.bounds.size.width;
    //float yCo = self.view.bounds.size.height;
    
    altView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    altView.layer.borderWidth = 3;
    altView.layer.cornerRadius = 15;
    

    altLabel.layer.masksToBounds = YES;
    //altLabel.backgroundColor = [UIColor lightGrayColor];
    altLabel.textAlignment = NSTextAlignmentCenter;
    altLabel.font = [UIFont systemFontOfSize:35];
    
    [altView addSubview:altLabel];
    [self.view addSubview:altView];
    
    factView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    factView.layer.borderWidth = 3;
    factView.layer.cornerRadius = 15;
    factView.layer.masksToBounds = YES;


    factLabel.lineBreakMode = NSLineBreakByWordWrapping;
    factLabel.textAlignment =  NSTextAlignmentLeft;
    factLabel.numberOfLines = 6;
    
    [factView addSubview:factLabel];
    [self.view addSubview:factView];
    
    barometerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    barometerView.layer.borderWidth = 3;
    barometerView.layer.cornerRadius = 15;
    barometerView.layer.masksToBounds = YES;
    barometerLabel.textAlignment = NSTextAlignmentCenter;
    barometerLabel.font = [UIFont systemFontOfSize:25];
    //barometerLabel.text = @"NA";
    UILabel *barometerTitle = [[UILabel alloc] initWithFrame:CGRectMake(2,2,76,15)];
    barometerTitle.textAlignment = NSTextAlignmentCenter;
    barometerTitle.font = [UIFont systemFontOfSize:11];
    barometerTitle.text = @"Pressure";
    [barometerLabel addSubview:barometerTitle];
    [barometerView addSubview:barometerLabel];
    [self.view addSubview:barometerView];
    
    compassView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    compassView.layer.borderWidth = 3;
    compassView.layer.cornerRadius = 15;
    compassView.layer.masksToBounds = YES;
    compassLabel.textAlignment = NSTextAlignmentCenter;
    compassLabel.font = [UIFont systemFontOfSize:25];
    
    UILabel *compassTitle = [[UILabel alloc] initWithFrame:CGRectMake(2,2,76,15)];
    compassTitle.textAlignment = NSTextAlignmentCenter;
    compassTitle.font = [UIFont systemFontOfSize:11];
    compassTitle.text = @"Heading";
    
    [compassLabel addSubview:compassTitle];
    [compassView addSubview:compassLabel];
    [self.view addSubview:compassView];

    acclView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    acclView.layer.borderWidth = 3;
    acclView.layer.cornerRadius = 15;
    acclView.layer.masksToBounds = YES;
    acclLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 80)];
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
    
    utilView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    utilView.layer.borderWidth = 3;
    utilView.layer.cornerRadius = 15;
    utilView.layer.masksToBounds = YES;
    [self.view addSubview:utilView];
    [self updateLabels:true];
    
}

- (void)updateLabels:(BOOL)changeFact{
    self.currentLocation = _locationManager.location;
    altLabel.text = [self deviceAltitude];
    if(changeFact){
        fact = [dbManager getFact:(int)self.currentLocation.altitude];
    }
    NSString *factText = [NSString stringWithFormat:@"That's %i %@... %@",(int)(self.currentLocation.altitude * 3.28084), self.secondUnitLabel, fact];
    factLabel.text = factText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)deviceAltitude {
    NSLog(@"alt: %f ts: %@", _locationManager.location.altitude, _locationManager.location.timestamp);
    return [NSString stringWithFormat:@"%i %@",
            (int)_locationManager.location.altitude, self.firstUnitLabel];
            //(int)(_locationManager.location.altitude * 3.28084), secondUnitLabel];
}
-(void)updateHeadingDisplays{
    NSString *accl = [NSString stringWithFormat:@"%i",(int)self.currentHeading];
    acclLabel.text = accl;
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //NSLog(@"locations array count: %i",(int)[locations count]);
    //Make sure a fact is showing
    if([fact length] < 10){
        [self updateLabels:true];
        return;
    }
    //make sure this isn't the first location update and then that it's a significant update
    if([locations count] > 1){
        int i = (int)[locations count] - 1;
        CLLocation *lstLoc = locations[i];
        self.currentLocation = [locations lastObject];
        double d = lstLoc.altitude - self.currentLocation.altitude;
        if(d < 0){
            d = d * -1;
        }
        if(d > 9){
            [self addAltitudePoint];
            [self updateGraph];
            [self updateLabels:true];
            return;
        }
        [self updateLabels:false];
        return;
    }
    [self addAltitudePoint];
    [self updateGraph];
    [self updateLabels:true];
    [self updateBarometer];
}
- (void)addAltitudePoint{
    NSNumber *altitude = [NSNumber numberWithInt:(int)self.currentLocation.altitude];
    //NSNumber *altitude = [NSNumber numberWithInt:50];
    NSLog(@"alt: %@", altitude);
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStamp = [NSNumber numberWithInt:(int)timeInterval];
    if((int)timeStamp - _lastTimestamp > 150){
        _lastTimestamp = (int)timeStamp;
        NSLog(@"time: %@", timeStamp);
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:timeStamp forKey:@"timestamp"];
        [dict setObject:altitude forKey:@"altitude"];
        [appGlobals.altitudeArray enqueue:dict];
        [dbManager saveAltitude:dict];
    }
}

- (void)updateGraph{
    NSLog(@"update Graph called");
    [self.chart1 clearChartData];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i = 0; i<appGlobals.altitudeArray.count; i++){
        //NSDictionary *dict =
    }
    //[self.chart1 setChartData:appGlobals.altitudeArray];
    [utilView addSubview:[self chart1]];
    [self.view addSubview:utilView];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0){
        return;
    }
    // Use the true heading if it is valid.
    CLLocationDirection theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    self.currentHeading = &theHeading;
    compassLabel.text = [NSString stringWithFormat:@"%i", (int)newHeading.magneticHeading];
    if(!altSpinner.hidden){
        [altSpinner stopAnimating];
        altSpinner.hidden = true;
        [altSpinner removeFromSuperview];
    }
    //[self updateHeadingDisplays];
}

-(LineChart*)chart1 {
    //NSMutableArray *chartData = altQueue;
    NSMutableArray *chartData = [[NSMutableArray alloc] init];
    //[appGlobals.altitudeArray removeAllObjects];
    for(int i=0;i<appGlobals.altitudeArray.count;i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict = appGlobals.altitudeArray[i];
        NSNumber *altitude = [dict valueForKey:@"altitude"];
        NSLog(@"ChartData Item: %@", altitude);
        [chartData addObject:altitude];
        //[appGlobals.altitudeArray addObject:altitude];
    }
    
    /*
    for(int i=0;i<10;i++) {
        int r = (rand() + rand()) % 100;
        chartData[i] = [NSNumber numberWithInt:1600 + r];
    }
    */
    
    LineChart* lineChart = [[LineChart alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 120, 140)];
    lineChart.verticalGridStep = 5;
    lineChart.horizontalGridStep = 9;
    NSLog(@"sig 1");
    lineChart.labelForIndex = ^(NSUInteger item) {
        return [NSString stringWithFormat:@"%lu",(unsigned long)item];
    };
    NSLog(@"sig 2");
    lineChart.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.f", value];
    };
    NSLog(@"sig 3");
    [lineChart setChartData:chartData];
    //[lineChart setChartData:appGlobals.altitudeArray];
    NSLog(@"sig 4");
    return lineChart;
}

-(void)initViews{
    float xCo = self.view.bounds.size.width;
    factLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, xCo-130, 75)];
    altView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, xCo-20, 115)];
    altLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, xCo-30, 100)];
    factView = [[UIView alloc] initWithFrame:CGRectMake(10, 225, xCo-120, 140)];
    barometerView = [[UIView alloc] initWithFrame:CGRectMake(xCo-100, 225, 90, 90)];
    barometerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 80)];
    compassView = [[UIView alloc] initWithFrame:CGRectMake(xCo-100, 325, 90, 90)];
    compassLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 80)];
    acclView = [[UIView alloc] initWithFrame:CGRectMake(xCo-100, 425, 90, 90)];
    utilView = [[UIView alloc] initWithFrame:CGRectMake(10, 375, xCo-120, 140)];
    altSpinner = [[UIActivityIndicatorView alloc]
                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    altSpinner.center = CGPointMake(40, 40);
    altSpinner.hidesWhenStopped = YES;
    barometerSpinner = [[UIActivityIndicatorView alloc]
                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    barometerSpinner.center = CGPointMake(40,40);
    barometerSpinner.hidesWhenStopped = YES;
    [compassLabel addSubview:altSpinner];
    [barometerLabel addSubview:barometerSpinner];
    [altSpinner startAnimating];
    [barometerSpinner startAnimating];
    
}
-(void)updateBarometer{
    CMAltimeter *altimeter = [[CMAltimeter alloc] init];
    if(!barometerSpinner.hidden){
        [barometerSpinner stopAnimating];
        barometerSpinner.hidden = true;
        [barometerSpinner removeFromSuperview];
    }
    if (CMAltimeter.isRelativeAltitudeAvailable) {
        barometerLabel.text = @"AVA";
        return;
    }
    barometerLabel.text = @"NA";
}


@end


