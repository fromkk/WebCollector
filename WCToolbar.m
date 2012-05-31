//
//  WCToolbar.m
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/03/27.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import "WCToolbar.h"

@implementation WCToolbar

@synthesize bgImage;
@synthesize bgImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        bgImage = [UIImage imageNamed:@"bg_toolbar.png"];
        if ( 5.0f <= [[[UIDevice currentDevice] systemVersion] floatValue] ) {
            [self setBackgroundImage:bgImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        } else {
            bgImageView = [[UIImageView alloc] initWithImage:bgImage];
            bgImageView.frame = self.bounds;
            bgImageView.autoresizingMask =
            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            bgImageView.layer.zPosition = -FLT_MAX;
            [self insertSubview:bgImageView atIndex:0];
            [bgImageView release];
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
