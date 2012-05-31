//
//  SaveEvernoteViewController.m
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/05/09.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import "SaveEvernoteViewController.h"
#import "EvernoteSDK.h"

@interface SaveEvernoteViewController ()

@end

@implementation SaveEvernoteViewController

@synthesize tableView;
@synthesize noteName;
@synthesize noteDetail;
@synthesize _loading_bg;
@synthesize _indicator;
@synthesize btn_keyboard;
@synthesize postImage;
@synthesize noteStore;
@synthesize currentUrl;

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    
    [tableView release];
    [noteName release];
    [noteDetail release];
    [_loading_bg release];
    [_indicator release];
    [btn_keyboard release];
    [noteStore release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SaveEvernote", nil);
    
    UIBarButtonItem *btn_back = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(tappedBtnBack:)];
    self.navigationItem.leftBarButtonItem = btn_back;
    [btn_back release];
    
    UIBarButtonItem *btn_save = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(tappedBtnSave:)];
    self.navigationItem.rightBarButtonItem = btn_save;
    [btn_save release];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    _loading_bg = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    _loading_bg.backgroundColor = [UIColor blackColor];
    _loading_bg.alpha = 0.5f;
    _loading_bg.hidden = YES;
    [self.view addSubview:_loading_bg];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.view addSubview:_indicator];
    
    btn_keyboard = [[UIButton alloc] initWithFrame:CGRectMake(240.0f, 130.0f, 60.0f, 23.0f)];
    [btn_keyboard setImage:[UIImage imageNamed:@"keyboard.png"] forState:UIControlStateNormal];
    [btn_keyboard addTarget:self action:@selector(tappedBtnKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    btn_keyboard.hidden = YES;
    [self.view addSubview:btn_keyboard];
    
    noteStore = [[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    btn_keyboard.hidden = NO;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    btn_keyboard.hidden = YES;
    
    return YES;
}

- (void)tappedBtnBack:(UIBarButtonItem *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tappedBtnSave:(UIBarButtonItem *)btn {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    _loading_bg.hidden = NO;
    [_indicator startAnimating];
    
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks){
        EDAMNotebook *defaultNoteBook;
        EDAMNotebook *notebook;
        for (int i = 0; i < notebooks.count; i++) {
            notebook = [notebooks objectAtIndex:i];
            if ( [notebook defaultNotebook] ) {
                defaultNoteBook = notebook;
            }
        }
        
     [self executeSaveImages:defaultNoteBook];
    } failure:^(NSError *error){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"EvernoteSaveError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        NSLog(@"error:%@", error);
    }];
}

- (void)executeSaveImages:(EDAMNotebook *)notebook {
    NSData* pngData = [[[NSData alloc] initWithData:UIImagePNGRepresentation( postImage )] autorelease];
    NSString *hash = [pngData MD5];
    
    EDAMResource *resource = [[[EDAMResource alloc] init] autorelease];
    EDAMData *data = [[EDAMData alloc] initWithBodyHash:pngData size:[pngData length] body:pngData];
    [resource setData:data];
    [resource setRecognition:data];
    NSString *mime = [[[NSString alloc] initWithString:@"image/png"] autorelease];
    [resource setMime:mime];
    NSArray *imageArray = [NSArray arrayWithObject:resource];
    
    EDAMNote *note = [[[EDAMNote alloc] init] autorelease];
    [note setNotebookGuid:[notebook guid]];
    [note setTitle:[noteName text]];
    NSMutableString* contentString = [[[NSMutableString alloc] init] autorelease];
    [contentString setString:	@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
    [contentString appendString:@"<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml.dtd\">"];
    [contentString appendString:@"<en-note>"];
    [contentString appendFormat:@"%@<br />", [noteDetail.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"]];
    [contentString appendFormat:@"<a href=\"%@\">%@</a><br />", currentUrl.description, currentUrl.description];
    [contentString appendFormat:@"<en-media title=\"%@\" alt=\"%@\" type=\"image/png\" hash=\"%@\"/>", noteName.text, noteName.text, hash];
    [contentString appendString:@"</en-note>"];
    [note setContent:contentString];
    [note setResources:imageArray];
    
    EDAMNoteAttributes *attributes = [[EDAMNoteAttributes alloc] init];
    [attributes setSourceURL:currentUrl.description];
    [note setAttributes:attributes];
    
    [note setCreated:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
    [noteStore createNote:note success:^(NSString *note) {
        NSLog(@"%@", note);
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self._loading_bg.hidden = YES;
        [self._indicator stopAnimating];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"complete", nil) message:NSLocalizedString(@"SaveEvernoteComplete", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1;
        [alert show];
        [alert release];
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"EvernoteSaveError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        NSLog(@"%@", error);
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( 1 == alertView.tag ) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tappedBtnKeyboard:(UIButton *)btn {
    [noteDetail resignFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ( 0 == indexPath.row ) {
        noteName = [[UITextField alloc] initWithFrame:CGRectMake(5.0f, 5.0f, cell.frame.size.width - 10.0f, cell.frame.size.height - 10.0f)];
        noteName.delegate = self;
        [noteName setPlaceholder:@"Note"];
        [noteName setReturnKeyType:UIReturnKeyDone];
        [cell addSubview:noteName];
    } else if ( 1 == indexPath.row ) {
        noteDetail = [[UITextView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, cell.frame.size.width - 10.0f, 100.0f)];
        noteDetail.delegate = self;
        [cell addSubview:noteDetail];
    }
    
    // Configure the cell...
    
    return cell;
}

- (float)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 44.0f;
    if ( 1 == indexPath.row ) {
        height = 372.0f;
    }
    
    return height;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
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

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
