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
- (BOOL) checkTableExists:(NSString *)tableName;
- (int) getTableRowCount:(NSString *)tableName;
- (NSString *) getFact:(int) alt;
- (BOOL) dropTable:(NSString*)tableName;


@end
