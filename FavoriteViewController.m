//
//  FavoriteViewController.m
//  longScreenCapture
//
//  Created by 植岡 和哉 on 12/03/27.
//  Copyright (c) 2012年 株式会社エージェント・テクノロジー・グローバル・ソリューションズ. All rights reserved.
//

#import "FavoriteViewController.h"

@interface FavoriteViewController ()

@end

@implementation FavoriteViewController

@synthesize aryFavorite;
@synthesize delegate;

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    
    delegate = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        aryFavorite = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"favorites", nil);
    
    UIBarButtonItem *btn_close = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = btn_close;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    Common *common = [Common sharedManager];
    [common.dao setTable:@"favorites"];
    
    aryFavorite = [[common.dao get:@"SELECT * FROM favorites ORDER BY id DESC" bind:nil] mutableCopy];
    [self.tableView reloadData];
}

- (void)close {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self.parentViewController release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait
                   || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
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
    return [aryFavorite count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( nil == cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[aryFavorite objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.detailTextLabel.text = [[aryFavorite objectAtIndex:indexPath.row] objectForKey:@"url"];
    cell.tag = [[[aryFavorite objectAtIndex:indexPath.row] objectForKey:@"id"] intValue];
    
    return cell;
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
        [common.dao setTable:@"favorites"];
        [common.dao get:@"DELETE FROM favorites WHERE id = ?" bind:[NSArray arrayWithObject:[[aryFavorite objectAtIndex:indexPath.row] objectForKey:@"id"]]];
        
        [aryFavorite removeObjectAtIndex:indexPath.row];
        
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *currentFavorite = [aryFavorite objectAtIndex:indexPath.row];
    
    [delegate doSelectFavorite:[currentFavorite objectForKey:@"url"]];
}

@end
