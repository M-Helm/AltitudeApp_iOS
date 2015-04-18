//
//  DBManager.h
//  howhiami
//
//  Created by Matthew Helm on 4/11/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+ (DBManager*)getSharedDBManager;
- (NSArray*)getInitFacts;
- (BOOL) checkFactTableExists;
- (int) getFactTableRowsCount;
- (NSString *) getFact:(int) alt;
- (BOOL) dropTable:(NSString*)table;


@end
