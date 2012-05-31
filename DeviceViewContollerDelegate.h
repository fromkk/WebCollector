//
//  DeviceViewContollerDelegate.h
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/03/27.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DeviceViewContollerDelegate <NSObject>

- (void)doSelectDevice:(NSDictionary *)device;

@end
