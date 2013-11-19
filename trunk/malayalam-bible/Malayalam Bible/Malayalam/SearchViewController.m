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
//#import "MalayalamBibleDetailViewController.h"
#import "MalayalamBibleAppDelegate.h"
#import "WebViewController.h"
#import "MBUtils.h"
#import "UIButtonGlossy.h"
#import "UIDeviceHardware.h"

#define tagLabelCount 8

@interface SearchViewController(Private)

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope AndBookid:(int)bookid;
-(NSUInteger) getResultDataCount;    

@end

@implementation SearchViewController

@synthesize  labelSearch, arrayResults, primaryL, isFirstTime, tableViewSearch, selectedBook, scopeValue, searchBarr;
@synthesize detailViewController = _detailViewController;
@synthesize activityView = _activityView;

- (id)init
{
    self = [super init];
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
    
    CGFloat yValue = 0;
    CGFloat xValue = 0;
    if([UIDeviceHardware isOS7Device]){
        
        
        yValue = 0;//statusBarHeight;
        xValue = 20;
    }
    

    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UISearchBar *mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(xValue, yValue, self.view.frame.size.width-xValue*2, 45)];
	//[mySearchBar setScopeButtonTitles:[NSArray arrayWithObjects:kBookAll, kBookOldTestament, kBookNewTestament, nil]];
	mySearchBar.delegate = self;
    if([UIDeviceHardware isOS7Device]){
        
        mySearchBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [mySearchBar setBarTintColor:[UIColor whiteColor]];
        mySearchBar.showsCancelButton = NO;
        mySearchBar.frame = CGRectMake(0, yValue, self.view.frame.size.width-70, 45);
        
        /*UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        cancelBtn.frame = CGRectMake(self.view.frame.size.width-70, yValue, 70 , 45);
        cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
         */
        //[cancelBtn.titleLabel setTextColor:[UIColor whiteColor]];
        
        //CGFloat components[8] = { 244./255, 245./255, 247./255, 1.0,   // Start color
        
        //   147./255., 153./255., 168./255., 1. }; // End color
        
        
        
        [mySearchBar setBackgroundColor:[UIColor whiteColor]];//jijo
        //[cancelBtn setBackgroundColor:[UIColor colorWithRed:(10/255.0) green:(10/255.0) blue:(10/255.0) alpha:1]];
        
        //[cancelBtn addTarget: self  action: @selector(cancelClicked:)   forControlEvents: UIControlEventTouchDown];
        //[self.view addSubview:cancelBtn];
        //[self.navigationController.navigationBar addSubview:cancelBtn];
    }else{
        
        mySearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        mySearchBar.showsCancelButton = YES;
        [mySearchBar setTintColor:[UIColor blackColor]];
    }
    [self.view setBackgroundColor:mySearchBar.backgroundColor];
    
    
	[mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    self.searchBarr = mySearchBar;
        
    //self.view.backgroundColor = [UIColor whiteColor];
	//[mySearchBar sizeToFit];
    
    if([UIDeviceHardware isOS7Device]){
        self.navigationItem.titleView = mySearchBar;
    }else{
        [self.view addSubview:mySearchBar];
    }
	
	
    
    
    /*
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
        
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    //[cancelBtn.titleLabel setTextColor:[UIColor whiteColor]];
    
    //CGFloat components[8] = { 244./255, 245./255, 247./255, 1.0,   // Start color
        
     //   147./255., 153./255., 168./255., 1. }; // End color
    
    
    
    
    //[cancelBtn setBackgroundColor:[UIColor colorWithRed:(10/255.0) green:(10/255.0) blue:(10/255.0) alpha:1]];
    
    [cancelBtn addTarget: self
                  action: @selector(cancelClicked:)
        forControlEvents: UIControlEventTouchDown];

    
    if([UIDeviceHardware isOS7Device]){
        
        [self.searchBarr setBarTintColor:[UIColor colorWithRed:(225/255.0) green:(225/255.0) blue:(225/255.0) alpha:1]];
        
        UIView *vieww = [[UIView alloc] init];
        vieww.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [vieww setBackgroundColor:[UIColor colorWithRed:(225/255.0) green:(225/255.0) blue:(225/255.0) alpha:1]];
        [vieww setFrame:CGRectMake(self.view.frame.size.width-50, 1+yValue, 50, 43)];
        
        [cancelBtn setFrame:CGRectMake(1, 2, 48, 41)];
        //[cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [vieww addSubview:cancelBtn];
        [self.view addSubview:vieww];
        
    }else{
        
        self.searchBarr.tintColor = [UIColor grayColor];
        UIColor *color1 = [UIColor darkGrayColor];// colorWithRed:(244/255.0) green:(245/255.0) blue:(247/255.0) alpha:1];
        UIColor *color2 = [UIColor darkGrayColor];//colorWithRed:(130/255.0) green:(130/255.0) blue:(130/255.0) alpha:1];
        
        [cancelBtn shinyButton:cancelBtn WithWidth:50 height:45 color:color1 color2:color2];
        [cancelBtn setBackgroundColor:[UIColor grayColor]];
        [cancelBtn setFrame:CGRectMake(self.view.frame.size.width-50, 0+yValue, 50, 45)];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }

    
    
      [self.view addSubview:cancelBtn];
 */
       

    
    if([UIDeviceHardware isOS7Device]){
        
        [self.searchBarr setBarTintColor:[UIColor whiteColor]];
        yValue += 60;
                
    }else{
        yValue += 45;
        self.searchBarr.tintColor = [UIColor blackColor];
    }
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    self.primaryL = kLangPrimary;
        
    if(dictPref !=nil ){
        
        self.primaryL = [dictPref valueForKey:@"primaryLanguage"];
               
    }
    
    
    
    
    
    self.labelSearch = [[UILabel alloc] initWithFrame:CGRectMake(0, yValue, self.view.frame.size.width, 45)];
    self.labelSearch.textAlignment = UITextAlignmentCenter;
    
    if([UIDeviceHardware isOS7Device]){
        self.labelSearch.textColor = [UIColor blackColor];
        self.labelSearch.backgroundColor = [UIColor whiteColor];
        
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.labelSearch.frame.size.height-1, self.labelSearch.frame.size.width, 1)];
        borderView.backgroundColor = [UIColor lightGrayColor];
        [self.labelSearch addSubview:borderView];
        
    }else{
        self.labelSearch.textColor = [UIColor whiteColor];
        self.labelSearch.backgroundColor = [UIColor blackColor];
        
    }
    self.labelSearch.numberOfLines = 2;
    //self.labelSearch.textAlignment = UITextAlignmentCenter;
    //self.labelSearch.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        self.labelSearch.frame = CGRectMake(0, 0+yValue, self.view.frame.size.width, 45);
        
    }
    if([self.primaryL isEqualToString:kLangPrimary]){
        
        [self.view addSubview:self.labelSearch];
        
        yValue+=45;
    }
    
    
    self.tableViewSearch = [[UITableView alloc] initWithFrame:CGRectMake(0, yValue, self.view.frame.size.width, self.view.frame.size.height-yValue) style:UITableViewStylePlain];
    self.tableViewSearch.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.tableViewSearch.delegate = self;
    self.tableViewSearch.dataSource = self;

    
    
    self.tableViewSearch.allowsMultipleSelection = YES;
    
     /*if([self.primaryL isEqualToString:kLangMalayalam]){
         
         UIButton *buttonHelp = [UIButton buttonWithType:UIButtonTypeCustom];
         UIImage *imgHelp = [UIImage imageNamed:@"help.png"];
         [buttonHelp setImage:imgHelp forState:UIControlStateNormal];
         //[buttonHelp setTitle:@"T" forState:UIControlStateNormal];
         buttonHelp.frame = CGRectMake(self.labelSearch.frame.size.width - 30, self.labelSearch.frame.size.height-30, 20, 20);
         [buttonHelp addTarget:self action:@selector(showHelp:) forControlEvents:UIControlEventTouchUpInside];
         
         buttonHelp.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;UIViewAutoresizingFlexibleBottomMargin
         
         [self.labelSearch addSubview:buttonHelp];

         self.labelSearch.userInteractionEnabled = NO;
     }*/
         
    
         [self.view addSubview:tableViewSearch];
  
	
	//[self.searchDisplayController.searchResultsTableView reloadData];
	//self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
    
    if(![UIDeviceHardware isOS7Device]){
    [self performSelector:@selector(enableCancelButton:) withObject:self.searchBarr afterDelay:0.5];
    }
  	self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
    if(![UIDeviceHardware isOS7Device]){
    self.navigationController.navigationBarHidden = YES;
    }
    if(searchBarr.text == nil || [searchBarr.text isEqualToString:@""]){
        [searchBarr becomeFirstResponder];
    }
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
        
    }
    //self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    //self.navigationController.toolbarHidden = YES;
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillDisappear:animated];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    //[self.searchDisplayController.searchResultsTableView reloadData];
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
            
            
            
            
            
           // [self.searchDisplayController.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:kBookAll, @"Old", @"New", nil]];
            //self.labelSearch.frame = CGRectMake(2, 0, 480-2, 100);
            
            
            
        }else{
            
            
            
           // self.labelSearch.frame = CGRectMake(2, 0, 320-2, 160);
          //  [self.searchDisplayController.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:kBookAll, kBookOldTestament, kBookNewTestament, nil]];
            
            
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
        
    CGSize constraintSize = CGSizeMake(self.tableViewSearch.frame.size.width-70, MAXFLOAT);//280
    
    CGSize labelSize = [verseStr sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height +10 ;
    
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
    NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
    
	   
    MBLog(@"dictVerse = %@", dictVerse);
    //Book *selectBook = [dictVerse valueForKey:@"book_details"];
      
    NSNumber *verseidNum = [NSNumber numberWithInt:[[dictVerse valueForKey:@"verse_id"] intValue]];
    NSMutableDictionary *dictVerseid = [NSMutableDictionary dictionaryWithObject:verseidNum forKey:@"verse_id"];
    
     MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.savedLocation replaceObjectAtIndex:2 withObject:dictVerseid];
    
    
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
                
        self.detailViewController.selectedBook = [dictVerse valueForKey:@"book_details"];
        self.detailViewController.chapterId = [[dictVerse valueForKey:@"chapter"] intValue];
        [self.detailViewController configureView];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        
    }else{
        
        
        MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        Book *selectBook = [dictVerse valueForKey:@"book_details"];
        
        /**set select book*** +20121006 **/
        NSUInteger bookindex= selectBook.bookId;
        NSMutableDictionary *dict = [appDelegate.savedLocation objectAtIndex:0];
        
        [dict setObject:[NSNumber numberWithInt:bookindex-1] forKey:bmBookSection];//+20121017
        /*if(bookindex > 39){
            
            [dict setObject:[NSNumber numberWithInt:1] forKey:bmBookSection];
            [dict setObject:[NSNumber numberWithInt:bookindex-40] forKey:bmBookRow];
            
            
        }else{
            
            [dict setObject:[NSNumber numberWithInt:0] forKey:bmBookSection];
            [dict setObject:[NSNumber numberWithInt:bookindex-1] forKey:bmBookRow];
            
            
        }
        */
        
        [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[[dictVerse valueForKey:@"chapter"] intValue]]];
        
        
        NSMutableDictionary *dictthird = [NSMutableDictionary dictionaryWithCapacity:1];
               
        NSNumber *verseid =  [NSNumber numberWithInt:[[dictVerse valueForKey:@"verse_id"] intValue]];
        [dictthird setValue:verseid forKey:@"verse_id"];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        [appDelegate openVerseForiPadSavedLocation];
    }
    
    
    	
}
-(void)copy:(id)sender{
    
    NSArray *arraySelectedIndesPath = [self.tableViewSearch indexPathsForSelectedRows];
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    NSString *secondaryL = kLangNone;
    if(dictPref !=nil ){
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
    }
    
    
    NSMutableString *verseStr = [[NSMutableString alloc] init ];
    //(@"arrayResults = %@", arrayResults);
    
    
   // NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
    
    //[verseStr appendFormat:@"%@", self.selectedBook.shortName];
    //[verseStr appendFormat:@" %i", self.chapterId];
    
    NSUInteger countV = [arraySelectedIndesPath count];
    
    if(countV == 0){
        
        
    }else if(countV == 1 && [secondaryL isEqualToString:kLangNone]){
        
        NSIndexPath *indexPath = [arraySelectedIndesPath objectAtIndex:0];
        
        NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
        
        [verseStr appendFormat:@"%@ %@\n", [[arrayResults objectAtIndex:indexPath.section] objectForKey:@"headerTitle"], [dictVerse valueForKey:@"verse_text"]];
        
    }else{
        
        [verseStr appendFormat:@"\n"];
        for(NSUInteger i=0; i<countV ; i++ ){
            
            NSIndexPath *indexPath = [arraySelectedIndesPath objectAtIndex:i];
            
            NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
            
            [verseStr appendFormat:@"%@ %@\n", [[arrayResults objectAtIndex:indexPath.section] objectForKey:@"headerTitle"], [dictVerse valueForKey:@"verse_text"]];
        }
    }
    MBLog(@"verseStr = %@", verseStr);
    
    [[UIPasteboard generalPasteboard] setString:verseStr];
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if(![searchBarr isFirstResponder]){
        if (action == @selector(copy:)){
             return YES;
        }
        
    }
    return NO;
}
- (BOOL)canBecomeFirstResponder {
    
    return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(![searchBarr isFirstResponder]){
        
        
        UIMenuController *theMenu = [UIMenuController sharedMenuController];
        
        CGRect selectionRect = cell.frame;//CGRectMake(currentSelection.x, currentSelection.y, SIDE, SIDE);
        
        [theMenu setTargetRect:selectionRect inView:tableView];
        [theMenu setMenuVisible:YES animated:YES];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [searchBarr resignFirstResponder];
        [self.tableViewSearch becomeFirstResponder];
        
    }
    
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

   
    return [arrayResults count];
   
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
/*
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    //http://stackoverflow.com/questions/2955354/showing-custom-menu-on-selection-in-uiwebview-in-iphone
    if (webView.superview != nil && ![urlTextField isFirstResponder]) {
        if (action == @selector(customAction1:) || action == @selector(customAction2:)) {
            return YES;
        }
    }
    ////(@"clicked me action...sender = %@", sender);
    return NO;//[super canPerformAction:action withSender:sender];
}
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    /*VerseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[VerseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
    }
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
    NSString *versee = [dictVerse valueForKey:@"verse_html"];
    
    cell.tag = indexPath.row;
    
    NSLog(@"ssss = %@", versee);
    
    [cell.webView loadHTMLString:versee  baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]]];
    
    cell.verseText = [dictVerse valueForKey:@"verse_text"];
    // Configure the cell...
    */
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIFont *cellFont = [UIFont fontWithName:kFontName size:FONT_SIZE];
        cell.textLabel.font = cellFont;
    }
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    NSDictionary *dictVerse = [[[arrayResults objectAtIndex:indexPath.section] objectForKey:@"rowValues"] objectAtIndex:indexPath.row];
    //NSString *versee = [dictVerse valueForKey:@"verse_html"];
    
    cell.tag = indexPath.row;
        
    //[cell.webView loadHTMLString:versee  baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]]];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [dictVerse valueForKey:@"verse_text"];
    
    return cell;
}
#pragma mark UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if([arrayResults count] > 0){
        
        self.arrayResults = nil;
        [tableViewSearch reloadData];
        
        
    }
    
    if([self.primaryL isEqualToString:kLangPrimary]){
        
        long flags = FL_DEFAULT;
        char *output = mozhi_unicode_parse([searchText UTF8String], flags);
        NSString *outputStr = [NSString stringWithUTF8String:output];
        
        
        labelSearch.text = outputStr;
    }else{
        
        labelSearch.text = searchText;
    }
       
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    
    if([@"mbediton***" isEqualToString:searchBar.text]){
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setValue:@"mbediton***" forKey:@"easteregg"];
        [def synchronize];
         
        return;
    }else if([@"mbeditoff***" isEqualToString:searchBar.text]){
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def removeObjectForKey:@"easteregg"];
        [def synchronize];
        
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"userdata"];
        BOOL isDire = YES;
        
        if(![fileManager fileExistsAtPath:documentsDirectory isDirectory:&isDire]){
            
            [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        NSString *localStringPath = [documentsDirectory stringByAppendingPathComponent:@"myedit.sql"];
        
        if([fileManager fileExistsAtPath:localStringPath]){
            
            [fileManager removeItemAtPath:localStringPath error:NULL];
        }
        
        return;
    }
    
    if([arrayResults count] > 0){
        
        self.arrayResults = nil;
        [tableViewSearch reloadData];
        
        
    }
    if([self.primaryL isEqualToString:kLangPrimary]){
        
        long flags = FL_DEFAULT;
        char *output = mozhi_unicode_parse([searchBar.text UTF8String], flags);
        NSString *outputStr = [NSString stringWithUTF8String:output];
        
        
        labelSearch.text = outputStr;
    }else{
        
        labelSearch.text = searchBar.text;
    }
    
    [NSThread detachNewThreadSelector:@selector(showIndicator) toTarget:self withObject:nil];
    
    [self performSelector:@selector(showResult) withObject:nil afterDelay:.1];
    
    [self.searchBarr resignFirstResponder];
    if([UIDeviceHardware isOS7Device]){//+20131114
        [self becomeFirstResponder];//+20101003
    }
    
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    
    
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray   arrayWithObjects:@"All",@"Old", @"New", selectedBook.shortName, nil]];
    segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    if([UIDeviceHardware isOS7Device]){
        //segmentControl.tintColor = window.tintColor;
    }else{
        
        for (UIView *subview in self.searchBarr.subviews) {
            if ([subview conformsToProtocol:@protocol(UITextInputTraits)]) {
                
                UITextField *fieldSearch = (UITextField *)subview;
                UILabel *lblCount = (UILabel *)[fieldSearch viewWithTag:tagLabelCount];
                [lblCount removeFromSuperview];
            }
        }
        
        segmentControl.tintColor = [UIColor darkGrayColor];
    }
    
    //  control.momentary = YES;
    [segmentControl addTarget:self action:@selector(segementClicked:) forControlEvents:UIControlEventValueChanged];
    
    //+20131114
    if([UIDeviceHardware isOS6Device]){
        searchBar.inputAccessoryView = segmentControl;//ios6
    }else{
        for (UIView* v in searchBar.subviews) {
            if ([v isKindOfClass:[UITextField class]]) {
                ((UITextField*)v).inputAccessoryView = segmentControl;
            }
        }
    }
    
    
    segmentControl.selectedSegmentIndex = self.scopeValue;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    [self.navigationController popViewControllerAnimated:YES];
    /*[self.searchDisplayController setActive:NO];
    
    
    for (UIView *subview in self.searchDisplayController.searchBar.subviews) { 
        if ([subview conformsToProtocol:@protocol(UITextInputTraits)]) { 
            
            UITextField *fieldSearch = (UITextField *)subview;
            UILabel *lblCount = (UILabel *)[fieldSearch viewWithTag:tagLabelCount];
            [lblCount removeFromSuperview];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    */
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    /*self.arrayResults = nil;
    
    [self.tableViewSearch setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
    [self.tableViewSearch setRowHeight:1200];
    [self.tableViewSearch setScrollEnabled:NO];
    [self.tableViewSearch reloadData];
    //if([self.primaryL isEqualToString:kLangMalayalam]){
        [self.tableViewSearch addSubview:labelSearch];
    //}
    
    for (UIView *subview in self.searchDisplayController.searchBar.subviews) { 
        if ([subview conformsToProtocol:@protocol(UITextInputTraits)]) { 
            
            UITextField *fieldSearch = (UITextField *)subview;
            UILabel *lblCount = (UILabel *)[fieldSearch viewWithTag:tagLabelCount];
            [lblCount removeFromSuperview];
        }
    }*/
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    if([UIDeviceHardware isOS7Device]){//+20131114
        [self becomeFirstResponder];//+20101003
    }
    if(![UIDeviceHardware isOS7Device]){
        [self performSelector:@selector(enableCancelButton:) withObject:searchBar afterDelay:0.5];
    }
    
}


#pragma mark @selector method
- (void)enableCancelButton:(UISearchBar *)aSearchBar {
    for (id subview in [aSearchBar subviews]) {
        
        MBLog(@"klydiaaa %@", NSStringFromClass([subview class]));
        for (id subview1 in [subview subviews]) {
            
            MBLog(@"klydiaaa 11 %@", NSStringFromClass([subview1 class]));
        }
        //if ([subview isKindOfClass:[UIControl class]]) {
            
            MBLog(@"enabling..");
            [subview setEnabled:TRUE];
        //}
    }
}

- (void) segementClicked:(UISegmentedControl *)sender{
    
    self.scopeValue = sender.selectedSegmentIndex;
}
- (void) cancelClicked:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) showHelp:(id)sender{
    //(@"clicked help");
    /*WebViewController *webViewCtrlr = [[WebViewController alloc] init];
    webViewCtrlr.requestURL = [[NSBundle mainBundle] pathForResource:@"lipi" ofType:@"png"];
    [self.navigationController pushViewController:webViewCtrlr animated:YES];*/
    
    /*WebViewController *webViewCtrlr = [[WebViewController alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths objectAtIndex:0];
    NSString *path = [basePath stringByAppendingPathComponent:@"narayam"];
    
    
    path = [path stringByAppendingPathComponent:@"libs"];
    path = [path stringByAppendingPathComponent:@"jquery.ime"];
    path = [path stringByAppendingPathComponent:@"examples"];
    path = [path stringByAppendingPathComponent:@"index.html"];
    
    webViewCtrlr.requestURL = path;
    [self.navigationController pushViewController:webViewCtrlr animated:YES];
     */
}

#pragma mark -
#pragma mark private method


-(void)threadStartAnimating
{
   
    MBLog(@"show indicator..");
	CGRect cgRect = self.tableViewSearch.frame;
	CGSize cgSize = cgRect.size;
    self.activityView.frame=CGRectMake(cgSize.width/2 - 25, cgSize.height/3, 50, 50);
    //self.activityView.frame=CGRectMake(cgSize.width/2, cgSize.height/3, 50, 50);
	
	self.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
	self.activityView.tag  = 1;
    
    [self.view addSubview:self.activityView];
   
    
    [self.activityView startAnimating];
}
-(void)threadStopAnimating
{
    [self.activityView stopAnimating];
    //[self.activityView setHidden:YES];
    [self.activityView removeFromSuperview];
    
    //[self.tableViewSearch setEditing:YES animated:NO];

    [self.tableViewSearch reloadData];
   
}
    
- (void)showIndicator{
    
    
    [self performSelectorOnMainThread:@selector(threadStartAnimating) withObject:nil waitUntilDone:NO];
    
}   
- (void) showResult{
    
    [self performSelectorOnMainThread:@selector(showResultset) withObject:nil waitUntilDone:NO];
    
    
}
- (void) showResultset{
    
    [self filterContentForSearchText:labelSearch.text scope:self.scopeValue AndBookid:self.selectedBook.bookId];
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope AndBookid:(int)bookid
{
    
    
    
    
	BibleDao *bdao = [[BibleDao alloc] init];
    
    
    self.arrayResults = nil;
    if([self.primaryL isEqualToString:kLangPrimary]){
        self.arrayResults = [bdao getSerachResultWithText:labelSearch.text InScope:scope AndBookId:bookid];
    }else{
        self.arrayResults = [bdao getSerachResultWithText:searchText InScope:scope AndBookId:bookid];
    }
    
    //(@"arrayResults = %@", arrayResults);
    //[labelSearch removeFromSuperview];
    
    

    NSUInteger cont = [self getResultDataCount];
    NSString *countStr = [NSString stringWithFormat:@"%i", cont];
    
    if([UIDeviceHardware isOS7Device]){
        
        NSString *existStr = self.labelSearch.text;
        self.labelSearch.text = [NSString stringWithFormat:@"%@ matches - %@", countStr, existStr];
    }else{
    
    for (UIView *subview in self.searchBarr.subviews) {
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



@end
