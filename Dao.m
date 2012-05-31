//
//  Dao.m
//  shiori
//
//  Created by Ueoka Kazuya on 11/05/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Dao.h"

@implementation Dao

@synthesize databasePath;
@synthesize table;
@synthesize _sql;

static sqlite3 *database = NULL;

-(id)initWithPath:(NSString *)path
{
    if ( path != databasePath ) {
        [self setDatabasePath:path];
    }
    
    return [self init];
}

-(id)init
{
    return self;
}

-(sqlite3 *)connect
{
    if ( database == NULL ) {
        [self defaultSetting];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *path = [documentsDirectory stringByAppendingPathComponent:databasePath];
        
        if ( sqlite3_open([path UTF8String], &database) == SQLITE_ERROR ) {
            NSLog(@"Database open error.");
            
            sqlite3_close(database);
        }
    }
    
    return database;
}

-(void)defaultSetting
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:databasePath];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if(success) return;
    
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databasePath];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message ‘%@’.",[error localizedDescription]);
    }
}

-(NSArray *)get:(NSString *)sql bind:(NSArray *)bind
{
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    
    if ( YES == [self checkDefault] ) {
        sqlite3_stmt *stmt = NULL;
        
        if ( sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            
            if ( nil != bind ) {
                int b;
                for ( b = 1; b <= [bind count]; b++ ) {
                    sqlite3_bind_text(stmt, b, [[bind objectAtIndex:b - 1] UTF8String], -1, SQLITE_TRANSIENT);
                }
            }
            
            NSString *columnName;
            NSString *currentValue;
            int i;
            const unsigned char* buffer;
            while ( sqlite3_step(stmt) == SQLITE_ROW ) {
                NSInteger column_count = sqlite3_column_count(stmt);
                
                NSMutableDictionary *currentRow = [[NSMutableDictionary alloc] init];
                
                for ( i = 0; i < (int)column_count; i++ ) {
                    columnName = [NSString stringWithCString:sqlite3_column_name(stmt, i) encoding:NSUTF8StringEncoding];
                    
                    buffer = sqlite3_column_text(stmt, i);
                    
                    if ( NULL == buffer ) {
                        currentValue = @"";
                    } else {
                        currentValue = [NSString stringWithCString:(const char*)buffer encoding:NSUTF8StringEncoding];
                    }
                    
                    [currentRow setObject:currentValue forKey:columnName];
                }
                
                [result addObject:currentRow];
            }
        } else {
            NSLog(@"%s", sqlite3_errmsg(database));
        }
    }
    
    return result;
}

-(NSString *)count:(NSString *)where
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS cnt FROM %@ WHERE %@", table, where];
    NSArray *values = [self get:sql bind:nil];

    return [[values objectAtIndex:0] objectForKey:@"cnt"];
}

-(BOOL)insert:(NSDictionary *)data
{
    BOOL result = YES;
    
    if ( NO == [self checkDefault] ) {
        result = NO;
    } else {
        NSArray *vals = [data allValues];
        NSArray *keys = [data allKeys];
        
        NSMutableArray *placeholder = [[NSMutableArray alloc] init];
        int i;
        for (i = 0; i < [keys count]; i++) {
            [placeholder addObject:@"?"];
        }
        
        _sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", table, [keys componentsJoinedByString:@","], [placeholder componentsJoinedByString:@","]];
        [placeholder release];
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [_sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            int j;
            NSString* currentValue;
            for (j = 1; j <= [vals count]; j++) {
                currentValue = [vals objectAtIndex:j - 1];
                
                sqlite3_bind_text(statement, j, [currentValue UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            if( sqlite3_step(statement) != SQLITE_DONE ) {
                result = NO;
                sqlite3_finalize(statement);
                
                NSLog(@"Insert error: %s", sqlite3_errmsg(database));
            } else {
                result = YES;
                
            }
        } else {
            NSLog(@"Statement error : %@", sqlite3_errmsg(database));
            result = NO;
        }
        
        return result;
    }
    
    return result;
}

-(BOOL)update:(NSDictionary *)data where:(NSString *)where
{
    BOOL result = YES;
    
    if ( NO == [self checkDefault] ) {
        result = NO;
    } else {
        NSArray *vals = [data allValues];
        NSArray *keys = [data allKeys];
        
        NSMutableArray *placeholder = [[NSMutableArray alloc] init];
        int i;
        for (i = 0; i < [keys count]; i++) {
            [placeholder addObject:[NSString stringWithFormat:@"%@ = ?", [keys objectAtIndex:i]] ];
        }
        
        _sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", table, [placeholder componentsJoinedByString:@","], where];
        [placeholder release];
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [_sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            int j;
            NSString* currentValue;
            for (j = 1; j <= [vals count]; j++) {
                currentValue = [vals objectAtIndex:j - 1];
                
                sqlite3_bind_text(statement, j, [currentValue UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            if( sqlite3_step(statement) != SQLITE_DONE ) {
                result = NO;
                sqlite3_finalize(statement);
                
                NSLog(@"Update error: %s", sqlite3_errmsg(database));
            } else {
                result = YES;
            }
        } else {
            NSLog(@"Statement error : %@", sqlite3_errmsg(database));
            result = NO;
        }
        
        return result;
    }
    
    return result;
}


-(BOOL)checkDefault
{
    BOOL result = YES;
    
    if ( NULL == database ) {
        NSLog(@"Database not connected.");
        
        result = NO;
    }
    
    if ( nil == [self table] ) {
        NSLog(@"Table is not setted.");
        
        result = NO;
    }
    
    return result;
}

@end
