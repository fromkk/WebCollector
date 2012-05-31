//
//  AnotherMenuViewController.h
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinkListXmlParser.h"
#import "DeviceViewController.h"
#import <StoreKit/StoreKit.h>

@protocol AnotherMenuViewControllerDelegate <NSObject>

- (void)dissmissModalAndReturnErrorUrlList:(NSArray *)url_list;
- (void)purchasedHideAd;

@end

@interface AnotherMenuViewController : UITableViewController <UITableViewDelegate, NSURLConnectionDelegate,
    SKPaymentTransactionObserver,
    SKProductsRequestDelegate> {
    UIBarButtonItem *btnClose;
    UIWebView *webView;
    UIInterfaceOrientation _interfaceOrientaion;
    LinkListXmlParser *xmlParser;
    NSURL *currentUrl;
    NSInteger currentCount;
    NSMutableArray *errorUrlList;
    id<AnotherMenuViewControllerDelegate> delegate;
    UIView *_loadingBgView;
    UIActivityIndicatorView *_spinner;
    UITextView *sourceView;
    UIViewController *sourceViewController;
    DeviceViewController *deviceViewController;
    BOOL isPurchase;
    UIView *loadingBg;
    UIActivityIndicatorView *indicator;
}
@property (nonatomic, retain) UIBarButtonItem *btnClose;
@property (nonatomic, assign) UIWebView *webView;
@property (nonatomic) UIInterfaceOrientation _interfaceOrientation;
@property (nonatomic, retain) LinkListXmlParser *xmlParser;
@property (nonatomic, retain) NSURL *currentUrl;
@property (nonatomic, retain) NSMutableArray *errorUrlList;
@property (nonatomic, strong) id<AnotherMenuViewControllerDelegate> delegate;
@property (nonatomic, retain) UIView *_loadingBgView;
@property (nonatomic, retain) UIActivityIndicatorView *_spinner;
@property (nonatomic) NSInteger currentCount;
@property (nonatomic, retain) UITextView *sourceView;
@property (nonatomic, retain) UIViewController *sourceViewController;
@property (nonatomic, retain) DeviceViewController *deviceViewController;
@property (nonatomic, assign) BOOL isPurchase;
@property (nonatomic, retain) UIView *loadingBg;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;

- (void)closeModalView:(id)sender;
-(void)changeDisplaySize:(UIInterfaceOrientation)interfaceOrientation;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)buyHideAdFeature;
- (void)showIndicator;
- (void)hideIndicator;
- (void)purchasedHideAd;


@end
