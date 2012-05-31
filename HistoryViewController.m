//
//  HistoryViewController.m
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"


@implementation HistoryViewController

#define MODE_MAIN 0
#define MODE_ANOTHER 1

@synthesize delegate;
@synthesize aryHistoryList;
@synthesize aryDateList;
@synthesize dicDateHistory;
@synthesize totalCount;
@synthesize btnReset;
@synthesize mode;

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    
    [aryDateList release];
    [dicDateHistory release];
    [btnReset release];
    
    delegate = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setTitle:NSLocalizedString(@"ReadHistory", nil)];
    }
    
    return self;
}

- (void)doReset:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm", nil) message:NSLocalizedString(@"ReallyReset", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"no", nil) otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Common *common = [Common sharedManager];
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [common.dao get:@"DELETE FROM history" bind:nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"result", nil) message:NSLocalizedString(@"ResetComplete", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:nil, nil];
            [alert show];
            
            [self viewWillAppear:YES];
            break;
    }
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)close {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self.parentViewController release];
}

- (BOOL)in_array:(NSString *)search from:(NSArray *)from {
    int i;
    for (i = 0; i < from.count; i++) {
        if ( [[from objectAtIndex:i] isEqualToString:search] ) {
            return YES;
        }
    }
    
    return NO;
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
    
    btnReset = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"reset", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doReset:)];
    
    if ( MODE_ANOTHER == mode ) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = btnReset;
    } else {
        self.navigationItem.leftBarButtonItem = btnReset;
        
        UIBarButtonItem *btn_close = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(close)];
        self.navigationItem.rightBarButtonItem = btn_close;
    }
    
    Common *common = [Common sharedManager];
    [common.dao setTable:@"history"];

    aryHistoryList = [common.dao get:@"SELECT * FROM history ORDER BY id DESC" bind:nil];
    
    aryDateList = [[NSMutableArray alloc] init];
    dicDateHistory = [[NSMutableDictionary alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
    [formatter setLocale:locale];
    
    NSString *currentDate;
    
    int i;
    for (i = 0; i < aryHistoryList.count; i++) {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        NSDate *date = [formatter dateFromString:[[aryHistoryList objectAtIndex:i] objectForKey:@"date"]];
        
        [formatter setDateFormat:@"yyyy/MM/dd"];
        currentDate = [formatter stringFromDate:date];
        
        if ( NO == [self in_array:currentDate from:aryDateList] ) {
            [aryDateList addObject:currentDate];
        }
        
        if (nil == [dicDateHistory objectForKey:currentDate]) {
            [dicDateHistory setValue:[[NSMutableArray alloc] init] forKey:currentDate];
        }
        
        [[dicDateHistory objectForKey:currentDate] addObject:[aryHistoryList objectAtIndex:i]];
    }
    [formatter release];

    [self.tableView reloadData];
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait
            || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [aryDateList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dicDateHistory objectForKey:[aryDateList objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *currentHistory = [[dicDateHistory objectForKey:[aryDateList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [currentHistory objectForKey:@"title"];
    cell.detailTextLabel.text = [currentHistory objectForKey:@"url"];
    cell.tag = [[currentHistory objectForKey:@"id"] intValue];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [aryDateList objectAtIndex:section];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        Common *common = [Common sharedManager];
        
        NSDictionary *currentHistory = [[dicDateHistory objectForKey:[aryDateList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [common.dao get:[NSString stringWithFormat:@"DELETE FROM history WHERE id = %@", [currentHistory objectForKey:@"id"]] bind:nil];
        
        [[dicDateHistory objectForKey:[aryDateList objectAtIndex:indexPath.section]] removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *currentHistory = [[dicDateHistory objectForKey:[aryDateList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    [delegate doSelectHistory:[currentHistory objectForKey:@"url"]];
}

@end
