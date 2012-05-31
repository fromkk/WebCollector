//
//  WCToolbar.h
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/03/27.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface WCToolbar : UIToolbar {
    UIImage *bgImage;
    UIImageView *bgImageView;
}
@property (nonatomic, retain) UIImage *bgImage;
@property (nonatomic, retain) UIImageView *bgImageView;

@end
