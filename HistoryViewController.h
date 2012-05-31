//
//  HistoryViewController.h
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@protocol HistoryViewControllerDelegate <NSObject>

- (void)doSelectHistory:(NSString *)url;

@end

@interface HistoryViewController : UITableViewController <UITableViewDelegate, UIAlertViewDelegate> {
    id <HistoryViewControllerDelegate> delegate;
    NSArray *aryHistoryList;
    NSMutableArray *aryDateList;
    NSMutableDictionary *dicDateHistory;
    NSInteger totalCount;
    UIBarButtonItem *btnReset;
    NSInteger mode;
}
@property (nonatomic, strong) id <HistoryViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray *aryHistoryList;
@property (nonatomic, retain) NSMutableArray *aryDateList;
@property (nonatomic, retain) NSMutableDictionary *dicDateHistory;
@property (nonatomic) NSInteger totalCount;
@property (nonatomic, retain) UIBarButtonItem *btnReset;
@property (nonatomic) NSInteger mode;

- (BOOL)in_array:(NSString *)search from:(NSArray *)from;
- (void)doReset:(id)sender;
- (void)close;

@end
