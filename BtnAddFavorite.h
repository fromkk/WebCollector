//
//  BtnAddFavorite.h
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/03/27.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BtnAddFavorite : UIButton {
    UIImage *imageHas;
    UIImage *imageNot;
    BOOL has;
}
@property (nonatomic, retain) UIImage *imageHas;
@property (nonatomic, retain) UIImage *imageNot;
@property (nonatomic) BOOL has;

- (void)defaultSetting;
- (void)changeHas:(BOOL)_has;

@end
