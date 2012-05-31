//
//  AppDelegate.m
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/07.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "EvernoteSDK.h"

NSString *productId = @"jp.fromkk.webcollector.hideads";

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize mainViewController;
@synthesize facebook;
@synthesize delegate;

static NSString *FACEBOOK_APPID = @"320094701373274";

- (void)dealloc {
    [mainViewController release];
    [facebook release];
    delegate = nil;
    
    [_window release];
    [__managedObjectModel release];
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    mainViewController = [[MainViewController alloc] init];
    facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APPID andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    // Initial development is done on the sandbox service
    // Change this to @"www.evernote.com" to use the production Evernote service
    //NSString *EVERNOTE_HOST = @"sandbox.evernote.com";
    NSString *EVERNOTE_HOST = @"www.evernote.com";
    
    // Fill in the consumer key and secret with the values that you received from Evernote
    // To get an API key, visit http://dev.evernote.com/documentation/cloud/
    NSString *CONSUMER_KEY = @"webcollector";
    NSString *CONSUMER_SECRET = @"e18d89982c2a45c7";
    
    // set up Evernote session singleton
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST 
                              consumerKey:CONSUMER_KEY 
                           consumerSecret:CONSUMER_SECRET];
    
    NSBundle *bundle;
    NSString *path;
    Common *common = [Common sharedManager];
    [common.dao setTable:@"sqlite_master"];
    NSUserDefaults *_def = [NSUserDefaults standardUserDefaults];
    if (nil == [_def objectForKey:@"wc_db_version"]) {
        [common.dao setTable:@"favorites"];
        [common.dao get:@"CREATE TABLE favorites (id INTEGER PRIMARY KEY, title TEXT, url TEXT, created TEXT);" bind:nil];
        [_def setValue:@"1.1" forKey:@"wc_db_version"];
        
        bundle = [NSBundle mainBundle];
        path = [bundle pathForResource:@"DefaultBookmark" ofType:@"plist"];
        
        if ( nil != path ) {
            NSArray *aryDefaultBookmark = [NSArray arrayWithContentsOfFile:path];
            
            for (int i = 0; i< aryDefaultBookmark.count; i++) {
                NSDictionary *insert = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [[aryDefaultBookmark objectAtIndex:i] objectForKey:@"title"], @"title",
                                        [[aryDefaultBookmark objectAtIndex:i] objectForKey:@"url"], @"url",
                                        [NSString stringWithFormat:@"%@", [NSDate date]], @"created",
                                        nil];
                [common.dao insert:insert];
            }
        }
    }
    
    if ( [[_def objectForKey:@"wc_db_version"] isEqualToString:@"1.1"] ) {
        NSLog(@"db_ver_1.1");
        [common.dao setTable:@"devices"];
        [common.dao get:@"CREATE TABLE devices ( id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, carrier TEXT, ua TEXT, width INTEGER);" bind:nil];
        NSLog(@"create devices");
        
        [_def setObject:@"1.2" forKey:@"wc_db_version"];
        
        bundle = [NSBundle mainBundle];
        path = [bundle pathForResource:@"VirtualDeviceList" ofType:@"plist"];
        if ( path ) {
            NSArray *aryDevices = [[NSArray arrayWithContentsOfFile:path] mutableCopy];
            
            NSDictionary *insertDevice;
            NSDictionary *currentDevice;
            for (int i = 0; i < aryDevices.count; i++) {
                currentDevice = [aryDevices objectAtIndex:i];
                insertDevice = [NSDictionary dictionaryWithObjectsAndKeys:
                                [currentDevice objectForKey:@"name"], @"name",
                                [currentDevice objectForKey:@"carrier"], @"carrier",
                                [currentDevice objectForKey:@"ua"], @"ua",
                                [NSString stringWithFormat:@"%@", [currentDevice objectForKey:@"width"]], @"width",
                                nil];
                
                [common.dao insert:insertDevice];
            }
        }
    }
    
    [self.window addSubview:mainViewController.view];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self openExternalUrl:url];
}

- (BOOL)openExternalUrl:(NSURL *)url {
    if ( [[[url description] substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"wc"] ) {
        NSString *_url = [self replaceSchemeUrl:[NSString stringWithFormat:@"%@", url] map:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"wc:"
                                                                                            , @"#", @"%23"
                                                                                            , @"&", @"&amp;", nil]];
        
        NSLog(@"%@", _url);
        
        [[mainViewController url] setText:_url];
        [mainViewController doAccess];
    } else if ( [[[url description] substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"fb"] ) {
        NSLog(@"%@", url);
        
        return [facebook handleOpenURL:url]; 
    } else if ( [[[url description] substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"en"] ) {
        return [[EvernoteSession sharedSession] handleOpenURL:url];
    }
    
    /*
     if ([[EvernoteSession sharedSession] handleOpenURL:url]) {
     return YES;
     }
     */
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self openExternalUrl:url];
}

- (void)fbDidLogin {
    NSLog(@"%s", __FUNCTION__);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [delegate logginedFb:nil];
}

- (void) fbDidLogout {
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

- (NSString *)replaceSchemeUrl:(NSString *)url map:(NSDictionary *)map {
    NSArray *allkey = [map allKeys];
    int i;
    for (i = 0; i < allkey.count; i++) {
        NSString *currentKey = [allkey objectAtIndex:i];
        
        url = [url stringByReplacingOccurrencesOfString:currentKey withString:[map objectForKey:currentKey]];
    }
    
    return url;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"longScreenCapture" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"longScreenCapture.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
