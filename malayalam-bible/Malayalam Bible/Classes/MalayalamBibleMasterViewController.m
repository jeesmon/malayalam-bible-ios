//
//  MalayalamBibleMasterViewController.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "MalayalamBibleAppDelegate.h"
#import "MalayalamBibleMasterViewController.h"
#import "MalayalamBibleDetailViewController.h"
#import "Book.h"
#import "BibleDao.h"
#import "SettingsViewController.h"
//#import "SearchViewController.h"
#import "MBConstants.h"
#import "VerseCell.h"
#import "WebViewController.h"

//const NSString *bmBookSection = @"BookPathSection";
//const NSString *bmBookRow = @"BookPathRow";

#define tagLabelCount 8

@interface MalayalamBibleMasterViewController(Private)

- (void) selectBookWithName:(NSString *)selectedBookName AndChapter:(int)chapter;
- (void) loadData;
/***Search Controller **/
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
-(NSUInteger) getResultDataCount;   

@end

@implementation MalayalamBibleMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize infoViewController = _infoViewController;
//@synthesize chapterSelectionController = _chapterSelectionController;
@synthesize isNeedReload = _isNeedReload;
@synthesize tableViewBooks = _tableViewBooks;


- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray{
    
    
    NSDictionary *dict = [selectionArray objectAtIndex:0];
        
    NSUInteger section = [[dict objectForKey:bmBookSection] intValue];
    NSUInteger row = [[dict objectForKey:bmBookRow] intValue];
    NSString *selectedBookName;
    
    if(section == 0) {
        selectedBookName = [oldTestament objectAtIndex:row];
    }
    else {
        selectedBookName = [newTestament objectAtIndex:row];
    }
    
    [self.tableViewBooks scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [self.tableViewBooks selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int chapterId = [[appDelegate.savedLocation objectAtIndex:1] intValue];
    
    [self selectBookWithName:selectedBookName AndChapter:chapterId];
    
    /*+20120727if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        [self.chapterSelectionController restoreLevelWithSelectionArray:selectionArray];
    }*/
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [BibleDao getTitleBooks];
        
        self.tableViewBooks = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableViewBooks.delegate = self;
        self.tableViewBooks.dataSource = self;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            //self.chapterSelectionController = [[ChapterSelection alloc] init];//WithNibName:@"ChapterSelection" bundle:nil
            self.detailViewController = [[MalayalamBibleDetailViewController alloc] init];
            //WithNibName:@"MalayalamBibleDetailViewController_iPhone" bundle:nil
        }else{
            //+20120302self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
        [self loadData];
    }
    return self;
}
- (id)init{
    return [self initWithNibName:nil bundle:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.tableViewBooks.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        self.tableViewBooks.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelMe:)];
        
    }else{
        
        self.tableViewBooks.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    }
    
    
    [self.view addSubview:self.tableViewBooks];
    
    /*UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(self.view.frame.size.width - 30, self.view.frame.size.height-30, 20, 20);
    infoButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
	[infoButton addTarget:self action:@selector(showInfoView:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:infoButton];
    
    
    
       
    
    UIButton* settingsButton = [[UIButton alloc] init];
    UIImage *img = [UIImage imageNamed:@"Gear.png"] ;
    [settingsButton setImage:img forState:UIControlStateNormal];
    CGRect rect = self.navigationController.navigationBar.frame;
    settingsButton.frame = CGRectMake(0, (rect.size.height-img.size.height)/2, img.size.width, img.size.height);
	[settingsButton addTarget:self action:@selector(showPreferences:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    */
    //Adding observer to notify the language changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList:) name:@"NotifyTableReload" object:nil];
    
    	
}



- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        self.navigationController.toolbarHidden = YES;
        
        MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
        //+20120910[appDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSMutableDictionary dictionaryWithCapacity:2]]; 
        [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];
        [appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSDictionary dictionary]];
    }
    if(self.isNeedReload){
        
        
               
        
        [self loadData];
        self.title = [BibleDao getTitleBooks];
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableViewBooks reloadData];
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            //+20120727self.chapterSelectionController.navigationItem.backBarButtonItem.title = [BibleDao getTitleChapterButton];
        }
        self.isNeedReload = NO;
    }
    
    
    
    //+20120810
    MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *dict = [appDelegate.savedLocation objectAtIndex:0];
    
    NSUInteger section = [[dict objectForKey:bmBookSection] intValue];
    NSUInteger row = [[dict objectForKey:bmBookRow] intValue];
       
    [self.tableViewBooks scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [self.tableViewBooks selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
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
    
    return YES;
    // Return YES for supported orientations
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }*/
}


#pragma mark UItableDataSource

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   
            return 2;
       
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
        if (section == 0) {
            return 39;
        }
        else {
            return 27;
        }
    
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
            
        NSString *CellIdentifier = [NSString stringWithFormat:@"%@%i", @"Cell", FONT_SIZE];
     
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont fontWithName:kFontName size:FONT_SIZE];
            
        }
        cell.textLabel.numberOfLines = 2;
        // Configure the cell.
       
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            if(indexPath.section == 0) {
                cell.textLabel.text = [oldTestament objectAtIndex:indexPath.row];
            }
            else {
                cell.textLabel.text = [newTestament objectAtIndex:indexPath.row];
            }
        
        return cell;
    
        
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
                
        NSString *cellText;
        if(indexPath.section == 0) {
            cellText = [oldTestament objectAtIndex:indexPath.row];
        }
        else {
            cellText = [newTestament objectAtIndex:indexPath.row];
        }
        
        UIFont *cellFont = [UIFont fontWithName:kFontName size:FONT_SIZE];
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        return labelSize.height + 10;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
   
        
     
            if(section == 0) {
                return [BibleDao getTitleOldTestament];
            }
            else {
                return [BibleDao getTitleNewTestament];
                
            }
     
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
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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

- (void)tableViewClicked:(NSIndexPath *)indexPath{
    
    MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableDictionary *dict = [appDelegate.savedLocation objectAtIndex:0];
    [dict setObject:[NSNumber numberWithInt:indexPath.section] forKey:bmBookSection];
    [dict setObject:[NSNumber numberWithInt:indexPath.row] forKey:bmBookRow];
    [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
	[appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSDictionary dictionary]];   
    
    NSString *selectedBookName;
    
    if(indexPath.section == 0) {
        selectedBookName = [oldTestament objectAtIndex:indexPath.row];
    }
    else {
        selectedBookName = [newTestament objectAtIndex:indexPath.row];
    }
    
    
    [self selectBookWithName:selectedBookName AndChapter:1];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        // save off this level's selection to our AppDelegate
        [self tableViewClicked:indexPath];
    
}



#pragma mark @selector methods



- (void) showInfoView:(id)sender
{
    
    self.infoViewController = [[Information  alloc] initWithNibName:@"Information" bundle:nil];
    self.infoViewController.title = @"About";
    [self.navigationController pushViewController:self.infoViewController animated:YES];
}
- (void) showPreferences:(id)sender{
    
    SettingsViewController *ctrlr = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:ctrlr animated:YES];
}
//for iPhone only
- (void) cancelMe:(id)sender{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark private method



- (void) selectBookWithName:(NSString *)selectedBookName AndChapter:(int)chapter{
    
    if(selectedBookName){
        
        
        self.detailViewController.isActionClicked = NO;
        Book *selectedBook = [books objectForKey:selectedBookName];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            if(selectedBook.numOfChapters > 1) {
                
              
                ChapterSelection *picker = [[ChapterSelection alloc] init];
                picker.selectedBook = selectedBook;
                [picker configureView:YES];
                
                //picker.navigationItem.backBarButtonItem.title = [BibleDao getTitleChapterButton];
                [self.navigationController pushViewController:picker animated:YES];
            }
            else {
                
               
                MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
                               
                appDelegate.detailViewController.selectedBook = selectedBook;
                appDelegate.detailViewController.chapterId = chapter;
                [appDelegate.detailViewController configureView];
                //[self.navigationController pushViewController:self.detailViewController animated:YES];
                [self.navigationController dismissModalViewControllerAnimated:YES];
            }
        }else{
            
            
            self.detailViewController.selectedBook = selectedBook;
            self.detailViewController.chapterId = chapter;
            
            [self.detailViewController configureiPadView];
        }
        
    }
    
}

- (void) loadData{
    
    BibleDao *dao = [[BibleDao alloc] init];
    NSDictionary *dict = [dao fetchBookNames];
    books = [dict objectForKey:@"books"];
    oldTestament = [dict objectForKey:@"oldTestament"];
    newTestament = [dict objectForKey:@"newTestament"];
                    
}

#pragma mark NotifyTableReload

- (void)refreshList:(NSNotification *)note
{
	self.isNeedReload = YES;
    
	//NSDictionary *dict = [note userInfo];
    
    
    
}

@end
