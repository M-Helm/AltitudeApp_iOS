//
//  AltitudeQueue.h
//  howhiami
//
//  Created by Matthew Helm on 4/19/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <foundation/Foundation.h>

@interface AltitudeQueue: NSMutableArray
//@property (nonatomic) NSMutableArray *altitudeQueue;
- (id) dequeue;
- (void) enqueue:(id)obj;
@end