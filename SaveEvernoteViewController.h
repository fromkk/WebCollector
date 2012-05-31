//
//  SaveEvernoteViewController.h
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/05/09.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvernoteSDK.h"
#import "NSData+MD5.h"

@interface SaveEvernoteViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate> {
    UITableView *tableView;
    UITextField *noteName;
    UITextView *noteDetail;
    UIView *_loading_bg;
    UIActivityIndicatorView *_indicator;
    UIButton *btn_keyboard;
    UIImage *postImage;
    EvernoteNoteStore *noteStore;
    NSURL *currentUrl;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UITextField *noteName;
@property (nonatomic, retain) UITextView *noteDetail;
@property (nonatomic, retain) UIView *_loading_bg;
@property (nonatomic, retain) UIActivityIndicatorView *_indicator;
@property (nonatomic, retain) UIButton *btn_keyboard;
@property (nonatomic, assign) UIImage *postImage;
@property (nonatomic, retain) EvernoteNoteStore *noteStore;
@property (nonatomic, assign) NSURL *currentUrl;

- (void)keyboardWillShow:(NSNotification *)notif;
- (void)keyboardWillHide:(NSNotification *)notif;
- (void)tappedBtnBack:(UIBarButtonItem *)btn;
- (void)tappedBtnSave:(UIBarButtonItem *)btn;
- (void)tappedBtnKeyboard:(UIButton *)btn;
- (void)executeSaveImages:(EDAMNotebook *)notebook;

@end
