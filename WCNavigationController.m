//
//  WCNavigationController.m
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/03/27.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import "WCNavigationController.h"

@interface WCNavigationController ()

@end

@implementation WCNavigationController

@synthesize bgImage;
@synthesize bgImageView;

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bgImage = [UIImage imageNamed:@"bg_toolbar.png"];
    if ( 5.0f <= [[[UIDevice currentDevice] systemVersion] floatValue] ) {
        [self.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    } else {
        bgImage = [bgImage
                 stretchableImageWithLeftCapWidth:0 topCapHeight:1];
        bgImageView = [[UIImageView alloc] initWithImage:bgImage];
        bgImageView.frame = self.navigationBar.bounds;
        bgImageView.autoresizingMask = (
                                      UIViewAutoresizingFlexibleWidth
                                      | UIViewAutoresizingFlexibleHeight);
        [self.navigationBar insertSubview:bgImageView atIndex:0];
        [bgImageView release];
    }
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
