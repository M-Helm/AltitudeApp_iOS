//
//  DBManager.m
//  howhimi
//
//  Created by Matthew Helm on 4/11/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "DBManager.h"

@interface DBManager()

@end

static DBManager *sharedDBManager = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

NSString* const createFactsTableString = @"create table if not exists facts(local_id integer primary key autoincrement, timestamp int NOT NULL, altitude int, fact var_char(255))";
NSString* const createAltitudeTableString = @"create table if not exists altitude(local_id integer primary key autoincrement, timestamp int NOT NULL, altitude int)";
NSString* const databaseName = @"howhimi.db";
NSString* const initFactListName = @"fact_list_20150413.txt";

@implementation DBManager

+ (id)sharedDBManager {
    static DBManager *sharedDBManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDBManager = [[self alloc] init];
        if(![sharedDBManager checkTableExists:@"facts"]){
            [sharedDBManager createTable:createFactsTableString];
        }
        [sharedDBManager createTable:createAltitudeTableString];
    });
    return sharedDBManager;
}
-(NSArray*)getInitFacts{
    //NSLog(@"pop Table");
    [self createTable:createFactsTableString];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [path stringByAppendingPathComponent:initFactListName];
    NSString *contentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

    NSData *jsonData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"%i",(int)[jsonData length]);
    
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
    //NSLog(@"count %i", (int)[jsonArray count]);
    //check if data exists in table and return the array w/o saving if so.
    if([self getTableRowCount:@"facts"] > 1)return jsonArray;
    //NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    //int timestamp = (int)timeInterval;
    int i = 0;
    while (i < [jsonArray count]){
        NSMutableDictionary *json = [jsonArray objectAtIndex:i];
        json[@"timestamp"] = @0;
        //NSLog(@"json: %@ %@ %@", [json objectForKey:@"alt"],
        //                         [json objectForKey:@"timestamp"],
        //                         [json objectForKey:@"msg"]);
        [self saveFact:json];
        i++;
    }
    return jsonArray;
}

-(BOOL)createTable:(NSString *)createString{
    //NSLog(@"create table called %@", createString);
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: databaseName]];
    BOOL isSuccess = YES;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = [createString UTF8String];
        
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
            != SQLITE_OK)
        {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
        sqlite3_close(database);
        return  isSuccess;
    }
    return isSuccess;
}
- (BOOL) saveFact:(NSDictionary *)msgJSON{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into facts (timestamp, altitude, fact) values(\"%@\", \"%@\", \"%@\")",
                               [msgJSON objectForKey:@"timestamp"],
                               [msgJSON objectForKey:@"alt"],
                               [msgJSON objectForKey:@"msg"]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"fact saved to db");
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return true;
        }
        else{
            NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(database));
            sqlite3_close(database);
            return false;
        }
    }
    sqlite3_close(database);
    NSLog(@"failed to save message");
    return false;
}
- (BOOL) saveAltitude:(NSDictionary *)msgJSON{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into altitude (timestamp, altitude) values(\"%@\", \"%@\")",
                               [msgJSON objectForKey:@"timestamp"],
                               [msgJSON objectForKey:@"altitude"]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"alt saved to db");
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return true;
        }
        else{
            NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(database));
            sqlite3_close(database);
            return false;
        }
    }
    sqlite3_close(database);
    NSLog(@"failed to save message");
    return false;
}
- (NSArray *)getAltitudeArray{
    NSString *sql_str = @"SELECT * FROM altitude ORDER BY local_id DESC LIMIT 20";
    NSMutableArray *queryArray = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *query_stmt = [sql_str UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //NSLog(@"msg sql ok");
            if(sqlite3_step(statement) > 0){
                NSLog(@"step > 0 %i", sqlite3_step(statement));
            }
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *altitude = [[NSString alloc] initWithUTF8String:
                        (const char *) sqlite3_column_text(statement, 2)];
                NSString *timestamp = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 1)];
                int i = (int)altitude.integerValue;
                NSLog(@"alt string = %@", altitude);
                NSLog(@"ts string = %@", timestamp);
                NSNumber *alt = [NSNumber numberWithInt:i];
                [queryArray addObject:alt];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    //[self cullAltitudeTable];
    return queryArray;
}

- (BOOL) checkTableExists:(NSString *)tableName{
    //NSLog(@"check Table called");
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 1", tableName];
        const char *query_stmt = [querySQL UTF8String];

        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"msg sql ok");
            if(sqlite3_step(statement) > 0){
                NSLog(@"step > 0 %i", sqlite3_step(statement));
                return true;
            }
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                //nothing goes here yet
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    NSLog(@"Return Nil");
    return false;
}

- (int) getTableRowCount:(NSString *)tableName{
    int count = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString* sql_str = [NSString stringWithFormat: @"SELECT COUNT(*) FROM %@", tableName];
        const char* sqlStatement = [sql_str UTF8String];
        sqlite3_stmt *statement;
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                count = sqlite3_column_int(statement, 0);
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        NSLog(@"count %i", count);
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return count;
}

- (NSString *) getFact:(int) alt{
    int altBoundLo = alt - 51;
    int altBoundHi = alt + 51;
    //NSString *fact = @"Database error";
    NSString *fact = @"";
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM facts WHERE altitude BETWEEN %i and %i ORDER BY RANDOM() LIMIT 1", altBoundLo, altBoundHi];
        //NSString *querySQL = [NSString stringWithFormat:@"SELECT altitude FROM facts"];
        //NSLog(@"%@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"msg sql ok");
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                fact = [[NSString alloc] initWithUTF8String:
                        (const char *) sqlite3_column_text(statement, 3)];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    //NSLog(@"... %@", fact);
    return fact;
}

-(BOOL) dropTable:(NSString*)tableName{
    NSString *docsDir;
    NSString *sql_str = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent:databaseName]];
    const char *dbpath = [databasePath UTF8String];
    const char *drop_stmt = [sql_str UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        if (sqlite3_exec(database, drop_stmt, NULL, NULL, &errMsg)!= SQLITE_OK){
            NSString *msg = [NSString stringWithFormat:@"%s", errMsg];
            NSLog(@"Failed to drop table: %@", msg);
            sqlite3_close(database);
            return false;
        }else{
            sqlite3_close(database);
            return true;
        }
    }
    return false;
}
-(void)cullAltitudeTable{
    NSString *sql_str = @"SELECT * FROM altitude ORDER BY local_id DESC";
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *query_stmt = [sql_str UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if(sqlite3_step(statement) > 21){
                NSString *lastTS = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 1)];
                NSLog(@"last DB TS: %@", lastTS);
                int i = (int)lastTS.integerValue;
                //i = i - 260000;
                i = i - 300;
                NSLog(@"id string = %i", i);
                NSString *delete_str = [NSString stringWithFormat:@"DELETE FROM altitude WHERE timestamp < %i", i];
                const char *delete_stmt = [delete_str UTF8String];
                char *errMsg;
                if (sqlite3_exec(database, delete_stmt, NULL, NULL, &errMsg)!= SQLITE_OK){
                    NSString *msg = [NSString stringWithFormat:@"%s", errMsg];
                    NSLog(@"Failed to delete rows: %@", msg);
                    sqlite3_finalize(statement);
                    sqlite3_close(database);
                    return;
                }else{
                    sqlite3_close(database);
                    return;
                }
            }
            sqlite3_close(database);
        }
    }
}

@end

