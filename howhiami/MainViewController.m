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

UIView *altView;
UIView *factView;
UILabel *altLabel;
UILabel *factLabel;


- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    dbManager = [[DBManager alloc] init];
    
    self.locationManager.delegate  = self;
    self.locationManager.distanceFilter = 10.0f;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if(IS_OS_8_OR_LATER) {
        [_locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    firstUnitLabel = @"meters";
    secondUnitLabel = @"feet";
    

    
    //[self.factLabel sizeToFit];


    //[dbManager dropTable:@"facts"];
    [dbManager getInitFacts];
    //[dbManager getFact:2100];
    //[dbManager checkFactTableExists];
    //[dbManager getFactTableRowsCount];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    float xCo = self.view.bounds.size.width;
    //float yCo = self.view.bounds.size.height;
    
    altView = [[UIView alloc] initWithFrame:CGRectMake(10, 125, xCo-20, 115)];
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
    
    factView = [[UIView alloc] initWithFrame:CGRectMake(10, 250, xCo-20, 150)];
    factView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    factView.layer.borderWidth = 3;
    factView.layer.cornerRadius = 15;
    //factView.layer.masksToBounds = YES;

    factLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, xCo-30, 75)];
    factLabel.lineBreakMode = NSLineBreakByCharWrapping;
    factLabel.textAlignment =  NSTextAlignmentLeft;
    factLabel.text = @"Hi!";
    //factLabel.backgroundColor = [UIColor lightGrayColor];
    factLabel.numberOfLines = 6;
    //[factLabel sizeToFit];
    
    [factView addSubview:factLabel];
    [self.view addSubview:factView];
    [self updateLabels];
    
}

- (void)updateLabels{
    altLabel.text = [self deviceAltitude];
    NSString *fact = [dbManager getFact:(int)_locationManager.location.altitude];
    //NSString *fact = [dbManager getFact:2100];
    NSString *text = [NSString stringWithFormat:@"That's %i %@... %@",(int)(_locationManager.location.altitude * 3.28084), secondUnitLabel, fact];

    factLabel.text = text;
    //factLabel.numberOfLines = 0;
    //[self.factLabel sizeToFit];
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
// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
    [self updateLabels];
}

@end
