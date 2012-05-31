//
//  MainViewController.h
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/07.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCToolbar.h"
#import "WCNavigationController.h"
#import "UrlTextField.h"
#import "ZBarSDK.h"
#import "ShareViewController.h"
#import "AnotherMenuViewController.h"
#import "FavoriteViewController.h"
#import "HistoryViewController.h"
#import "UrlHistoryViewController.h"
#import "Common.h"
#import "GADBannerView.h"
#import "BasicAuthModalViewController.h"
#import "Base64EncDec.h"
#import "BtnAddFavorite.h"
#import "DeviceViewController.h"

@interface MainViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UIAlertViewDelegate, ZBarReaderDelegate, GADBannerViewDelegate, AnotherMenuViewControllerDelegate, HistoryViewControllerDelegate, UrlHistoryViewControllerDelegate, FavoriteViewControllerDelegate, NSURLConnectionDelegate, BasicAuthModalViewControllerDelegate, DeviceViewContollerDelegate> {
    WCToolbar *barHeader;
    UIScrollView *headerScrollView;
    UrlTextField *url;
    BtnAddFavorite *btnAddFavorite;
    UIButton *btnShot;
    UIWebView *webView;
    WCToolbar *barFooter;
    CGSize fittingSize;
    UIImageView *imageView;
    CGRect baseFrame;
    UIButton *btn_back;
    UIButton *btn_forward;
    UIButton *btn_reload;
    UIButton *btn_stop;
    UIBarButtonItem *btn_favorite;
    UIBarButtonItem *btn_history;
    UIBarButtonItem *btn_barcode;
    UIBarButtonItem *btn_another;
    UIBarButtonItem *btn_close;
    WCNavigationController *navigationController;
    AnotherMenuViewController *anotherMenuViewController;
    HistoryViewController *historyViewController;
    BasicAuthModalViewController *basicAuthViewController;
    NSString *_qr_data;
    GADBannerView *bannerView_;
    UIView *shutterView;
    UIInterfaceOrientation _interfaceOrientaion;
    UrlHistoryViewController *historyTable;
    NSArray *aryHistoryList;
    BOOL isPurchased;
}

@property (nonatomic, retain) WCToolbar *barHeader;
@property (nonatomic, retain) UIScrollView *headerScrollView;
@property (nonatomic, retain) BtnAddFavorite *btnAddFavorite;
@property (nonatomic, retain) UrlTextField *url;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIButton *btnShot;
@property (nonatomic, retain) WCToolbar *barFooter;
@property (nonatomic) CGSize fittingSize;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic) CGRect baseFrame;
@property (nonatomic, retain) UIButton *btn_back;
@property (nonatomic, retain) UIButton *btn_forward;
@property (nonatomic, retain) UIButton *btn_reload;
@property (nonatomic, retain) UIButton *btn_stop;
@property (nonatomic, retain) UIBarButtonItem *btn_favorite;
@property (nonatomic, retain) UIBarButtonItem *btn_history;
@property (nonatomic, retain) UIBarButtonItem *btn_barcode;
@property (nonatomic, retain) UIBarButtonItem *btn_another;
@property (nonatomic, retain) WCNavigationController *navigationController;
@property (nonatomic, retain) AnotherMenuViewController *anotherMenuViewController;
@property (nonatomic, retain) HistoryViewController *historyViewController;
@property (nonatomic, retain) NSString *_qr_data;
@property (nonatomic, retain) UIView *shutterView;
@property (nonatomic) UIInterfaceOrientation _interfaceOrientation;
@property (nonatomic, retain) UrlHistoryViewController *historyTable;
@property (nonatomic, retain) NSArray *aryHistoryList;
@property (nonatomic, assign) BOOL isPurchased;

- (void)tappedBtnShot:(id)sender;
- (void)tappedBtnAddFavorite:(id)sender;
- (BOOL)hasBookmark;
- (void)doAccess;
- (void)scanBarcode:(id)sender;
- (void)changeDisplaySize:(UIInterfaceOrientation)interfaceOrientation;
- (void)takeCapture:(id)sender;
- (void)openAnotherMenu:(id)sender;
- (void)urlDidChanged:(id)sender;
- (void)showBookmarks;
- (void)showHistories;
- (void)changeWebviewSize:(float)width orientation:(UIInterfaceOrientation)interfaceOrientation;
-(NSString *) setViewportWidth:(CGFloat)inWidth;

@end
