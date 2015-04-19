//
//  ApplicationGlobals.m
//  howhiami
//
//  Created by Matthew Helm on 4/18/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "ApplicationGlobals.h"

@implementation ApplicationGlobals


#pragma mark singleton 

+ (id)sharedAppGlobals {
    static ApplicationGlobals *sharedApplicationGlobals = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedApplicationGlobals = [[self alloc] init];
    });
    return sharedApplicationGlobals;
}

- (id)init {
    if (self = [super init]) {
        //self.altitudeArray = [[NSMutableArray alloc] init];
        //someProperty = [[NSString alloc] initWithString:@"Default Property Value"];
    }
    return self;
}

- (void)dealloc {
    //nada y pue nada
}

@end