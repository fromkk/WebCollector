//
//  AppDelegate.h
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/07.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "FBConnect.h"
#import "Common.h"

extern NSString *productId;

@interface AppDelegate : UIResponder <UIApplicationDelegate,FBSessionDelegate> {
    MainViewController *mainViewController;
    Facebook *facebook;
    id<ShareViewControllerProtocol> delegate;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) id<ShareViewControllerProtocol> delegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)replaceSchemeUrl:(NSString *)url map:(NSDictionary *)map;
- (BOOL)openExternalUrl:(NSURL *)url;

@end
