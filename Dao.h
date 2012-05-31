//
//  Dao.h
//  shiori
//
//  Created by Ueoka Kazuya on 11/05/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Dao : NSObject {
    NSString *databasePath;
    NSString *table;
    NSString *_sql;
}
@property (nonatomic, retain) NSString *databasePath;
@property (nonatomic, retain) NSString *table;
@property (nonatomic, retain) NSString *_sql;

-(id)initWithPath:(NSString *)path;
-(sqlite3 *)connect;
-(void)defaultSetting;
-(BOOL)checkDefault;
-(NSArray *)get:(NSString *)sql bind:(NSArray *)bind;
-(BOOL)insert:(NSDictionary *)data;
-(BOOL)update:(NSDictionary *)data where:(NSString *)where;
-(NSString *)count:(NSString *)where;

@end
