//
//  SearchViewController.m
//  Malayalam Bible
//
//  Created by jijo on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "mal_api.h"
#include "txt2html.h"

#import "BibleDao.h"
#import "MBConstants.h"
#import "VerseCell.h"
#import "MalayalamBibleDetailViewController.h"
#import "MalayalamBibleAppDelegate.h"
#import "WebViewController.h"

#define tagLabelCount 8

@interface SearchViewController(Private)

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
-(NSUInteger) getResultDataCount;    

@end

@implementation SearchViewController

@synthesize searchDisplayController, labelSearch, arrayResults, primaryL, isFirstTime;
@synthesize detailViewController = _detailViewController;
@synthesize activityView = _activityView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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

    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UISearchBar *mySearchBar = [[UISearchBar alloc] init];
	[mySearchBar setScopeButtonTitles:[NSArray arrayWithObjects:kBookAll, kBookOldTestament, kBookNewTestament, nil]];
	mySearchBar.delegate = self;
	[mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[mySearchBar sizeToFit];
	self.tableView.tableHeaderView = mySearchBar;
	/*
	 fix the search bar width problem in landscape screen
	 */
	if (UIInterfaceOrientationLandscapeRight == [[UIDevice currentDevice] orientation] ||
		UIInterfaceOrientationLandscapeLeft == [[UIDevice currentDevice] orientation])
	{
		self.tableView.tableHeaderView.frame = CGRectMake(0.f, 0.f, 480.f, 44.f);
	}
	else
	{
		self.tableView.tableHeaderView.frame = CGRectMake(0.f, 0.f, 320.f, 44.f);
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
    
     /*if([self.primaryL isEqualToString:kLangMalayalam]){
         
         UIButton *buttonHelp = [UIButton buttonWithType:UIButtonTypeCustom];
         UIImage *imgHelp = [UIImage imageNamed:@"help.png"];
         [buttonHelp setImage:imgHelp forState:UIControlStateNormal];
         //[buttonHelp setTitle:@"T" forState:UIControlStateNormal];
         buttonHelp.frame = CGRectMake(self.labelSearch.frame.size.width - 30, self.labelSearch.frame.size.height-30, 20, 20);
         [buttonHelp addTarget:self action:@selector(showHelp:) forControlEvents:UIControlEventTouchUpInside];
         
         buttonHelp.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
         
         [self.labelSearch addSubview:buttonHelp];

         self.labelSearch.userInteractionEnabled = NO;
     }*/
         
     
     
    
	
	[self.searchDisplayController.searchResultsTableView reloadData];
	self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
    
   
    [self.tableView.tableHeaderView becomeFirstResponder];
    
    
  	self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
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
    /*
	 Hide the search bar
	 */
	//[self.tableView setContentOffset:CGPointMake(0, 44.f) animated:NO];
	
	
	//NSIndexPath *tableSelection = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
	//[self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:tableSelection animated:NO];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!isFirstTime){
        
        isFirstTime = YES;
        [self.tableView.tableHeaderView becomeFirstResponder];
    }
    self.navigationController.toolbarHidden = YES;
    
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
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
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
    // Return YES for supported orientations
    return YES;
}
#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
    
    NSString *verseStr = [dictVerse valueForKey:@"verse_text"];
    
    UIFont *cellFont = [UIFont fontWithName:kFontName size:FONT_SIZE];
    
    CGSize constraintSize = CGSizeMake(self.view.frame.size.width-40-40, MAXFLOAT);//280
    
    CGSize labelSize = [verseStr sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 35 ;
    
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
        
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
    // Return the number of sections.
    return [arrayResults count];
    }else{
        
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.// 
    //return [arrayResults count];;
   
    return [[[arrayResults objectAtIndex:section] objectForKey:@"rowValues"] count] ;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    return [[arrayResults objectAtIndex:section] objectForKey:@"headerTitle"];
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    //http://stackoverflow.com/questions/2955354/showing-custom-menu-on-selection-in-uiwebview-in-iphone
    /*if (webView.superview != nil && ![urlTextField isFirstResponder]) {
        if (action == @selector(customAction1:) || action == @selector(customAction2:)) {
            return YES;
        }
    }*/
    ////(@"clicked me action...sender = %@", sender);
    return NO;//[super canPerformAction:action withSender:sender];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    VerseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[VerseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
    }
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
    NSString *versee = [dictVerse valueForKey:@"verse_html"];
    
    cell.tag = indexPath.row;
    
    [cell.webView loadHTMLString:versee  baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]]];
    
    cell.verseText = [dictVerse valueForKey:@"verse_text"];
    // Configure the cell...
    
    return cell;
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
    
    [self.searchDisplayController setActive:NO];
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
    
    self.arrayResults = nil;
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
    [self.searchDisplayController.searchResultsTableView setRowHeight:1200];
    [self.searchDisplayController.searchResultsTableView setScrollEnabled:NO];
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

#pragma mark @selector method

- (void) showHelp:(id)sender{
    //(@"clicked help");
    WebViewController *webViewCtrlr = [[WebViewController alloc] init];
    webViewCtrlr.requestURL = [[NSBundle mainBundle] pathForResource:@"lipi" ofType:@"png"];
    [self.navigationController pushViewController:webViewCtrlr animated:YES];
}

#pragma mark -
#pragma mark private method


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
    self.searchDisplayController.searchResultsTableView.scrollEnabled = NO;
    
    
}
-(void)threadStopAnimating
{
    [self.activityView stopAnimating];
    [self.activityView setHidden:YES];
    [self.activityView removeFromSuperview];
    self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
}
    
- (void)showIndicator{
    
    
    [self performSelectorOnMainThread:@selector(threadStartAnimating) withObject:nil waitUntilDone:NO];
    
}   
- (void) showResult{
    
    [self performSelectorOnMainThread:@selector(showResultset) withObject:nil waitUntilDone:NO];
    
    
}
- (void) showResultset{
    
    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    
    
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:scope];
    
}
- (void)test{
    
    
    
    
    
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
    [self.searchDisplayController.searchResultsTableView setScrollEnabled:YES];
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
    
    [self.searchDisplayController.searchResultsTableView setDelegate:self];
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
	/*
	 Hide the search bar
	 */
    
	//[self.tableView setContentOffset:CGPointMake(0, 44.f) animated:YES];
}

@end
