//
//  AltitudeQueue.m
//  howhiami
//
//  Created by Matthew Helm on 4/19/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "AltitudeQueue.h"

@implementation AltitudeQueue

- (id) dequeue {
    if ([self count] < 1) return nil;
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

- (void) enqueue:(id)anObject {
    [self addObject:anObject];
    if([self count] > 20){
        [self dequeue];
    }
}
@end