//
//  MalayalamBibleAppDelegate.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MalayalamBibleAppDelegate.h"

#import "MalayalamBibleMasterViewController.h"

#import "BibleDao.h"
#import "MBConstants.h"



@implementation MalayalamBibleAppDelegate

@synthesize detailViewController = _detailViewController;
@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize savedLocation;

NSString *kRestoreLocationKey = @"RestoreLocation";	// preference key to obtain our restore location



- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray{
    
    
    NSDictionary *dict = [selectionArray objectAtIndex:0];
    
    NSUInteger section = [[dict objectForKey:bmBookSection] intValue];
    NSUInteger row = [[dict objectForKey:bmBookRow] intValue];
   
    BibleDao *bdao = [[BibleDao alloc] init];
    Book *selBook = [bdao fetchBookWithSection:section Row:row];
    
    
    NSInteger chapterid = [[selectionArray objectAtIndex:1] intValue];
    
   
	if (chapterid <= 0)
	{
        chapterid = 1;
    }
        self.detailViewController.isActionClicked = NO;
        
        self.detailViewController.selectedBook = selBook;
        self.detailViewController.chapterId = chapterid;
        [self.detailViewController configureView];

    
    
}

- (void)openVerseForiPadSavedLocation{
    
    [(MalayalamBibleMasterViewController*)[[self.splitViewController.viewControllers objectAtIndex:0] topViewController] restoreLevelWithSelectionArray:savedLocation];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
       
    self.window = [[RootWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.detailViewController = [[MalayalamBibleDetailViewController alloc] init];
    
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.detailViewController];
        self.window.rootViewController = self.navigationController;
        
    } else {
        
                
        //MalayalamBibleDetailViewController *detailViewController = [[MalayalamBibleDetailViewController alloc] initWithNibName:@"MalayalamBibleDetailViewController_iPad" bundle:nil];
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:self.detailViewController];
        
        MalayalamBibleMasterViewController *masterViewController = [[MalayalamBibleMasterViewController alloc] init];
        masterViewController.detailViewController = self.detailViewController;
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = self.detailViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
        
        self.window.rootViewController = self.splitViewController;
        
        
    }
    
    
    
    // load the stored preference of the user's last location from a previous launch
    NSUserDefaults *def  =[NSUserDefaults standardUserDefaults];
	self.savedLocation = [[def objectForKey:kRestoreLocationKey] mutableCopy];
    NSInteger fontSize = [def integerForKey:@"fontSize"];
    
    if(fontSize > 0){
        FONT_SIZE = fontSize;
    }
   
  
    
	if (savedLocation == nil || [savedLocation count] == 0)
	{
		// user has not launched this app nor navigated to a particular level yet, start at level 1, with no selection
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
      
            self.savedLocation = [NSMutableArray arrayWithObjects:
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"BookPathSection",[NSNumber numberWithInt:0], @"BookPathRow", nil],	// book selection at 1st level
                             [NSNumber numberWithInt:1],	// .. 2nd level  the chapter idex
                             [NSMutableDictionary dictionaryWithCapacity:1],// 3rd level - verse id
                             nil];
            
        }else{
            
            
            self.savedLocation = [NSMutableArray arrayWithObjects:
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"BookPathSection",[NSNumber numberWithInt:0], @"BookPathRow", nil],	// book selection at 1st level
                             [NSNumber numberWithInt:1],	// .. 2nd level , the chapter idex
                             [NSMutableDictionary dictionaryWithCapacity:1],// 3rd level - verse id	
                             nil];
            
        }
    }
    
    
    [self.window makeKeyAndVisible];
	
    NSNumber *selection = [[savedLocation objectAtIndex:0] valueForKey:@"BookPathSection"];	// read the saved selection at level 1
    if (selection)
    {
        NSLog(@"restore point %@", selection);
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            
            [self restoreLevelWithSelectionArray:savedLocation];
            
        }else{
            
            [(MalayalamBibleMasterViewController*)[[self.splitViewController.viewControllers objectAtIndex:0] topViewController] restoreLevelWithSelectionArray:savedLocation];
        }
        
    }
    else
    {    
        NSLog(@"no restore point");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            self.savedLocation = [NSMutableArray arrayWithObjects:
                                  [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"BookPathSection",[NSNumber numberWithInt:0], @"BookPathRow", nil],	// book selection at 1st level
                                  [NSNumber numberWithInt:1],	// .. 2nd level , the chapter idex
                                  [NSMutableDictionary dictionaryWithCapacity:1],	
                                  nil];
            [(MalayalamBibleMasterViewController*)[[self.splitViewController.viewControllers objectAtIndex:0] topViewController] restoreLevelWithSelectionArray:self.savedLocation];
        }else{
            
            
            self.savedLocation = [NSMutableArray arrayWithObjects:
                                  [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"BookPathSection",[NSNumber numberWithInt:0], @"BookPathRow", nil],	// book selection at 1st level
                                  [NSNumber numberWithInt:1],	// .. 2nd level , the chapter idex
                                  [NSMutableDictionary dictionaryWithCapacity:1],// 3rd level - verse id	
                                  nil];
            
             [self restoreLevelWithSelectionArray:savedLocation];
            /*MalayalamBibleMasterViewController *masterViewController = [[MalayalamBibleMasterViewController alloc] init];
            UINavigationController *temp = [[UINavigationController alloc] initWithRootViewController:masterViewController];
            [self.window.rootViewController presentModalViewController:temp animated:YES];*/
        }
        // no saved selection, so user was at level 1 the last time
    }
	
    
    
    
        
    // register our preference selection data to be archived
	NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:savedLocation forKey:kRestoreLocationKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    
    /*NSString *pathname = [[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    if(pathname != nil){
        
        NSLog(@"pathname = %@", pathname);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:pathname]){
            
            NSLog(@"file exist = %@", pathname);
             NSError *error;
            if([fileManager removeItemAtPath:pathname error:&error]){
                NSLog(@"removed old db");
            }else{
                 NSLog(@"err %@",[error localizedDescription]);
            }
        }
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"malayalam-english-bible.db"];

    if(dbPath != nil){
        
        NSLog(@"dbPath = %@", dbPath);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:dbPath]){
            
            NSLog(@"file exist = %@", dbPath);
            NSError *error;
            if([fileManager removeItemAtPath:dbPath error:&error]){
                NSLog(@"removed old db");
            }else{
                NSLog(@"err %@",[error localizedDescription]);
            }
        }
    }*/
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
