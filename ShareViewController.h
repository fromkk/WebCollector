//
//  ShareViewController.h
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/08.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FBConnect.h"
#import "ShareViewControllerProtocol.h"
#import "SaveEvernoteViewController.h"
#import "WCNavigationController.h"

@interface ShareViewController : UIViewController <MFMailComposeViewControllerDelegate,ShareViewControllerProtocol,FBRequestDelegate, UIActionSheetDelegate> {
    UIScrollView *previewView;
    UIImageView *previewImage;
    UIToolbar *barBgButtons;
    UIButton *btnSaveAlbum;
    UIButton *btnSendEmail;
    UIButton *btnShareTwitter;
    UIBarButtonItem *btnClose;
    TWTweetComposeViewController *tweetViewController;
    MFMailComposeViewController *mailPicker;
    UIView *_loadingBgView;
    UIActivityIndicatorView *_spinner;
    UIInterfaceOrientation _interfaceOrientaion;
    UIButton *btnShareFb;
    Facebook *facebook;
    UITextView *fbComment;
    UIButton *btnFbPost;
    UIView *_fbBgView;
    UIActionSheet *actionSheet;
    NSInteger indexAlbum;
    NSInteger indexMail;
    NSInteger indexFacebook;
    NSInteger indexEvernote;
    NSInteger indexTwitter;
    NSInteger indexClose;
    NSURL *currentUrl;
}

@property (nonatomic, retain) UIScrollView *previewView;
@property (nonatomic, retain) UIImageView *previewImage;

@property (nonatomic, retain) UIToolbar *barBgButtons;
@property (nonatomic, retain) UIButton *btnSaveAlbum;
@property (nonatomic, retain) UIButton *btnSendEmail;
@property (nonatomic, retain) UIButton *btnShareTwitter;
@property (nonatomic, retain) UIBarButtonItem *btnClose;
@property (nonatomic, retain) TWTweetComposeViewController *tweetViewController;
@property (nonatomic, retain) MFMailComposeViewController *mailPicker;
@property (nonatomic, retain) UIView *_loadingBgView;
@property (nonatomic, retain) UIActivityIndicatorView *_spinner;
@property (nonatomic) UIInterfaceOrientation _interfaceOrientation;
@property (nonatomic, retain) UIButton *btnShareFb;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) UITextView *fbComment;
@property (nonatomic, retain) UIButton *btnFbPost;
@property (nonatomic, retain) UIView *_fbBgView;
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic) NSInteger indexAlbum;
@property (nonatomic) NSInteger indexMail;
@property (nonatomic) NSInteger indexFacebook;
@property (nonatomic) NSInteger indexEvernote;
@property (nonatomic) NSInteger indexTwitter;
@property (nonatomic) NSInteger indexClose;
@property (nonatomic, assign) NSURL *currentUrl;

- (void)dispTweetView;
-(void)changeDisplaySize:(UIInterfaceOrientation)interfaceOrientation;
- (void)shareFb:(id)sender;
- (void)postToFb:(id)sender;
- (void)saveEvernote:(id)sender;
- (void)tappedBtnShare:(UIBarButtonItem *)btn;
- (void)showEvernoteView;

@end
