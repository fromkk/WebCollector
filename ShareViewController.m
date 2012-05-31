//
//  ShareViewController.m
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/08.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import "AppDelegate.h"
#import "EvernoteSDK.h"

@implementation ShareViewController

@synthesize previewView;
@synthesize previewImage;
@synthesize barBgButtons;
@synthesize btnSaveAlbum;
@synthesize btnSendEmail;
@synthesize btnShareTwitter;
@synthesize tweetViewController;
@synthesize btnClose;
@synthesize mailPicker;
@synthesize _loadingBgView;
@synthesize _spinner;
@synthesize _interfaceOrientation;
@synthesize btnShareFb;
@synthesize facebook;
@synthesize fbComment;
@synthesize btnFbPost;
@synthesize _fbBgView;
@synthesize actionSheet;
@synthesize indexAlbum;
@synthesize indexMail;
@synthesize indexFacebook;
@synthesize indexEvernote;
@synthesize indexTwitter;
@synthesize indexClose;
@synthesize currentUrl;

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    
    [previewView release];
    [previewImage release];
    [barBgButtons release];
    [tweetViewController release];
    [btnClose release];
    [mailPicker release];
    [_loadingBgView release];
    [_spinner release];
    [fbComment release];
    [_fbBgView release];
    [actionSheet release];
    
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"preview", nil)];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    btnClose = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"close", nil) style:UIBarButtonItemStylePlain 
                                                     target:self action:@selector(closeModalView:)];
    UIBarButtonItem *btnShare = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(tappedBtnShare:)];
    
    self.navigationItem.leftBarButtonItem = btnClose;
    self.navigationItem.rightBarButtonItem = btnShare;
    [btnShare release];
    
    if ( nil != previewImage ) {
        previewView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 188.0f)];
        previewView.scrollEnabled = YES;
        previewView.alwaysBounceHorizontal = YES;
        previewView.alwaysBounceVertical = YES;
        previewView.contentSize = previewImage.image.size;
        [previewView addSubview:previewImage];
        
        [self.view addSubview:previewView];
        
        actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        [actionSheet addButtonWithTitle:NSLocalizedString(@"SaveAlbum", nil)];
        indexAlbum = 0;
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"SendEmail", nil)];
        indexMail = 1;
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"ShareFacebook", nil)];
        indexFacebook = 2;
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"SaveEvernote", nil)];
        indexEvernote = 3;
        
        if ( 5.0 <= [[[UIDevice currentDevice] systemVersion] floatValue] ) {
            [actionSheet addButtonWithTitle:NSLocalizedString(@"ShareTwitter", nil)];
            indexTwitter = 4;
            
            indexClose = 5;
        } else {
            indexClose = 4;
        }
        [actionSheet addButtonWithTitle:NSLocalizedString(@"close", nil)];
        [actionSheet setCancelButtonIndex:indexClose];
        
        /*
        barBgButtons = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 188.0f, 320.0f, 228.0f)];
        barBgButtons.barStyle = UIBarStyleBlack;
        
        btnSaveAlbum = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btnSaveAlbum setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnSaveAlbum setTitle:NSLocalizedString(@"SaveAlbum", nil) forState:UIControlStateNormal];
        [btnSaveAlbum setTintColor:[UIColor whiteColor]];
        btnSaveAlbum.frame = CGRectMake(30.0f, 10.0f, 260.0f, 40.0f);
        [btnSaveAlbum addTarget:self action:@selector(saveAlbum:) forControlEvents:UIControlEventTouchDown];
        
        [barBgButtons addSubview:btnSaveAlbum];
        
        btnSendEmail = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btnSendEmail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnSendEmail setTitle:NSLocalizedString(@"SendEmail", nil) forState:UIControlStateNormal];
        [btnSendEmail setTintColor:[UIColor whiteColor]];
        btnSendEmail.frame = CGRectMake(30.0f, 60.0f, 260.0f, 40.0f);
        [btnSendEmail addTarget:self action:@selector(sendEmail:) forControlEvents:UIControlEventTouchDown];
        
        [barBgButtons addSubview:btnSendEmail];
        
        btnShareFb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btnShareFb setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnShareFb setTitle:NSLocalizedString(@"ShareFacebook", nil) forState:UIControlStateNormal];
        [btnShareFb setTintColor:[UIColor whiteColor]];
        [btnShareFb setFrame:CGRectMake(30.0f, 110.0, 260.0f, 40.0f)];
        [btnShareFb addTarget:self action:@selector(shareFb:) forControlEvents:UIControlEventTouchUpInside];
        [barBgButtons addSubview:btnShareFb];
        
        [self.view addSubview:barBgButtons];
        if ( 5.0 <= [[[UIDevice currentDevice] systemVersion] floatValue] ) {
            btnShareTwitter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btnShareTwitter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnShareTwitter setTitle:@"Share on Twitter" forState:UIControlStateNormal];
            [btnShareTwitter setTintColor:[UIColor whiteColor]];
            btnShareTwitter.frame = CGRectMake(30.0f, 160.0f, 260.0f, 44.0f);
            [btnShareTwitter addTarget:self action:@selector(shareTwitter:) forControlEvents:UIControlEventTouchDown];
            
            [barBgButtons addSubview:btnShareTwitter];
        }
        */
         
        _fbBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
        _fbBgView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
        _fbBgView.hidden = YES;
        [self.view addSubview:_fbBgView];
        
        fbComment = [[UITextView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 310.0f, 100.0f)];
        fbComment.layer.cornerRadius = 6.0f;
        fbComment.contentInset = UIEdgeInsetsMake(5,5,5,5);
        fbComment.hidden = YES;
        [self.view addSubview:fbComment];
        
        btnFbPost = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btnFbPost setFrame:CGRectMake(10.0f, 115.0f, 300.0f, 44.0f)];
        [btnFbPost setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnFbPost setTintColor:[UIColor whiteColor]];
        [btnFbPost setTitle:@"Post to Facebook" forState:UIControlStateNormal];
        [btnFbPost addTarget:self action:@selector(postToFb:) forControlEvents:UIControlEventTouchUpInside];
        [btnFbPost setHidden:YES];
        [self.view addSubview:btnFbPost];
        
        _loadingBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
        _loadingBgView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
        _loadingBgView.hidden = YES;
        [self.view addSubview:_loadingBgView];
        
        _spinner       = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_spinner setHidesWhenStopped:YES];
        [_spinner stopAnimating];
        [self.view addSubview:_spinner];
    } else {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == indexClose ) {
        return;
    }
    
    if ( indexAlbum == buttonIndex ) {
        [self saveAlbum:nil];
    } else if ( indexMail == buttonIndex ) {
        [self sendEmail:nil];
    } else if ( indexFacebook == buttonIndex ) {
        [self shareFb:nil];
    } else if ( indexEvernote == buttonIndex ) {
        [self saveEvernote:nil];
    } else if ( indexTwitter == buttonIndex ) {
        [self shareTwitter:nil];
    }
}

- (void)tappedBtnShare:(UIBarButtonItem *)btn {
    [actionSheet showInView:self.view];
}

-(void)changeDisplaySize:(UIInterfaceOrientation)interfaceOrientation
{
    _interfaceOrientation = interfaceOrientation;

    if (UIInterfaceOrientationPortrait == interfaceOrientation)
    {
        previewView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 416.0f);
        barBgButtons.frame = CGRectMake(0.0f, 188.0f, 320.0f, 228.0f);
        btnSaveAlbum.frame = CGRectMake(30.0f, 10.0f, 260.0f, 40.0f);
        btnSendEmail.frame = CGRectMake(30.0f, 60.0f, 260.0f, 40.0f);
        btnShareFb.frame   = CGRectMake(30.0f, 110.0f, 260.0f, 40.0f);
        
        if ( 5.0 <= [[[UIDevice currentDevice] systemVersion] floatValue] ) {
            btnShareTwitter.frame = CGRectMake(30.0f, 160.0f, 260.0f, 40.0f);
        }
        
        _loadingBgView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
        _spinner.frame       = CGRectMake(120.0f, 200.0f, 80.0f, 80.0f);
        
        fbComment.frame = CGRectMake(5.0f, 5.0f, 310.0f, 100.0f);
        btnFbPost.frame = CGRectMake(10.0f, 115.0f, 300.0f, 44.0f);
        _fbBgView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    } else if ( UIInterfaceOrientationLandscapeLeft == interfaceOrientation ) {                previewView.frame = CGRectMake(0.0f, 0.0f, 480.0f, 256.0f);
        barBgButtons.frame = CGRectMake(0.0f, 114.0f, 480.0f, 154.0f);
        btnSaveAlbum.frame = CGRectMake(30.0f, 10.0f, 420.0f, 30.0f);
        btnSendEmail.frame = CGRectMake(30.0f, 45.0f, 420.0f, 30.0f);
        btnShareFb.frame = CGRectMake(30.0f, 80.0f, 420.0f, 30.0f);
        if ( 5.0 <= [[[UIDevice currentDevice] systemVersion] floatValue] ) {                        btnShareTwitter.frame = CGRectMake(30.0f, 115.0f, 420.0f, 30.0f);
        }
        
        _loadingBgView.frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
        _spinner.frame       = CGRectMake(200.0f, 120.0f, 80.0f, 80.0f);
        
        fbComment.frame = CGRectMake(5.0f, 5.0f, 310.0f, 95.0f);
        btnFbPost.frame = CGRectMake(320.0f, 10.0f, 160.0f, 80.0f);
        _fbBgView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)saveEvernote:(id)sender {
    NSLog(@"%s", __FUNCTION__);
 
    EvernoteSession *session = [EvernoteSession sharedSession];
    if (! session.isAuthenticated) {
        [session authenticateWithCompletionHandler:^(NSError *error) {
            if (error || !session.isAuthenticated) {
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) 
                                                                 message:@"Could not authenticate" 
                                                                delegate:nil 
                                                       cancelButtonTitle:@"OK" 
                                                       otherButtonTitles:nil] autorelease];
                [alert show];
            } else {
                [self showEvernoteView];
            } 
        }];
    } else {
        [self showEvernoteView];
    }
}

- (void)showEvernoteView {
    SaveEvernoteViewController *evernoteView = [[SaveEvernoteViewController alloc] init];
    evernoteView.postImage = previewImage.image;
    evernoteView.currentUrl = currentUrl;
    [self.navigationController pushViewController:evernoteView animated:YES];
    [evernoteView release];
}

- (void)shareTwitter:(id)sender {
    tweetViewController = [[TWTweetComposeViewController alloc] init];
    tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult res) {
        [self dismissModalViewControllerAnimated:YES];
    };
    
    [self dispTweetView];
}

- (void)shareFb:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    facebook = delegate.facebook;
    [delegate setDelegate:self];
    
    if ( ! [facebook isSessionValid] ) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"publish_stream",
                                nil];
        [facebook authorize:permissions];
    } else {
        NSLog(@"%s", __FUNCTION__);
        [self logginedFb:nil];
    }
}

- (void)logginedFb:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    fbComment.alpha = 0.0f;
    fbComment.hidden = NO;
    [fbComment becomeFirstResponder];
    
    btnFbPost.alpha = 0.0f;
    btnFbPost.hidden = NO;
    
    _fbBgView.alpha = 0.0f;
    _fbBgView.hidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        _fbBgView.alpha = 1.0f;
        btnFbPost.alpha = 1.0f;
        fbComment.alpha = 1.0f;
    }];
}

- (void)postToFb:(id)sender {
    [fbComment resignFirstResponder];
    _loadingBgView.hidden = NO;
    [_spinner startAnimating];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   previewImage.image, @"picture",
                                   fbComment.text, @"caption",
                                   nil];
    [facebook requestWithMethodName:@"photos.upload"
                          andParams:params
                      andHttpMethod:@"POST"
                        andDelegate:self];
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"received response");
};

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	if ([result objectForKey:@"owner"]) {
        [fbComment setText:@""];
        btnFbPost.hidden = YES;
        _fbBgView.hidden = YES;
        fbComment.hidden = YES;
        _loadingBgView.hidden = YES;
        [_spinner stopAnimating];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Photo upload success!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
		NSLog(@"Photo upload Success");
	} else {
		NSLog(@"result name:%@",[result objectForKey:@"name"]);
	}
};

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Photo upload error!!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    [alert show];
    
    [fbComment setText:@""];
    btnFbPost.hidden = YES;
    _fbBgView.hidden = YES;
    fbComment.hidden = YES;
    _loadingBgView.hidden = YES;
    [_spinner stopAnimating];
	NSLog(@"didFailWithError:");
};

-(void)sendEmail:(id)sender {
    mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    NSData *attachData = UIImagePNGRepresentation(previewImage.image);
    [mailPicker addAttachmentData:attachData
                         mimeType:@"image/png"
                         fileName:@"scshot"];				
    [self presentModalViewController:mailPicker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
    [mailPicker dismissModalViewControllerAnimated:YES];
}

- (void)dispTweetView {
    [tweetViewController addImage:previewImage.image];
    [tweetViewController addURL:currentUrl];
    
    [self presentModalViewController:tweetViewController animated:YES];
}

-(void)saveAlbum:(id)sender
{
    _loadingBgView.hidden = NO;
    [_spinner startAnimating];
    
    UIImageWriteToSavedPhotosAlbum(previewImage.image, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
}

- (void) savingImageIsFinished:(UIImage *)_image
      didFinishSavingWithError:(NSError *)_error
                   contextInfo:(void *)_contextInfo
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"save", nil) message:NSLocalizedString(@"CompleteSaveCapture", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:nil, nil];
    [alert show];
    
    _loadingBgView.hidden = YES;
    [_spinner stopAnimating];
}

- (void)closeModalView:(id)sender
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    BOOL result = (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
                   || interfaceOrientation == UIInterfaceOrientationPortrait);
    
    if ( YES == result ) {
        [self changeDisplaySize:interfaceOrientation];
    }
    
    return result;
}

@end
