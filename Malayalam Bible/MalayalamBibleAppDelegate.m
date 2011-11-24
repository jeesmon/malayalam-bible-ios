//
//  MalayalamBibleAppDelegate.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MalayalamBibleAppDelegate.h"

#import "MalayalamBibleMasterViewController.h"

#import "MalayalamBibleDetailViewController.h"

@implementation MalayalamBibleAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize savedLocation;

NSString *kRestoreLocationKey = @"RestoreLocation";	// preference key to obtain our restore location

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        MalayalamBibleMasterViewController *masterViewController = [[MalayalamBibleMasterViewController alloc] initWithNibName:@"MalayalamBibleMasterViewController_iPhone" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        self.window.rootViewController = self.navigationController;
        
    } else {
        
        
        MalayalamBibleDetailViewController *detailViewController = [[MalayalamBibleDetailViewController alloc] init];
        
        //MalayalamBibleDetailViewController *detailViewController = [[MalayalamBibleDetailViewController alloc] initWithNibName:@"MalayalamBibleDetailViewController_iPad" bundle:nil];
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        
        MalayalamBibleMasterViewController *masterViewController = [[MalayalamBibleMasterViewController alloc] init];
        masterViewController.detailViewController = detailViewController;
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
        
        self.window.rootViewController = self.splitViewController;
        
        
    }
    
    
    
    // load the stored preference of the user's last location from a previous launch
	self.savedLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:kRestoreLocationKey] mutableCopy];
	
    
	if (savedLocation == nil)
	{
		// user has not launched this app nor navigated to a particular level yet, start at level 1, with no selection
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            savedLocation = [NSMutableArray arrayWithObjects:
                             [NSMutableDictionary dictionaryWithCapacity:1],	// book selection 
                             [NSNumber numberWithInt:-1],	// .. 2nd level  the chapter idex
                             [NSMutableDictionary dictionaryWithCapacity:1],
                             nil];
            
        }else{
            savedLocation = [NSMutableArray arrayWithObjects:
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"BookPathSection",[NSNumber numberWithInt:0], @"BookPathRow", nil],	// book selection at 1st level
                             [NSNumber numberWithInt:0],	// .. 2nd level , the chapter idex
                             [NSMutableDictionary dictionaryWithCapacity:1],	
                             nil];
            
        }
    }
	
    NSLog(@"savedLocation =%@", savedLocation);
    NSNumber *selection = [[savedLocation objectAtIndex:0] valueForKey:@"BookPathSection"];	// read the saved selection at level 1
    if (selection)
    {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            [(MalayalamBibleMasterViewController*)self.navigationController.topViewController restoreLevelWithSelectionArray:savedLocation];
        }else{
            [(MalayalamBibleMasterViewController*)[[self.splitViewController.viewControllers objectAtIndex:0] topViewController] restoreLevelWithSelectionArray:savedLocation];
        }
        
    }
    else
    {    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            [savedLocation replaceObjectAtIndex:0 withObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"BookPathSection",[NSNumber numberWithInt:0], @"BookPathRow", nil]];
            [(MalayalamBibleMasterViewController*)self.navigationController.topViewController restoreLevelWithSelectionArray:savedLocation];
        }
        // no saved selection, so user was at level 1 the last time
    }
	
    
    [self.window makeKeyAndVisible];
    
        
    // register our preference selection data to be archived
	NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:savedLocation forKey:kRestoreLocationKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
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
    
	[[NSUserDefaults standardUserDefaults] setObject:savedLocation forKey:kRestoreLocationKey];
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
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
