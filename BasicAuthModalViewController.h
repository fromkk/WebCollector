//
//  BasicAuthModalViewController.h
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BasicAuthModalViewControllerDelegate <NSObject>

- (void)basicAuthDidEntered:(NSString *)user_id passwd:(NSString *)passwd;

@end

@interface BasicAuthModalViewController : UITableViewController <UITableViewDelegate, UITextFieldDelegate> {
    id <BasicAuthModalViewControllerDelegate> delegate;
    UITextField *user_id;
    UITextField *passwd;
    UIBarButtonItem *btnClose;
    UIBarButtonItem *btnDone;
}
@property (nonatomic, strong) id <BasicAuthModalViewControllerDelegate> delegate;
@property (nonatomic, retain) UITextField *user_id;
@property (nonatomic, retain) UITextField *passwd;
@property (nonatomic, retain) UIBarButtonItem *btnClose;
@property (nonatomic, retain) UIBarButtonItem *btnDone;

-(void)doClose:(id)sender;
-(void)doDone:(id)sender;

@end
