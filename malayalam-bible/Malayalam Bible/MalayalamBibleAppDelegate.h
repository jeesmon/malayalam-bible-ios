//
//  MalayalamBibleAppDelegate.h
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MalayalamBibleDetailViewController.h"
#import "RootWindow.h"

static NSString * const kStatusBarTappedNotification = @"statusBarTappedNotification";

@interface MalayalamBibleAppDelegate : UIResponder <UIApplicationDelegate>{
    
    NSMutableArray		*savedLocation;	// an array of selections for each drill level
    MalayalamBibleDetailViewController *detailViewController;
    // [ dictionary bookPathSection and bookpathRow keys, NSNumber chapterIndex , dictionary scrollposition]   
}

@property (strong, nonatomic) RootWindow *window;
@property (nonatomic, retain) NSMutableArray *savedLocation;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) MalayalamBibleDetailViewController *detailViewController;
@property (strong, nonatomic) UISplitViewController *splitViewController;



- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)openVerseForiPadSavedLocation;
- (NSManagedObjectContext *)managedObjectContext;
@end
