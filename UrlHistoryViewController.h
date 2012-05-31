//
//  UrlHistoryViewController.h
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UrlHistoryViewControllerDelegate <NSObject>

- (void)urlDidSelected:(NSString *)url;

@end

@interface UrlHistoryViewController : UITableViewController {
    NSArray *aryHistoryList;
    id <UrlHistoryViewControllerDelegate> delegate;
}
@property (nonatomic, retain) NSArray *aryHistoryList;
@property (nonatomic, strong) id <UrlHistoryViewControllerDelegate> delegate;

@end
