//
//  DeviceViewController.h
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/03/27.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceViewContollerDelegate.h"

@interface DeviceViewController : UITableViewController {
    NSMutableArray *aryDevices;
    id<DeviceViewContollerDelegate> delegate;
}
@property (nonatomic, retain) NSMutableArray *aryDevices;
@property (nonatomic, strong) id<DeviceViewContollerDelegate> delegate;

@end
