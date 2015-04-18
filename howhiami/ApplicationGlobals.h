//
//  ApplicationGlobals.h
//  howhiami
//
//  Created by Matthew Helm on 4/18/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <foundation/Foundation.h>

@interface ApplicationGlobals : NSObject

@property (nonatomic, retain) NSMutableArray *altitudeArray;

+ (id)sharedAppGlobals;

@end