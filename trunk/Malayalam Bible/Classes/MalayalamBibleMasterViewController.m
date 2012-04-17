//
//  MalayalamBibleMasterViewController.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "mal_api.h"
#include "txt2html.h"

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

const NSString *bmBookSection = @"BookPathSection";
const NSString *bmBookRow = @"BookPathRow";

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
@synthesize chapterSelectionController = _chapterSelectionController;
@synthesize isNeedReload = _isNeedReload;
@synthesize tableViewBooks = _tableViewBooks;
/****Search Controller ***/
@synthesize searchDisplayController, labelSearch, arrayResults, primaryL, isFirstTime, isSearching;
@synthesize activityView = _activityView;

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
    
    MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int chapterId = [[appDelegate.savedLocation objectAtIndex:1] intValue];
    
    [self selectBookWithName:selectedBookName AndChapter:chapterId];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        [self.chapterSelectionController restoreLevelWithSelectionArray:selectionArray];
    }
    
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
            
            self.chapterSelectionController = [[ChapterSelection alloc] init];//WithNibName:@"ChapterSelection" bundle:nil
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
    
    CGFloat htOfSearchbar = 45.0f;
    
    self.tableViewBooks.frame = CGRectMake(0, htOfSearchbar-1, self.view.frame.size.width, self.view.frame.size.height-htOfSearchbar-1);
    self.tableViewBooks.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:self.tableViewBooks];
    
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(self.view.frame.size.width - 30, self.view.frame.size.height-30, 20, 20);
    infoButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
	[infoButton addTarget:self action:@selector(showInfoView:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:infoButton];
    
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchVerses:)];
       
    
    UIButton* settingsButton = [[UIButton alloc] init];
    UIImage *img = [UIImage imageNamed:@"Gear.png"] ;
    [settingsButton setImage:img forState:UIControlStateNormal];
    CGRect rect = self.navigationController.navigationBar.frame;
    settingsButton.frame = CGRectMake(0, (rect.size.height-img.size.height)/2, img.size.width, img.size.height);
	[settingsButton addTarget:self action:@selector(showPreferences:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    
    //Adding observer to notify the language changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList:) name:@"NotifyTableReload" object:nil];
    
    
    /****Search Controller *****/
    UISearchBar *mySearchBar = [[UISearchBar alloc] init];
    mySearchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, htOfSearchbar);
	[mySearchBar setScopeButtonTitles:[NSArray arrayWithObjects:kBookAll, kBookOldTestament, kBookNewTestament, nil]];
	mySearchBar.delegate = self;
    mySearchBar.placeholder = @"Search Verse in Primary Language";
	[mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    mySearchBar.autoresizingMask =  UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
	[mySearchBar sizeToFit];
    [self.view addSubview:mySearchBar];
	//self.tableViewBooks.tableHeaderView = mySearchBar;
	/*
	 fix the search bar width problem in landscape screen
	 */
	if (UIInterfaceOrientationLandscapeRight == [[UIDevice currentDevice] orientation] ||
		UIInterfaceOrientationLandscapeLeft == [[UIDevice currentDevice] orientation])
	{
		self.tableViewBooks.tableHeaderView.frame = CGRectMake(0.f, 0.f, 480.f, htOfSearchbar);
	}
	else
	{
		self.tableViewBooks.tableHeaderView.frame = CGRectMake(0.f, 0.f, 320.f, htOfSearchbar);
	}
	/*
	 set up the searchDisplayController programically
	 */
	searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
	[self setSearchDisplayController:searchDisplayController];
	[searchDisplayController setDelegate:self];
	[searchDisplayController setSearchResultsDataSource:self];
    searchDisplayController.searchResultsTableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    self.primaryL = kLangMalayalam;
    
    if(dictPref !=nil ){
        
        self.primaryL = [dictPref valueForKey:@"primaryLanguage"];
        
    }
    
    
    self.labelSearch = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 320-2, 160)];
    self.labelSearch.textColor = [UIColor whiteColor];
    self.labelSearch.backgroundColor = [UIColor clearColor];
    self.labelSearch.numberOfLines = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        self.labelSearch.frame = CGRectMake(2, 0, 320-2, 300);
        
    }
        	
	[self.searchDisplayController.searchResultsTableView reloadData];
	//self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
    
    
    //[self.tableView.tableHeaderView becomeFirstResponder];
    
    
  	self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    /************************/
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
        [appDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSMutableDictionary dictionaryWithCapacity:2]]; 
        [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:-1]];
        [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSDictionary dictionary]];
    }
    if(self.isNeedReload){
        
        NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
        
        
        self.primaryL = kLangMalayalam;
        
        if(dictPref !=nil ){
            
            self.primaryL = [dictPref valueForKey:@"primaryLanguage"];
            
        }
        
        
        
        [self loadData];
        self.title = [BibleDao getTitleBooks];
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableViewBooks reloadData];
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.chapterSelectionController.navigationItem.backBarButtonItem.title = [BibleDao getTitleChapterButton];
        }
        self.isNeedReload = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if(isSearching){
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (isSearching && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
            
            
            
            
            
            [self.searchDisplayController.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:kBookAll, @"Old", @"New", nil]];
            self.labelSearch.frame = CGRectMake(2, 0, 480-2, 100);
            
            
            
        }else{
            
            
            
            self.labelSearch.frame = CGRectMake(2, 0, 320-2, 160);
            [self.searchDisplayController.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:kBookAll, kBookOldTestament, kBookNewTestament, nil]];
            
            
        }
    }
    
    
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
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        // Return the number of sections.
        return [arrayResults count];
    }else{
       
        
            return 2;
        
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [[[arrayResults objectAtIndex:section] objectForKey:@"rowValues"] count] ;
    }else{
        
        if (section == 0) {
            return 39;
        }
        else {
            return 27;
        }
    }
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        
        static NSString *CellIdentifier = @"SearchCell"; //[NSString stringWithFormat:@"%@%i", @"SearchCell", FONT_SIZE];
        VerseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[VerseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            
        }
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
        NSString *versee = [dictVerse valueForKey:@"verse_html"];
        
        cell.tag = indexPath.row;
        
        [cell.webView loadHTMLString:versee  baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]]];
        cell.isSearchResult = YES;
        cell.verseText = [dictVerse valueForKey:@"verse_text"];
        // Configure the cell...
        
        return cell;

        
    }else{
        
        NSString *CellIdentifier = [NSString stringWithFormat:@"%@%i", @"Cell", FONT_SIZE];
     
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont fontWithName:kFontName size:FONT_SIZE];
            
        }
        cell.textLabel.numberOfLines = 2;
        // Configure the cell.
        if(isSearching){
            cell.textLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        }else{
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            if(indexPath.section == 0) {
                cell.textLabel.text = [oldTestament objectAtIndex:indexPath.row];
            }
            else {
                cell.textLabel.text = [newTestament objectAtIndex:indexPath.row];
            }
        }
        return cell;
    }
	
    
        
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     if (tableView == self.searchDisplayController.searchResultsTableView){
        
        NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
        
        NSString *verseStr = [dictVerse valueForKey:@"verse_text"];
        
        UIFont *cellFont = [UIFont fontWithName:kFontName size:FONT_SIZE];
        
        CGSize constraintSize = CGSizeMake(self.view.frame.size.width-60, MAXFLOAT);//280
        
        CGSize labelSize = [verseStr sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
                  
        return labelSize.height + 10 ;

        
    }else{
        
            
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
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [[arrayResults objectAtIndex:section] objectForKey:@"headerTitle"];
    }else{
        
        if(isSearching){
            return nil;
        }else{
            if(section == 0) {
                return [BibleDao getTitleOldTestament];
            }
            else {
                return [BibleDao getTitleNewTestament];
                
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        
        NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
        
        
        
        
        NSNumber *verseidNum = [NSNumber numberWithInt:[[dictVerse valueForKey:@"verse_id"] intValue]];
        NSDictionary *dictVerseid = [NSDictionary dictionaryWithObject:verseidNum forKey:@"verse_id"];
        
        MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.savedLocation replaceObjectAtIndex:2 withObject:dictVerseid];
        
        
        
        
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            MalayalamBibleDetailViewController *detailController = [[MalayalamBibleDetailViewController alloc] init];
            detailController.selectedBook = [dictVerse valueForKey:@"book_details"];
            detailController.chapterId = [[dictVerse valueForKey:@"chapter"] intValue];
            
            detailController.isFromSeachController = YES;
            [detailController configureView];
            
            
            [self.navigationController pushViewController:detailController animated:YES];
            
            
        }else{
            
            
            self.detailViewController.selectedBook = [dictVerse valueForKey:@"book_details"];
            self.detailViewController.chapterId = [[dictVerse valueForKey:@"chapter"] intValue];
            [self.detailViewController configureiPadView];
            
        }
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
    
    if(!isSearching){
    // save off this level's selection to our AppDelegate
        [self tableViewClicked:indexPath];
    }
}



#pragma mark @selector methods


-(void)threadStartAnimating
{
    
    
	CGRect cgRect =[self.searchDisplayController.searchResultsTableView frame];
	CGSize cgSize = cgRect.size;
    //
	self.activityView.frame=CGRectMake(cgSize.width/2 - 25, cgSize.height/3-45, 50, 50);
	
	self.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
	self.activityView.tag  = 1;
    
    [self.searchDisplayController.searchResultsTableView addSubview:self.activityView];
    [self.searchDisplayController.searchResultsTableView bringSubviewToFront:self.activityView];
    [self.activityView setHidden:NO];
	[self.activityView startAnimating];
    
    
    
    
}
-(void)threadStopAnimating
{
    [self.activityView stopAnimating];
    [self.activityView setHidden:YES];
    [self.activityView removeFromSuperview];
   
}

- (void)showIndicator{
    
    
    [self performSelectorOnMainThread:@selector(threadStartAnimating) withObject:nil waitUntilDone:NO];
    
}   
- (void) showResult{
    
    [self performSelectorOnMainThread:@selector(showResultset) withObject:nil waitUntilDone:NO];
    
    
}
- (void) showResultset{
    
    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    self.searchDisplayController.searchResultsTableView.userInteractionEnabled = NO;
    
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:scope];
    
    self.searchDisplayController.searchResultsTableView.userInteractionEnabled = YES;
}
- (void) showHelp:(id)sender{
    //(@"clicked help");
    WebViewController *webViewCtrlr = [[WebViewController alloc] init];
    webViewCtrlr.requestURL = [[NSBundle mainBundle] pathForResource:@"lipi" ofType:@"png"];
    [self.navigationController pushViewController:webViewCtrlr animated:YES];
}
/*- (void) searchVerses:(id)sender{
    
    SearchViewController *ctrlr = [[SearchViewController alloc] init];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        ctrlr.detailViewController = self.detailViewController;
    }
    [self.navigationController pushViewController:ctrlr animated:YES];

}*/

- (void) showInfoView:(id)sender
{
    
    self.infoViewController = [[Information  alloc] initWithNibName:@"Information" bundle:nil];
    self.infoViewController.title = @"Information";
    [self.navigationController pushViewController:self.infoViewController animated:YES];
}
- (void) showPreferences:(id)sender{
    
    SettingsViewController *ctrlr = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:ctrlr animated:YES];
}


#pragma mark -
#pragma mark private method



- (void) selectBookWithName:(NSString *)selectedBookName AndChapter:(int)chapter{
    
    if(selectedBookName){
        
        
        self.detailViewController.isActionClicked = NO;
        Book *selectedBook = [books objectForKey:selectedBookName];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            if(selectedBook.numOfChapters > 1) {
                
                
                self.chapterSelectionController.selectedBook = selectedBook;
                [self.chapterSelectionController configureView];
                [self.navigationController pushViewController:self.chapterSelectionController animated:YES];
            }
            else {
                
                               
                self.detailViewController.selectedBook = selectedBook;
                self.detailViewController.chapterId = chapter;
                [self.detailViewController configureView];
                [self.navigationController pushViewController:self.detailViewController animated:YES];
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
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    
    
    
	BibleDao *bdao = [[BibleDao alloc] init];
    
    
    self.arrayResults = nil;
    if([self.primaryL isEqualToString:kLangMalayalam]){
        self.arrayResults = [bdao getSerachResultWithText:labelSearch.text InScope:scope];
    }else{
        self.arrayResults = [bdao getSerachResultWithText:searchText InScope:scope];
    }
    
    //[labelSearch removeFromSuperview];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    [self.searchDisplayController.searchResultsTableView setRowHeight:45];
    //[self.searchDisplayController.searchResultsTableView setScrollEnabled:YES];
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    NSUInteger cont = [self getResultDataCount];
    NSString *countStr = [NSString stringWithFormat:@"%i", cont];
    
    for (UIView *subview in self.searchDisplayController.searchBar.subviews) { 
        if ([subview conformsToProtocol:@protocol(UITextInputTraits)]) { 
            
            UITextField *fieldSearch = (UITextField *)subview;
            
            UILabel *lblCount = (UILabel *)[fieldSearch viewWithTag:tagLabelCount];
            if(lblCount == nil){
                
                lblCount = [[UILabel alloc] init];
                lblCount.backgroundColor = [UIColor clearColor];
                lblCount.textColor = [UIColor grayColor];
                lblCount.tag = tagLabelCount;
            }else{
                [lblCount removeFromSuperview];
            }
            
            lblCount.text = countStr;
            CGSize sizeCount = [countStr sizeWithFont:lblCount.font];
            
            lblCount.frame = CGRectMake(fieldSearch.frame.size.width - sizeCount.width - 28, 0, sizeCount.width, fieldSearch.frame.size.height);
            [fieldSearch addSubview:lblCount];
            break;
        } 
    } 
    
    
    [self threadStopAnimating];
    //UIActivityIndicatorView *tempActivityView = (UIActivityIndicatorView *)[self.searchDisplayController.searchResultsTableView viewWithTag:1];
	
    //[tempActivityView stopAnimating];
	//[tempActivityView removeFromSuperview];
}
-(NSUInteger) getResultDataCount{
	
	NSUInteger sum = 0;
	for(NSDictionary *dict in arrayResults){
		
		sum += [[dict objectForKey:@"rowValues"] count];
	}
	return sum;
}

#pragma mark NotifyTableReload

- (void)refreshList:(NSNotification *)note
{
	self.isNeedReload = YES;
    
	//NSDictionary *dict = [note userInfo];
    
    
    
}
#pragma mark UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    
    if([self.primaryL isEqualToString:kLangMalayalam]){
        
        long flags = FL_DEFAULT;
        char *output = mozhi_unicode_parse([searchText UTF8String], flags);
        NSString *outputStr = [NSString stringWithUTF8String:output];
        
        
        labelSearch.text = outputStr;
    }else{
        
        labelSearch.text = searchText;
    }
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    
    [NSThread detachNewThreadSelector:@selector(showIndicator) toTarget:self withObject:nil];
    
    [self performSelector:@selector(showResult) withObject:nil afterDelay:.1];
    
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    
    [self.searchDisplayController setActive:NO animated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
    
    for (UIView *subview in self.searchDisplayController.searchBar.subviews) { 
        if ([subview conformsToProtocol:@protocol(UITextInputTraits)]) { 
            
            UITextField *fieldSearch = (UITextField *)subview;
            UILabel *lblCount = (UILabel *)[fieldSearch viewWithTag:tagLabelCount];
            [lblCount removeFromSuperview];
        }
    }
    
    
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    
    self.isSearching = YES;
    
    self.arrayResults = nil;
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
    [self.searchDisplayController.searchResultsTableView setRowHeight:1200];
    //[self.searchDisplayController.searchResultsTableView setScrollEnabled:NO];
    [self.searchDisplayController.searchResultsTableView reloadData];
    //if([self.primaryL isEqualToString:kLangMalayalam]){
    [self.searchDisplayController.searchResultsTableView addSubview:labelSearch];
    //}
    
    for (UIView *subview in self.searchDisplayController.searchBar.subviews) { 
        if ([subview conformsToProtocol:@protocol(UITextInputTraits)]) { 
            
            UITextField *fieldSearch = (UITextField *)subview;
            UILabel *lblCount = (UILabel *)[fieldSearch viewWithTag:tagLabelCount];
            [lblCount removeFromSuperview];
        }
    }
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
   
    
    //if([self.primaryL isEqualToString:kLangMalayalam]){
    [labelSearch removeFromSuperview];
    //}
}
#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [controller.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
    [controller.searchResultsTableView setRowHeight:1200];
    //[controller.searchResultsTableView setScrollEnabled:NO];
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    // undo the changes above to prevent artefacts reported below by mclin
    
    
    [controller.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    [controller.searchResultsTableView setRowHeight:45];
    //[controller.searchResultsTableView setScrollEnabled:YES];
}

/*- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
 [self filterContentForSearchText:searchString scope:
 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
 
 
 // Return YES to cause the search result table view to be reloaded.
 return NO;
 }*/

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
    
    NSString *sText = [self.searchDisplayController.searchBar text];
    if(sText && [sText length] > 0){
        
        [NSThread detachNewThreadSelector:@selector(showIndicator) toTarget:self withObject:nil];
        
        [self performSelector:@selector(showResult) withObject:nil afterDelay:.1];
        //[self filterContentForSearchText:sText scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
        [self.searchDisplayController.searchBar resignFirstResponder];
    }
    
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
	/*
     Because the searchResultsTableView will be released and allocated automatically, so each time we start to begin search, we set its delegate here.
     */
    
    
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
     
     //if([self.primaryL isEqualToString:kLangMalayalam]){
     
     CGRect lblFrame = labelSearch.frame;
     lblFrame.size = CGSizeMake(self.searchDisplayController.searchResultsTableView.frame.size.width-20, 200);
     labelSearch.frame = lblFrame;//+20120322
     [labelSearch setNeedsLayout];
     //}
     
     }*/
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        if([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft || [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight){
            
            
            [self.searchDisplayController.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:kBookAll, @"Old", @"New", nil]];
        }
    }
    
    
    self.isSearching = YES;
    [self.tableViewBooks reloadData];
    
    [self.searchDisplayController.searchResultsTableView setDelegate:self];
    
    
    
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
	/*
	 Hide the search bar
	 */
    self.isSearching = NO;
    [self.tableViewBooks reloadData];
   
	//[self.tableView setContentOffset:CGPointMake(0, 44.f) animated:YES];
}

@end
