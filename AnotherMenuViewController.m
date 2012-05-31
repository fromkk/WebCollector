//
//  AnotherMenuViewController.m
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AnotherMenuViewController.h"
#import "EvernoteSDK.h"
#import "AppDelegate.h"

#define CHECK_LINK 0
#define OPEN_SAFARI 1
#define SHOW_SOURCE 2
#define SHOW_DEVICES 3
#define LOGOUT_FACEBOOK 4
#define LOGOUT_EVERNOTE 5
#define PURCHASE_HIDE_AD 6

@implementation AnotherMenuViewController

@synthesize btnClose;
@synthesize webView;
@synthesize _interfaceOrientation;
@synthesize xmlParser;
@synthesize currentUrl;
@synthesize errorUrlList;
@synthesize delegate;
@synthesize _loadingBgView;
@synthesize _spinner;
@synthesize currentCount;
@synthesize sourceView;
@synthesize sourceViewController;
@synthesize deviceViewController;
@synthesize isPurchase;
@synthesize loadingBg;
@synthesize indicator;

- (void)dealloc {
    [xmlParser release];
    [currentUrl release];
    [errorUrlList release];
    [_loadingBgView release];
    [_spinner release];
    [sourceView release];
    [sourceViewController release];
    [deviceViewController release];
    
    [loadingBg release];
    [indicator release];
    
    delegate = nil;
    NSLog(@"%s", __FUNCTION__);
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"AnotherMenu", nil)];
    
    btnClose = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"close", nil) style:UIBarButtonItemStylePlain 
                                               target:self action:@selector(closeModalView:)];
    
    self.navigationItem.rightBarButtonItem = btnClose;
    [btnClose release];

    _loadingBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
    _loadingBgView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    _loadingBgView.hidden = YES;
    [self.parentViewController.view addSubview:_loadingBgView];
    
    _spinner       = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_spinner setHidesWhenStopped:YES];
    [_spinner stopAnimating];
    [self.parentViewController.view addSubview:_spinner];
    
    sourceViewController = [[UIViewController alloc] init];
    sourceViewController.title = NSLocalizedString(@"source", nil);
    sourceView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    sourceViewController.view = sourceView;
    [sourceView setEditable:NO];
    
    currentCount = 0;
    
    loadingBg = [[UIView alloc] initWithFrame:self.view.bounds];
    loadingBg.backgroundColor = [UIColor blackColor];
    loadingBg.alpha = 0.5f;
    loadingBg.hidden = YES;
    [self.view addSubview:loadingBg];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(loadingBg.frame.size.width / 2, loadingBg.frame.size.height / 2);
    [self.view addSubview:indicator];
    
    [indicator stopAnimating];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL result = (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
                   || interfaceOrientation == UIInterfaceOrientationPortrait);
    
    if ( YES == result ) {
        [self changeDisplaySize:interfaceOrientation];
    }
    
    return result;
}

-(void)changeDisplaySize:(UIInterfaceOrientation)interfaceOrientation
{
    _interfaceOrientation = interfaceOrientation;
    
    if (UIInterfaceOrientationPortrait == interfaceOrientation)
    {
        _loadingBgView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
        _spinner.frame       = CGRectMake(120.0f, 200.0f, 80.0f, 80.0f);
        sourceView.frame     = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    } else if ( UIInterfaceOrientationLandscapeLeft == interfaceOrientation ) {
        _loadingBgView.frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
        _spinner.frame       = CGRectMake(200.0f, 120.0f, 80.0f, 80.0f);
        sourceView.frame     = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)closeModalView:(id)sender
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6 + ( NO == isPurchase ? 1 : 0 );
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case CHECK_LINK:
            cell.textLabel.text = NSLocalizedString(@"CheckLink", nil);
            break;
        case OPEN_SAFARI:
            cell.textLabel.text = NSLocalizedString(@"OpenSafari", nil);
            break;
        case SHOW_SOURCE:
            cell.textLabel.text = NSLocalizedString(@"ShowSource", nil);
            break;
        case SHOW_DEVICES:
            cell.textLabel.text = NSLocalizedString(@"ShowDevices", nil);
            break;
        case LOGOUT_EVERNOTE:
            
            cell.textLabel.text = NSLocalizedString(@"LogoutEvernote", nil);
            break;
        case LOGOUT_FACEBOOK:
            cell.textLabel.text = NSLocalizedString(@"LogoutFacebook", nil);
            break;
        case PURCHASE_HIDE_AD:
            cell.textLabel.text = NSLocalizedString(@"PurchaseHideAd", nil);
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

-(void)checkLink
{
    errorUrlList = [[NSMutableArray alloc] init];
    
    NSString *xml = [self.webView stringByEvaluatingJavaScriptFromString:@"var htmlEscape = (function(){var map = {'<':'&lt;', '>':'&gt;', '&':'&amp;', '\\'':'&#39;', '\"':'&quot;'}; var replaceStr = function(s){ return map[s]; }; return function(str) { return str.replace(/<|>|&|'|\"/g, replaceStr); };})(); function getLinkList() { var aryLinkList = document.getElementsByTagName('a'); var xml = '<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?><Linklist><Items>'; var currentLink; for (var i = 0; i < aryLinkList.length; i++) {currentLink = aryLinkList.item(i); if (-1 != currentLink.href.indexOf('javascript:') || -1 != currentLink.href.indexOf('tel:') || -1 != currentLink.href.indexOf('mailto:') || '' == currentLink.href) {continue;} xml += '<Item><url>' + htmlEscape(currentLink.href) + '</url></Item>'; } xml += '</Items></Linklist>'; return xml;} getLinkList();"];
    
    NSData *xmlData = [xml dataUsingEncoding:NSUTF8StringEncoding];
    
    xmlParser = [[LinkListXmlParser alloc] initWithData:xmlData];
    [xmlParser setDelegate:xmlParser];
    [xmlParser parse];
    
    currentCount = 0;
    
    int i;
    for (i = 0; i < xmlParser.linkList.count; i++) {
        currentUrl = [NSURL URLWithString:[xmlParser.linkList objectAtIndex:i]];
        NSLog(@"currentUrl:%@", [currentUrl description]);
        NSURLRequest *req = [NSURLRequest requestWithURL:currentUrl
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        // myUrlConnDelegateへdelegateしながら初期化
        NSURLConnection *conn;
        conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    }
}


// レスポンスを受け取った時点で呼び出される。データ受信よりも前なので注意
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
    
    int statusCode = [(NSHTTPURLResponse *)response statusCode];
    if(statusCode >= 400){
        [errorUrlList addObject:[NSString stringWithFormat:@"%@", connection.currentRequest.URL]];
    }
}

// データを受け取る度に呼び出される
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"didReceiveData");
}

// データを全て受け取ると呼び出される
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    currentCount++;
    
    NSLog(@"LinkCount:%d", xmlParser.linkList.count);
    NSLog(@"CurrentCount:%d", currentCount);
    
    if ( xmlParser.linkList.count == currentCount ) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        _loadingBgView.hidden = YES;
        [_spinner stopAnimating];
        
        if ( 0 == errorUrlList.count ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CheckResult", nil) message:NSLocalizedString(@"ErrorNothing", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:nil, nil];
            [alert show];
            
            [self.parentViewController dismissModalViewControllerAnimated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CheckResult", nil) message:NSLocalizedString(@"ErrorExist", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:nil, nil];
            [alert show];
            
            if ( [delegate respondsToSelector:@selector(dissmissModalAndReturnErrorUrlList:)] ) {
                [delegate dissmissModalAndReturnErrorUrlList:errorUrlList];
            }
        }
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    currentCount++;
    NSLog(@"%@", connection.currentRequest);
    
    NSLog(@"failed:%@", [connection description]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"FailNetwork", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:nil, nil];
    [alert show];
    
    //[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *sourceHtml = [[NSString alloc] init];
    NSString *charset    = [[NSString alloc] init];
    
    EvernoteSession *session = [EvernoteSession sharedSession];
    Facebook *facebook = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setCancelButtonIndex:0];
    switch (indexPath.row) {
        case CHECK_LINK:
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            _loadingBgView.hidden = NO;
            [_spinner startAnimating];
            [self checkLink];
            break;
        case OPEN_SAFARI:
            [[UIApplication sharedApplication] openURL:[[webView request] URL]];
            break;
        case SHOW_SOURCE:
            sourceHtml = [webView stringByEvaluatingJavaScriptFromString:@"var h=function(){d=document;c=d.charset||0;i=0;o=d.documentElement;s=o.outerHTML;return s;};h();"];
            charset = [webView stringByEvaluatingJavaScriptFromString:@"document.charset"];
            
//            if ( [charset isEqualToString:@"UTF-8"] ) {
//                data = [sourceHtml dataUsingEncoding:NSUTF8StringEncoding];
//            } else if ([charset isEqualToString:@"EUC-JP"]) {
//                data = [sourceHtml dataUsingEncoding:NSJapaneseEUCStringEncoding];
//            } else if ([charset isEqualToString:@"Shift_JIS"]) {
//                data = [sourceHtml dataUsingEncoding:NSShiftJISStringEncoding];
//            }
            
            [sourceView setText:sourceHtml];
            
            [self.navigationController pushViewController:sourceViewController animated:YES];
            break;
        case SHOW_DEVICES:
            [self.navigationController pushViewController:deviceViewController animated:YES];
            break;
        case LOGOUT_FACEBOOK:
            if ( [facebook isSessionValid] ) {
                [facebook logout];
                
                alert.title = NSLocalizedString(@"complete", nil);
                alert.message = NSLocalizedString(@"CompLogoutFacebook", nil);
                [alert show];
            }
            break;
        case LOGOUT_EVERNOTE:
            if ( [session isAuthenticated] ) {
                [session logout];
                
                alert.title = NSLocalizedString(@"complete", nil);
                alert.message = NSLocalizedString(@"CompLogoutEvernote", nil);
                [alert show];
            }
            break;
        case PURCHASE_HIDE_AD:
            [self buyHideAdFeature];
            break;
        default:
            break;
    }
    [alert release];
}

- (void)showIndicator {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    loadingBg.hidden = NO;
    [indicator startAnimating];
}

- (void)hideIndicator {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    loadingBg.hidden = YES;
    [indicator stopAnimating];
}

- (void)buyHideAdFeature {
    [self showIndicator];
    
    NSLog(@"%s", __FUNCTION__);
    
    if ([SKPaymentQueue canMakePayments] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"notAllowInAppPurchase", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        [self hideIndicator];
        return;
    }
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSSet *productIds = [NSSet setWithObject:productId];
    SKProductsRequest *skProductRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    skProductRequest.delegate = self;
    [skProductRequest start];
    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (response == nil) {
        NSLog(@"Product Response is nil");
        return;
    }
    
    // 確認できなかったidentifierをログに記録
    for (NSString *identifier in response.invalidProductIdentifiers) {
        NSLog(@"invalid product identifier: %@", identifier);
    }
    
    for (SKProduct *product in response.products ) {
        NSLog(@"valid product identifier: %@", product.productIdentifier);
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    BOOL purchasing = YES;
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // 購入中
            case SKPaymentTransactionStatePurchasing: {
                NSLog(@"Payment Transaction Purchasing");
                break;
            }
                // 購入成功
            case SKPaymentTransactionStatePurchased: {
                NSLog(@"Payment Transaction END Purchased: %@", transaction.transactionIdentifier);
                purchasing = NO;
                //[self completeUpgradePlus];
                [queue finishTransaction:transaction];
                [self hideIndicator];
                [self purchasedHideAd];
                break;
            }
                // 購入失敗
            case SKPaymentTransactionStateFailed: {
                NSLog(@"Payment Transaction END Failed: %@ %@", transaction.transactionIdentifier, transaction.error);
                purchasing = NO;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"failedInAppPurchase", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                [self hideIndicator];
                
                [queue finishTransaction:transaction];
                break;
            }
                // 購入履歴復元
            case SKPaymentTransactionStateRestored: {
                NSLog(@"Payment Transaction END Restored: %@", transaction.transactionIdentifier);
                // 本来ここに到達しない
                purchasing = NO;
                [queue finishTransaction:transaction];
                break;
            }
        }
    }
    
    if (purchasing == NO) {
        //[(UIView *)[self.view.window viewWithTag:21] removeFromSuperview];
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)purchasedHideAd {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"complete", nil) message:NSLocalizedString(@"PurchaseComplete", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:@"PurchasedHideAd"];
    
    isPurchase = YES;
    [self.tableView reloadData];
    
    if ( [delegate respondsToSelector:@selector(purchasedHideAd)] ) {
        [delegate performSelector:@selector(purchasedHideAd)];
    }
}

@end
