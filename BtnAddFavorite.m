//
//  BtnAddFavorite.m
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/03/27.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import "BtnAddFavorite.h"

@implementation BtnAddFavorite

@synthesize imageHas;
@synthesize imageNot;
@synthesize has;

- (void)dealloc {
    [super dealloc];
}

- (id)init {
    self = [super init];
    if ( self ) {
        [self defaultSetting];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetting];
    }
    
    return self;
}

- (void)defaultSetting {
    imageHas = [UIImage imageNamed:@"btn_has_favorite.png"];
    imageNot = [UIImage imageNamed:@"btn_not_favorite.png"];
    
    [self setImage:imageNot forState:UIControlStateNormal];
}

- (void)changeHas:(BOOL)_has {
    [self setHas:_has];
    
    if ( self.has ) {
        [self setImage:imageHas forState:UIControlStateNormal];
    } else {
        [self setImage:imageNot forState:UIControlStateNormal];
    }
}

@end
