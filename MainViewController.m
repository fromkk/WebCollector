//
//  MainViewController.m
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/07.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainViewController

@synthesize barHeader;
@synthesize headerScrollView;
@synthesize url;
@synthesize btnAddFavorite;
@synthesize webView;
@synthesize btnShot;
@synthesize barFooter;
@synthesize fittingSize;
@synthesize imageView;
@synthesize baseFrame;
@synthesize btn_back;
@synthesize btn_forward;
@synthesize btn_reload;
@synthesize btn_stop;
@synthesize btn_favorite;
@synthesize btn_history;
@synthesize btn_barcode;
@synthesize btn_another;
@synthesize anotherMenuViewController;
@synthesize historyViewController;
@synthesize navigationController;
@synthesize _qr_data;
@synthesize shutterView;
@synthesize _interfaceOrientation;
@synthesize historyTable;
@synthesize aryHistoryList;
@synthesize isPurchased;

- (void)dealloc {
    [barHeader release];
    [headerScrollView release];
    [url release];
    [btnAddFavorite release];
    [webView release];
    [barFooter release];
    [imageView release];
    [btn_back release];
    [btn_forward release];
    [btn_reload release];
    [btn_stop release];
    [btn_favorite release];
    [btn_history release];
    [btn_barcode release];
    [btn_another release];
    [shutterView release];
    [historyTable release];
    [aryHistoryList release];
    
    bannerView_ = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    historyTable.view.hidden = YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ( [[defaults objectForKey:@"PurchasedHideAd"] isEqualToString:@"1"] ) {
        isPurchased = YES;
    } else {
        isPurchased = NO;
    }
    
    
    Common *common = [Common sharedManager];
    [common.dao setTable:@"history"];
    
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    fittingSize = CGSizeZero;
    
    barHeader = [[WCToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0f, 44.0f)];
    [self.view addSubview:barHeader];
    
    headerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, barHeader.frame.size.width, barHeader.frame.size.height)];
    headerScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, barHeader.frame.size.height);
    headerScrollView.scrollEnabled = YES;
    headerScrollView.pagingEnabled = YES;
    headerScrollView.showsHorizontalScrollIndicator = NO;
    headerScrollView.showsVerticalScrollIndicator = NO;
    headerScrollView.scrollsToTop = NO;
    [barHeader addSubview:headerScrollView];
    
    url = [[UrlTextField alloc] initWithFrame:CGRectMake(10.0f, 6.0f, 310.0f, 32.0f)];
    url.placeholder = @"URL";
    url.delegate = self;
    url.borderStyle = UITextBorderStyleRoundedRect;
    url.keyboardType = UIKeyboardTypeURL;
    url.returnKeyType = UIReturnKeyDone;
    url.clearButtonMode = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(urlDidChanged:)
                                                 name:UITextFieldTextDidChangeNotification 
                                               object:nil];
    
    [headerScrollView addSubview:url];
    
    btnAddFavorite = [[BtnAddFavorite alloc] initWithFrame:CGRectMake(url.frame.size.width - 28.0f, 5.0f, 21.0f, 20.0f)];
    [btnAddFavorite addTarget:self action:@selector(tappedBtnAddFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [url addSubview:btnAddFavorite];
    
    float webViewHeight = 322.0f;
    if ( YES == isPurchased ) {
        webViewHeight = webViewHeight + GAD_SIZE_320x50.height;
    }
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, webViewHeight)];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    webView.dataDetectorTypes = UIDataDetectorTypeLink;
    
    [self.view addSubview:webView];
    
    btn_back = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 30.0f, 12.0f, 17.0f, 20.0f)];
    [btn_back setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [btn_back addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [headerScrollView addSubview:btn_back];
    
    if ( NO == [webView canGoBack] ) {
        [btn_back setEnabled:NO];
    }
    //btn_forward = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_forward.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forward:)];
    btn_forward = [[UIButton alloc] initWithFrame:CGRectMake(btn_back.frame.origin.x + btn_back.frame.size.width + 30.0f, 12.0f, 17.0f, 20.0f)];
    [btn_forward setImage:[UIImage imageNamed:@"btn_forward.png"] forState:UIControlStateNormal];
    [btn_forward addTarget:self action:@selector(forward:) forControlEvents:UIControlEventTouchUpInside];
    [headerScrollView addSubview:btn_forward];
    
    if ( NO == [webView canGoForward] ) {
        [btn_forward setEnabled:NO];
    }
    
    //btn_reload = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_reload.png"] style:UIBarButtonItemStylePlain target:self action:@selector(reload:)];
    btn_reload = [[UIButton alloc] initWithFrame:CGRectMake(btn_forward.frame.origin.x + btn_forward.frame.size.width + 30.0f, 12.0f, 21.0f, 20.0f)];
    [btn_reload setImage:[UIImage imageNamed:@"btn_reload.png"] forState:UIControlStateNormal];
    [btn_reload addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    [headerScrollView addSubview:btn_reload];
    [btn_reload setEnabled:NO];
    
    //btn_stop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_stop.png"] style:UIBarButtonItemStylePlain target:self action:@selector(stop:)];
    btn_stop = [[UIButton alloc] initWithFrame:CGRectMake(btn_reload.frame.origin.x + btn_reload.frame.size.width + 30.0f, 12.0f, 20.0f, 20.0f)];
    [btn_stop setImage:[UIImage imageNamed:@"btn_stop.png"] forState:UIControlStateNormal];
    [btn_stop addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    [headerScrollView addSubview:btn_stop];
    [btn_stop setEnabled:NO];
    
    btn_favorite = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_favorite.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showBookmarks)];
    
    btn_history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_history.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showHistories)];
    
    btn_barcode = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_barcode.png"] style:UIBarButtonItemStylePlain target:self action:@selector(scanBarcode:)];
    
    btn_another = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openAnotherMenu:)];
    
    barFooter = [[WCToolbar alloc] initWithFrame:CGRectMake(0.0f, 416.0f, 320.0f, 44.0f)];
    [self.view addSubview:barFooter];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [barFooter setItems:[NSArray arrayWithObjects:btn_favorite, space, btn_history, space, space, space, btn_barcode, space, btn_another, nil]];
    
    btnShot = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShot setImage:[UIImage imageNamed:@"btn_take.png"] forState:UIControlStateNormal];
    btnShot.frame = CGRectMake((barFooter.frame.size.width / 2) - 40.0f, barFooter.frame.origin.y, 80.0f, 44.0f);
    [btnShot addTarget:self action:@selector(tappedBtnShot:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnShot];
    
    if ( NO == isPurchased ) {
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                (self.view.frame.size.height - 44.0) -
                                                GAD_SIZE_320x50.height,
                                                GAD_SIZE_320x50.width,
                                                GAD_SIZE_320x50.height)];
        
        // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
        bannerView_.adUnitID = @"a14e90f3cd0fd14";
        bannerView_.delegate = self;
        
        // Let the runtime know which UIViewController to restore after taking
        // the user wherever the ad goes and add it to the view hierarchy.
        bannerView_.rootViewController = self;
        [self.view addSubview:bannerView_];
        
        // Initiate a generic request to load it with an ad.
        [bannerView_ loadRequest:[GADRequest request]];
    }
    
    NSArray *lastAccess = [common.dao get:@"SELECT * FROM history ORDER BY id DESC LIMIT 1" bind:nil];
    if ( 0 != [lastAccess count] ) {
        [url setText:[[lastAccess objectAtIndex:0] objectForKey:@"url"]];
        
        [self doAccess];
    } else {
        [url setText:@"http://www.google.com/"];
        
        [self doAccess];
    }
    
    aryHistoryList = [[NSArray alloc] init];
    historyTable = [[UrlHistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    historyTable.view.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, webView.frame.size.height);
    historyTable.delegate = self;
    [historyTable.view setHidden:YES];
    [self.view addSubview:historyTable.view];
}

- (void)purchasedHideAd {
    isPurchased = YES;
    
    if (nil != bannerView_) {
        bannerView_.hidden = YES;
    }
    
    if ( _interfaceOrientation == UIInterfaceOrientationPortrait ) {
        webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, 322.0f + GAD_SIZE_320x50.height);
    }
}

-(NSURLRequest*) uiWebView:(id)webView 
				  resource:(id)identifier 
		   willSendRequest:(NSURLRequest *)request 
		  redirectResponse:(NSURLResponse *)redirectResponse 
			fromDataSource:(id)dataSource
{
    
	NSMutableURLRequest *req = [request mutableCopy];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *_device = [defaults objectForKey:@"VirtualDevice"];
    
    if ( nil != _device ) {
        [req setValue:[_device objectForKey:@"ua"] forHTTPHeaderField:@"User-Agent"];
    }
     
	return req;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    [btnAddFavorite setHidden:YES];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [btnAddFavorite setHidden:NO];
    
    return YES;
}

- (void)tappedBtnAddFavorite:(id)sender {
    Common *common = [Common sharedManager];
    [common.dao setTable:@"favorites"];
    if ( [self hasBookmark] ) {
        [common.dao get:[NSString stringWithFormat:@"DELETE FROM favorites WHERE url = '%@'", url.text] bind:nil];
        
        [btnAddFavorite changeHas:NO];
    } else {
        NSDictionary *saveBookmark = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [webView stringByEvaluatingJavaScriptFromString:@"document.title"], @"title",
                                     [url text], @"url",
                                     [NSString stringWithFormat:@"%@", [NSDate date]], @"created"
                                     , nil];
        
        [common.dao insert:saveBookmark];
        [btnAddFavorite changeHas:YES];
    }
}

- (BOOL)hasBookmark {
    Common *common = [Common sharedManager];
    [common.dao setTable:@"favorites"];
    int hasFavorite = [[common.dao count:[NSString stringWithFormat:@"url = '%@'", url.text]] intValue];
    
    return 0 != hasFavorite;
}

- (BOOL)useTestAd {
    return NO;
}

- (void)showBookmarks {
    FavoriteViewController *favoriteViewController = [[FavoriteViewController alloc] initWithStyle:UITableViewStylePlain];
    favoriteViewController.delegate = self;
    
    navigationController = [[WCNavigationController alloc] initWithRootViewController:favoriteViewController];
    
    [self presentModalViewController:navigationController animated:YES];
    [favoriteViewController release];
}

- (void)doSelectFavorite:(NSString *)_url {
    [url setText:_url];
    [self doAccess];
    
    [navigationController dismissModalViewControllerAnimated:YES];
    [navigationController release];
}

- (void)showHistories {
    historyViewController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    historyViewController.delegate = self;
    historyViewController.mode = 0;
    
    navigationController = [[WCNavigationController alloc] initWithRootViewController:historyViewController];
    
    [self presentModalViewController:navigationController animated:YES];
    [historyViewController release];
}

- (void)urlDidChanged:(id)sender {
    if ( 0 != [[url text] length] ) {
        NSString *percent = @"%";
        NSString *like = [NSString stringWithFormat:@"%@%@%@", percent, [url text], percent];
        
        Common *common = [Common sharedManager];
        aryHistoryList = [common.dao get:@"SELECT title, url FROM history WHERE url LIKE ? GROUP BY url, title ORDER BY url ASC" bind:[NSArray arrayWithObjects:like, nil]];
        
        if ( 0 != [aryHistoryList count] ) {
            [historyTable setAryHistoryList:aryHistoryList];
            [historyTable.tableView reloadData];
            [historyTable.view setHidden:NO];
        } else {
            [historyTable.view setHidden:YES];
        }
    } else {
        [historyTable.view setHidden:YES];
    }
}

- (void)openAnotherMenu:(id)sender {
    anotherMenuViewController = [[AnotherMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
    anotherMenuViewController.isPurchase = isPurchased;
    anotherMenuViewController.delegate = self;
    
    [anotherMenuViewController setWebView:webView];
    DeviceViewController *deviceViewController = [[DeviceViewController alloc] initWithStyle:UITableViewStylePlain];
    deviceViewController.delegate = self;
    [anotherMenuViewController setDeviceViewController:deviceViewController];
    
    navigationController = [[WCNavigationController alloc] initWithRootViewController:anotherMenuViewController];
    
    [self presentModalViewController:navigationController animated:YES];
    [anotherMenuViewController release];
    [navigationController release];
}

- (void)doSelectDevice:(NSDictionary *)device {
    NSLog(@"selected:%@", device);
    if ( nil == device ) {
        [self changeWebviewSize:320.0f orientation:_interfaceOrientaion];
    } else {
        float width = [[device objectForKey:@"width"] floatValue];
        
        [self changeWebviewSize:width orientation:_interfaceOrientaion];
    }
    
    [navigationController dismissModalViewControllerAnimated:YES];
    
    [self reload:nil];
}

-(NSString *) setViewportWidth:(CGFloat)inWidth {
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"(function ( inWidth ) { "
            "var result = ''; "
            "var viewport = null; "
            "var content = 'width = ' + inWidth; "
            "var document_head = document.getElementsByTagName('head')[0]; "
            "var child = document_head.firstChild; "
            "while ( child ) { "
                "if ( null == viewport && child.nodeType == 1 && child.nodeName == 'META' && child.getAttribute( 'name' ) == 'viewport' ) { "
                    "viewport = child; "
                    "content = child.getAttribute( 'content' ); "
                    "if ( content.search( /width\\s=\\s[^,]+/ ) < 0 ) { "
                    "content = 'width = ' + inWidth + ', ' + content; "
                "} else { "
                    "content = content.replace( /width\\s=\\s[^,]+/ , 'width = ' + inWidth ); "
                "} "
            "} "
            "child = child.nextSibling; "
        "} "
        "if ( null != content ) { "
            "child = document.createElement( 'meta' ); "
            "child.setAttribute( 'name' , 'viewport' ); "
            "child.setAttribute( 'content' , content ); "
            "if ( null == viewport ) { "
                "document_head.appendChild( child ); "
                "result = 'append viewport ' + content; "
            "} else { "
                "document_head.replaceChild( child , viewport ); "
                "result = 'replace viewport ' + content; "
            "} "
        "} "
        "document.body.style.padding = '0px'; "
        "document.body.style.margin = '0px'; "
        "return result; "
    "})( %d )" , (int)inWidth]];
    
    return result;
}

- (void)dissmissModalAndReturnErrorUrlList:(NSArray *)url_list
{
    NSLog(@"errorList:%@", url_list);
    
    NSString *formatJs = @"var inArray = function(str, ary) { var i; for (i = 0; i < ary.length; i++) { if ( ary[i] ==str ) { return true; } } return false; }; var changeLinkColor = function() {var aryLinkList = document.getElementsByTagName('a'); var currentLink; var linkList = [%@]; for(var i = 0; i < aryLinkList.length; i++) { currentLink = aryLinkList[i]; if ( inArray(currentLink.href, linkList) ) { currentLink.style.border = '1px #FF0000 solid'; currentLink.style.padding = '5px'; currentLink.style.color = '#FF0000'; currentLink.style.fontWeight = 'bold'; currentLink.style.backgroundColor = '#FFCCCC'; } } }; changeLinkColor();";
    
    NSMutableArray *aryCheckUrlList = [[NSMutableArray alloc] init];
    
    int i;
    for (i = 0; i < url_list.count; i++) {
        NSString *currentUrl = [[url_list objectAtIndex:i]  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *replaceUrl = [currentUrl stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        
        [aryCheckUrlList addObject:[NSString stringWithFormat:@"'%@'", currentUrl]];
        [aryCheckUrlList addObject:[NSString stringWithFormat:@"'%@'", replaceUrl]];
    }
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:formatJs, [aryCheckUrlList componentsJoinedByString:@","]]];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)doSelectHistory:(NSString *)_url
{
    [url setText:_url];
    [self doAccess];
    
    [navigationController dismissModalViewControllerAnimated:YES];
    [navigationController release];
}

-(void)changeDisplaySize:(UIInterfaceOrientation)interfaceOrientation
{
    _interfaceOrientation = interfaceOrientation;
    
    if (UIInterfaceOrientationPortrait == interfaceOrientation)
    {
        barHeader.frame   = CGRectMake(0.0f, 0.0f, 320.0f, 44.0f);
        headerScrollView.frame = CGRectMake(0.0f, 0.0f, barHeader.frame.size.width, barHeader.frame.size.height);
        headerScrollView.contentSize = CGSizeMake(barHeader.frame.size.width * 2, barHeader.frame.size.height);
        
        url.frame         = CGRectMake(10.0f, 6.0f, 300.0f, 32.0f);
        //webView.frame     = CGRectMake(0.0f, 44.0f, 320.0f, 322.0f);
        barFooter.frame   = CGRectMake(0.0f, 416.0f, 320.0f, 44.0f);
        if ( NO == isPurchased ) {
            bannerView_.hidden = NO;
            bannerView_.frame = CGRectMake(0.0,
                                           webView.frame.origin.y + webView.frame.size.height,
                                           GAD_SIZE_320x50.width,
                                           GAD_SIZE_320x50.height);
        }
    } else if ( UIInterfaceOrientationLandscapeLeft == interfaceOrientation ) {
        barHeader.frame   = CGRectMake(0.0f, 0.0f, 480.f, 44.0f);
        headerScrollView.frame = CGRectMake(0.0f, 0.0f, barHeader.frame.size.width, barHeader.frame.size.height);
        headerScrollView.contentSize = CGSizeMake(barHeader.frame.size.width * 2, barHeader.frame.size.height);
        
        url.frame         = CGRectMake(10.0f, 6.0f, 460.0f, 32.0f);
        //webView.frame     = CGRectMake(0.0f, 44.0f, 480.0f, 212.0f);
        barFooter.frame   = CGRectMake(0.0f, 256.0f, 480.0f, 44.0f);
        if ( NO == isPurchased ) {
            bannerView_.hidden = YES;
            /*bannerView_.frame = CGRectMake((480.0f - GAD_SIZE_320x50.width) / 2,
             300.0f - 44.0f -
             GAD_SIZE_320x50.height,
             GAD_SIZE_320x50.width,
             GAD_SIZE_320x50.height);
             */
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *_device = [defaults objectForKey:@"VirtualDevice"];
    
    NSLog(@"_device:%@", _device);
    
    if ( nil != _device ) {
        [self changeWebviewSize:[[_device objectForKey:@"width"] floatValue] orientation:interfaceOrientation];
    } else {
        if ( UIInterfaceOrientationPortrait == interfaceOrientation ) {
            float webviewHeight = 322.0f;
            if ( YES == isPurchased ) {
                webviewHeight = webviewHeight + GAD_SIZE_320x50.height;
            }
            webView.frame = CGRectMake(0.0f, 44.0f, 320.0f, webviewHeight);
        } else if ( UIInterfaceOrientationLandscapeLeft == interfaceOrientation ) {
            webView.frame     = CGRectMake(0.0f, 44.0f, 480.0f, 212.0f);
        }
    }
    
    btn_back.frame = CGRectMake(headerScrollView.frame.size.width + 30.0f, btn_back.frame.origin.y, btn_back.frame.size.width, btn_back.frame.size.height);
    btn_forward.frame = CGRectMake(btn_back.frame.origin.x + btn_back.frame.size.width + 30.0f, btn_forward.frame.origin.y, btn_forward.frame.size.width, btn_forward.frame.size.height);
    btn_reload.frame = CGRectMake(btn_forward.frame.origin.x + btn_forward.frame.size.width + 30.0f, btn_reload.frame.origin.y, btn_reload.frame.size.width, btn_reload.frame.size.height);
    btn_stop.frame = CGRectMake(btn_reload.frame.origin.x + btn_reload.frame.size.width + 30.0f, btn_stop.frame.origin.y, btn_stop.frame.size.width, btn_stop.frame.size.height);
    btnShot.frame = CGRectMake((barFooter.frame.size.width / 2) - 40.0f, barFooter.frame.origin.y, 80.0f, 44.0f);
    
    btnAddFavorite.frame = CGRectMake(url.frame.size.width - 28.0f, 5.0f, 21.0f, 20.0f);
    
    historyTable.view.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, webView.frame.size.height);
}

- (void)changeWebviewSize:(float)width orientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"width:%f", width);
    if ( UIInterfaceOrientationPortrait == interfaceOrientation ) {
        float webViewHeight = 322.0f;
        if ( YES == isPurchased ) {
            webViewHeight = webViewHeight + GAD_SIZE_320x50.height;
        }
        
        if ( 320.0f <= width ) {
            webView.frame = CGRectMake(0.0f, 44.0f, 320.0f, webViewHeight);
        } else {
            webView.frame = CGRectMake((320.0f - width) / 2, 44.0f, width, webViewHeight);
        }
    } else if ( UIInterfaceOrientationLandscapeLeft == interfaceOrientation ) {
        if ( 480.0f <= width ) {
            webView.frame = CGRectMake(0.0f, 44.0f, 480.0f, 212.0f);
        } else {
            webView.frame = CGRectMake((480.0f - width) / 2, 44.0f, width, 212.0f);
        }
    }
}

- (void)scanBarcode:(id)sender
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    
    _qr_data = [symbol.data copy];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm", nil) message:[NSString stringWithFormat:@"Access to %@ ?", _qr_data] delegate:self cancelButtonTitle:NSLocalizedString(@"no", nil) otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
    alert.tag = 9;
    [alert show];
    [alert release];
}
                          
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (9 == alertView.tag) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                NSLog(@"%@", _qr_data);
                [url setText:_qr_data];
                [self doAccess];
                break;
        }

    }
}

- (void)urlDidSelected:(NSString *)_url {
    [url resignFirstResponder];
    
    [historyTable.view setHidden:YES];
    [url setText:_url];
    [self doAccess];
}

- (void)checkButtons {
    if ( NO == [webView canGoBack] ) {
        [btn_back setEnabled:NO];
    } else {
        [btn_back setEnabled:YES];
    }
    
    if ( NO == [webView canGoForward] ) {
        [btn_forward setEnabled:NO];
    } else {
        [btn_forward setEnabled:YES];
    }
}

- (void)back:(id)sender {
    [webView goBack];
    
    [self checkButtons];
}

- (void)forward:(id)sender {
    [webView goForward];
    
    [self checkButtons];
}

- (void)reload:(id)sender {
    [webView reload];
}

- (void)stop:(id)sender {
    [webView stopLoading];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [historyTable.view setHidden:YES];
    
    [textField resignFirstResponder];
    
    [self doAccess];
        
    return YES;
}

- (void)doAccess {
    NSError *errUrl = nil;
    NSRegularExpression *regUrl = [NSRegularExpression regularExpressionWithPattern:@"^https?://[a-zA-Z0-9]+.*?$" options:0 error:&errUrl];
    
    if ( nil != errUrl ) {
        NSLog(@"%@", errUrl);
    } else {
        NSTextCheckingResult *matchUrl = [regUrl firstMatchInString:[url text] options:0 range:NSMakeRange(0, [[url text] length])];
        
        if ( !matchUrl.numberOfRanges ) {
            
            NSError *errReg = nil;
            NSRegularExpression *regValidate = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9\\.\\-_#&\\?/=%!@]+$" options:0 error:&errReg];
            
            if ( nil != errReg ) {
                NSLog(@"%@", errReg);
            } else {
                NSRange searchResult = [[url text] rangeOfString:@"."];
                
                NSTextCheckingResult *matchValidate = [regValidate firstMatchInString:[url text] options:0 range:NSMakeRange(0, [[url text] length])];
                if ( !matchValidate.numberOfRanges || searchResult.location == NSNotFound ) {
                    NSString *keyword = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes
                    (NULL, (__bridge CFStringRef)url.text, NULL, NULL, kCFStringEncodingUTF8);
                    
                    [url setText:[NSString stringWithFormat:@"http://www.google.com/search?q=%@", keyword]];
                } else {
                    [url setText:[NSString stringWithFormat:@"http://%@", [url text]]];
                }
            }
        }
        NSURL *defaultUrl = [NSURL URLWithString:url.text];
        NSURLRequest *req = [NSURLRequest requestWithURL:defaultUrl];
        
        [webView loadRequest:req];
    }

}

- (void)tappedBtnShot:(id)sender
{
    if ( 0 != fittingSize.width && 0 != fittingSize.height ) {
        if ( _interfaceOrientation == UIInterfaceOrientationPortrait ) {
            shutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
            
        } else if ( _interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
            shutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 480.0f, 320.0f)];            
        }
        shutterView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0f];
        [self.view addSubview:shutterView];
        
        [UIView beginAnimations:@"shutter" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDelay:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(takeCapture:)];
        [shutterView setAlpha:0.0f];
        [UIView commitAnimations];
        
        /*
        UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
        */
    } else {
        NSLog(@"NG");
    }
}

- (void)takeCapture:(id)sender
{
    [shutterView removeFromSuperview];
    
    baseFrame = webView.frame;
    
    fittingSize = [webView sizeThatFits:CGSizeZero];
    
    webView.frame = CGRectMake(0.0f, 44.0f, fittingSize.width, fittingSize.height);
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, fittingSize.width, fittingSize.height)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ( nil == [defaults objectForKey:@"VirtualDevice"] ) {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 0);
    } else {
        UIGraphicsBeginImageContext(imageView.bounds.size);
    }
    
    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    ShareViewController *shareViewController = [[ShareViewController alloc] init];
    shareViewController.currentUrl = webView.request.URL;
    [shareViewController setPreviewImage:imageView];
    
    WCNavigationController *navViewController = [[WCNavigationController alloc] initWithRootViewController:shareViewController];
    
    [self presentModalViewController:navViewController animated:YES];
    [shareViewController release];
    [navViewController release];
    
    webView.frame = baseFrame;
}

// 完了を知らせるメソッド
/*
- (void) savingImageIsFinished:(UIImage *)_image
      didFinishSavingWithError:(NSError *)_error
                   contextInfo:(void *)_contextInfo
{
    bgLoadingView.hidden = YES;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"save", nil) message:NSLocalizedString(@"CompleteSaveCapture", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:nil, nil];
    [alert show];
    
    webView.frame = baseFrame;
}
*/

- (BOOL)in_array:(NSString *)search from:(NSArray *)from {
    int i;
    for (i = 0; i < from.count; i++) {
        if ( [[from objectAtIndex:i] isEqualToString:search] ) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {    
    NSLog(@"shouldStartLoadWithRequest");
    NSLog(@"%@", request.URL.scheme);
    
    if ( NO == [[request.URL scheme] isEqualToString:@"http"] && NO == [[request.URL scheme] isEqualToString:@"https"] ) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    return YES;
}

//-(void)basicAuthDidEntered:(NSString *)user_id passwd:(NSString *)passwd {
//    [historyTable.view setHidden:YES];
//     
//    NSString *currentUrl = [url text];
//    NSArray *aryUrl = [currentUrl componentsSeparatedByString:@"://"];
//    
//    if ( 2 == [aryUrl count] ) {
//        NSString *at = @"@";
//        NSString *newUrl = [NSString stringWithFormat:@"%@://%@:%@%@%@", [aryUrl objectAtIndex:0], user_id, passwd, at, [aryUrl objectAtIndex:1]];
//        
//        [url setText:newUrl];
//        [self doAccess];
//    }
//    
//    [navigationController dismissModalViewControllerAnimated:YES];
//}

//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    NSLog(@"%@", [challenge description]);
//    
//    basicAuthViewController = [[BasicAuthModalViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    basicAuthViewController.delegate = self;
//    navigationController = [[UINavigationController alloc] initWithRootViewController:basicAuthViewController];
//    
//    [self presentModalViewController:navigationController animated:YES];
//}

- (void)webViewDidStartLoad:(UIWebView *)_webView {
    NSLog(@"webViewDidStartLoad");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [btn_stop setEnabled:YES];
    [btn_reload setEnabled:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    NSLog(@"webViewDidFinishLoad");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [btn_stop setEnabled:NO];
    [btn_reload setEnabled:YES];
    
    [self checkButtons];
    
    fittingSize = [_webView sizeThatFits:CGSizeZero];
    
    NSURLRequest *_req = [_webView request];
    
    [url setText:[NSString stringWithFormat:@"%@", [_req URL]]];
    
    [btnAddFavorite changeHas:[self hasBookmark]];
    
    Common *common = [Common sharedManager];
    [common.dao setTable:@"history"];
    NSArray *lastHistory = [common.dao get:@"SELECT url FROM history ORDER BY id DESC LIMIT 1" bind:nil];
    if ( 0 == lastHistory.count || ![[[lastHistory objectAtIndex:0] objectForKey:@"url"] isEqualToString:[url text]] ) {
        NSDictionary *saveHistory = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [webView stringByEvaluatingJavaScriptFromString:@"document.title"], @"title",
                                         [url text], @"url",
                                         [NSString stringWithFormat:@"%@", [NSDate date]], @"date"
                                         , nil];
            
        [common.dao insert:saveHistory];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *_device = [defaults objectForKey:@"VirtualDevice"];
    
    if ( nil != _device ) {
        [self setViewportWidth:[[_device objectForKey:@"width"] floatValue]];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError");
    NSInteger err_code = [error code];
    NSLog(@"err_code:%d", err_code);
	if (err_code == NSURLErrorCancelled) {
		return;
	}
    
    if([[error domain]isEqual:NSURLErrorDomain]) {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:[error localizedDescription]
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    BOOL result = (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
                   || interfaceOrientation == UIInterfaceOrientationPortrait);
    
    if ( YES == result ) {
        [self changeDisplaySize:interfaceOrientation];
    }
    
    return result;
}

@end
