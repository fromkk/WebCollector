//
//  Common.m
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/03/27.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import "Common.h"

@implementation Common

@synthesize dao;

static Common *sharedCommon;

+ (Common *)sharedManager {
	@synchronized(self) {
		if (sharedCommon == nil) {
			sharedCommon = [[self alloc] init];
		}
	}
	return sharedCommon;
}

- (id)init {
    dao = [[Dao alloc] initWithPath:@"history.sqlite"];
    [dao connect];
    
    return self;
}

- (id)copyWithZone:(NSZone*)zone {
	return self;  // シングルトン状態を保持するため何もせず self を返す
}

@end
