//
//  FavoriteViewController.h
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/03/27.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@protocol FavoriteViewControllerDelegate <NSObject>

- (void)doSelectFavorite:(NSString *)_url;

@end

@interface FavoriteViewController : UITableViewController {
    NSMutableArray *aryFavorite;
    id<FavoriteViewControllerDelegate> delegate;
}
@property (nonatomic, retain) NSMutableArray *aryFavorite;
@property (nonatomic, strong) id<FavoriteViewControllerDelegate> delegate;

- (void)close;

@end
