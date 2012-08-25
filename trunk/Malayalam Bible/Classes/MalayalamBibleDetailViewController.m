//
//  MalayalamBibleDetailViewController.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "MalayalamBibleAppDelegate.h"
#import "MalayalamBibleDetailViewController.h"
#import "ChapterSelection.h"
#import "UIToolbarCustom.h"
#import "BibleDao.h"
#import "MBConstants.h"
#import "VerseCell.h"
#import "MalayalamBibleMasterViewController.h"
#import "SettingsViewController.h"
#import "UIDeviceHardware.h"
#import "SearchViewController.h"
//#import "SelectableCell.h"

//#import "MEDropDown.h"

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_5_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_5_0 675.000000
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0 //50000

#define IF_IOS5_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_5_0) \
{ \
__VA_ARGS__ \
}
#else
#define IF_IOS5_OR_GREATER(...)
#endif

@interface MalayalamBibleDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void) resetBottomToolbar;
-(void)displayComposerSheet:(NSArray *)arraySelectedIndesPath;
- (void) scrollToVerseId;

@end

@implementation MalayalamBibleDetailViewController


@synthesize masterPopoverController = _masterPopoverController;
@synthesize selectedBook = _selectedBook;
@synthesize chapterId = _chapterId;
@synthesize popoverChapterController = _popoverChapterController;
@synthesize tableViewVerses = _tableViewVerses;
@synthesize isActionClicked = _isActionClicked;
@synthesize isFromSeachController = _isFromSeachController;
@synthesize bVerses = _bVerses;
@synthesize bottomToolBar = _bottomToolBar;
//@synthesize tableWebViewVerses = _tableWebViewVerses;

#pragma mark - Managing the detail item

/** To configure iPhone detail view each time **/
- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.selectedBook) {
        
        if (self.chapterId < 1 || self.chapterId > self.selectedBook.numOfChapters) {
            self.chapterId = 1;
        }
        //self.title = [NSString stringWithFormat:@"%@ - %i" ,[self.selectedBook shortName], self.chapterId];
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
        //lblTitle.font = [UIFont boldSystemFontOfSize:8];
        lblTitle.minimumFontSize = 8.0;
        lblTitle.text = [NSString stringWithFormat:@"%@ - %i" ,[self.selectedBook shortName], self.chapterId];
        lblTitle.textAlignment = UITextAlignmentCenter;
        lblTitle.numberOfLines  = 1;
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:17.0];
        lblTitle.adjustsFontSizeToFitWidth = YES;
        
        //UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
        //viewTitle.backgroundColor = [UIColor redColor];
        /*MEDropDown *referenceBtn = [MEDropDown buttonWithType:UIButtonTypeCustom];
        [referenceBtn drawWithFrame:CGRectMake(0, 0, 120, 40) andImage:[UIImage imageNamed:@"down-arrow.png"]];
        [referenceBtn setborderWithColor:[UIColor blackColor]];
        
        //[referenceBtn addTarget:self action:@selector(showListBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [referenceBtn setTitle:[self.selectedBook shortName] forState:UIControlStateNormal];
        [referenceBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [referenceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        */
         //[viewTitle addSubview:lblTitle];
        
        self.navigationItem.titleView = lblTitle;
        // save off this level's selection to our AppDelegate
        MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:self.chapterId]];
        //[appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSDictionary dictionary]];    
        
        BibleDao *bDao = [[BibleDao alloc] init];
        self.bVerses = [bDao getChapter:self.selectedBook.bookId :self.chapterId];
        
        /*UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray         arrayWithObjects:[UIImage imageNamed:@"previous.png"],[UIImage imageNamed:@"next.png"], nil]];
        control.segmentedControlStyle = UISegmentedControlStyleBar;
        control.momentary = YES;
        [control addTarget:self action:@selector(nextPrevious:) forControlEvents:UIControlEventValueChanged];
        
        if(self.chapterId <= 1) {
            [control setEnabled:NO forSegmentAtIndex:0];
        }
        
        if(self.chapterId >= self.selectedBook.numOfChapters) {
            [control setEnabled:NO forSegmentAtIndex:1];
        }
        
        UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];
        
        self.navigationItem.rightBarButtonItem = controlItem;
        */
        //if(!self.navigationController.toolbarHidden){
        
        [self resetBottomToolbar];
        self.tableViewVerses.editing = NO;
        IF_IOS5_OR_GREATER(
        self.tableViewVerses.allowsMultipleSelectionDuringEditing = NO;
                           )
        //}
        
        [self.tableViewVerses reloadData];
        
        //To show from the beginning of a chaper
        [self.tableViewVerses scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        /***** New WebView Table
        [self.tableWebViewVerses reloadData];
        [self.tableWebViewVerses scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO]; ****/
        
    }
}

- (void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message 
                                                    message:message 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark User Swipe Handiling
/** this is useless without animation 
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
	
    if(!self.tableViewVerses.isEditing){
        
        if(recognizer.direction ==UISwipeGestureRecognizerDirectionLeft){
            
            self.chapterId++;
        }else{
            self.chapterId--;
        }
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self configureiPadView];
        }
        else {
            [self configureView];
        }
    }
    
}
*/
#pragma mark iPad Specific




- (void)configureiPadView{
    
    if (self.selectedBook) {
               
        
        if (self.chapterId < 1 || self.chapterId > self.selectedBook.numOfChapters) {
            self.chapterId = 1;
        }
        self.title = [NSString stringWithFormat:@"%@ - %i" ,[self.selectedBook shortName], self.chapterId];
        
        // save off this level's selection to our AppDelegate
        MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:self.chapterId]];
        //[appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSDictionary dictionary]];
        
        BibleDao *bDao = [[BibleDao alloc] init];
        self.bVerses = [bDao getChapter:self.selectedBook.bookId :self.chapterId];
        
        
        //UIToolbarCustom* tools = [[UIToolbarCustom alloc] initWithFrame:CGRectMake(0, 0, 190, 44)];
        //[tools setBackgroundColor:[UIColor clearColor]];
        if(self.selectedBook.numOfChapters > 1){
            
            UIBarButtonItem* chapterItem =[[UIBarButtonItem alloc] initWithTitle:[BibleDao getTitleChapterButton] style:UIBarButtonItemStyleBordered target:self action:@selector(showChapters:)];
            self.navigationItem.rightBarButtonItem = chapterItem;
        }
        
        
        //UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        /*UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray         arrayWithObjects:[UIImage imageNamed:@"previous.png"],[UIImage imageNamed:@"next.png"], nil]];
        control.segmentedControlStyle = UISegmentedControlStyleBar;
        control.tintColor = [UIColor darkGrayColor];
        control.momentary = YES;
        [control addTarget:self action:@selector(nextPrevious:) forControlEvents:UIControlEventValueChanged];
        
        if(self.chapterId <= 1) {
            [control setEnabled:NO forSegmentAtIndex:0];
        }
        
        if(self.chapterId >= self.selectedBook.numOfChapters) {
            [control setEnabled:NO forSegmentAtIndex:1];
        }
        
        UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];
        */
        //NSArray *items = [[NSArray alloc] initWithObjects:chapterItem, flex, nil];
        
        //[tools setItems:items animated:NO];
        
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
        
        //if(!self.navigationController.toolbarHidden){
        self.tableViewVerses.editing = NO;
        IF_IOS5_OR_GREATER(
        self.tableViewVerses.allowsMultipleSelectionDuringEditing = NO;
                           )
        [self resetBottomToolbar];
        //}
        [self.tableViewVerses reloadData];
       
        //To show from the beginning of a chaper
        //+20120326[self.tableViewVerses scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        /***** New WebView Table
        [self.tableWebViewVerses reloadData];
        //To show from the beginning of a chaper
        [self.tableWebViewVerses scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO]; ****/
        
        [self scrollToVerseId];
        
    }
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}



#pragma mark PopOverDelegate

-(void)dismissWithChapter:(NSUInteger)chapterId{
    
    
    self.chapterId = chapterId;
    
    [self.popoverChapterController dismissPopoverAnimated:YES]; 
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self configureiPadView];
    }
    else {
        [self configureView];
    }
 
}
#pragma mark - iPad UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = [BibleDao getTitleBooks];
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma Mark UITableDataSource
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ %d",[BibleDao getTitleChapter], self.chapterId];
}
*/

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.bVerses) {
        
       return [self.bVerses count];
    }
    else {
       return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    /*NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%i", FONT_SIZE];
    
    
    SelectableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SelectableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier AndCallBack:self];
        
    }
    
     
    NSDictionary *dictVerse = [self.bVerses objectAtIndex:indexPath.row];
    cell.verseDict = dictVerse;
    cell.lblVerse1.tag = indexPath.row;
    cell.lblVerse2.tag = indexPath.row;
    
    return cell;
    */
   if(self.isActionClicked){
        
       
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%i", FONT_SIZE];
        
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:kFontName size:FONT_SIZE];
        }
        
        NSDictionary *dictVerse = [self.bVerses objectAtIndex:indexPath.row];
        cell.textLabel.text = [dictVerse valueForKey:@"verse_text"];
        
        return cell;
        
    }else{
        
        
        static NSString *CellIdentifier = @"WebCell";
        
        
        VerseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
           
            cell = [[VerseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
                                  
        }
       
        NSDictionary *dictVerse = [self.bVerses objectAtIndex:indexPath.row];
        
        NSString *versee = [dictVerse valueForKey:@"verse_html"];
                
        [cell.webView loadHTMLString:versee  baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]]];
       
        cell.verseText = [dictVerse valueForKey:@"verse_text"];
         
        
        return cell;
         
    }
    
    
}

#pragma  mark UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    //IF_IOS5_OR_GREATER(
    return 44.0;
    //                   )
   // return 0.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    //IF_IOS5_OR_GREATER(
    UIView *fview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableViewVerses.frame.size.width, 45)];
    [fview setBackgroundColor:[UIColor clearColor]];
    return  fview;
    //)
    //return nil;
}
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
/*
//No use after implement tablewebview
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)){
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        
        NSMutableString *copiedVerse = [[NSMutableString alloc] init ];
        [copiedVerse appendFormat:@"%@", self.selectedBook.shortName];
        [copiedVerse appendFormat:@" %i", self.chapterId];
                
        
        NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
        NSString *secondaryL = kLangNone;
        if(dictPref !=nil ){
            secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
        }
        
        NSDictionary *dictVerse = [self.bVerses objectAtIndex:indexPath.row];
        
        if(secondaryL == kLangNone) {
            [copiedVerse appendFormat:@":%@\n", [dictVerse valueForKey:@"verse_text"]];
        }
        else {
            [copiedVerse appendFormat:@"\n%@\n", [dictVerse valueForKey:@"verse_text"]];
        }
        
        pasteboard.string = copiedVerse;
                
    }
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.isActionClicked){
        
        NSDictionary *dictVerse = [self.bVerses objectAtIndex:indexPath.row];
        NSString *cellText = [dictVerse valueForKey:@"verse_text"];
        
        UIFont *cellFont = [UIFont fontWithName:kFontName size:FONT_SIZE];
        CGSize constraintSize = CGSizeMake(self.view.frame.size.width-60, MAXFLOAT);//280
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        return labelSize.height + 10;
        
    }else{
      
        NSDictionary *dictVerse = [self.bVerses objectAtIndex:indexPath.row];
        
        NSString *verseStr = [dictVerse valueForKey:@"verse_text"];
        NSString *verseStr2 = [dictVerse valueForKey:@"verse_text2"];
        
        UIFont *cellFont = [UIFont fontWithName:kFontName size:FONT_SIZE];
        
        CGSize constraintSize = CGSizeMake(self.view.frame.size.width-40, MAXFLOAT);//280 - 40
        
        CGSize labelSize = [verseStr sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        CGSize labelSize2 = [verseStr2 sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
              
        return labelSize.height + labelSize2.height + 15 ;//+ 10
    }
}

#pragma mark MemoryHandling


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) loadView{
    
    [super loadView];
    
    CGRect cgRect = self.view.frame;
    
    
	
	UIView *myView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, cgRect.size.width, cgRect.size.height)]; //initilize the view    
	myView.autoresizesSubviews = YES;              //allow it to tweak size of elements in view 
	myView.backgroundColor = [UIColor whiteColor];
	myView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.view = myView;
    
    
    
    self.tableViewVerses = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];//
    self.tableViewVerses.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableViewVerses.delegate = self;
    self.tableViewVerses.dataSource = self;
    
    
    self.bottomToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-45, self.view.frame.size.width, 46)];
    self.bottomToolBar.barStyle =  UIBarStyleBlack;
    self.bottomToolBar.translucent = YES;
    self.bottomToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:self.bottomToolBar];
    
    
    [self.view addSubview:self.tableViewVerses];
    
    [self.view bringSubviewToFront:self.bottomToolBar];

    
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    IF_IOS5_OR_GREATER(
                       //self.navigationController.toolbarHidden = NO;
                       //self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;               
                       
                       )

   
    
    self.tableViewVerses.allowsSelection = NO;
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    NSString *secondaryL = kLangNone;
    if(dictPref !=nil ){
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
        
    }
    if([secondaryL isEqualToString:kLangNone]){
       
        self.tableViewVerses.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        
        self.tableViewVerses.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    //self.tableViewVerses.backgroundColor = [UIColor grayColor];
    //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        
    /* No Use
     UITableViewCellSeparatorStyleNone,
     UITableViewCellSeparatorStyleSingleLine,
     UITableViewCellSeparatorStyleSingleLineEtched
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:recognizer];
	
	
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    */
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        //+20120508
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:[BibleDao getTitleBooks] style:UIBarButtonItemStyleBordered target:self action:@selector(openBooks)];
       
        [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
        
        UIBarButtonItem *barButtonItemR = [[UIBarButtonItem alloc] initWithTitle:[BibleDao getTitleChapter] style:UIBarButtonItemStyleBordered target:self action:@selector(openChapters)];
        
        [self.navigationItem setRightBarButtonItem:barButtonItemR animated:YES];
        
        [self configureView];
    }else{
        
        //Adding observer to notify the language changes
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList:) name:@"NotifyTableReload" object:nil];
    }
    if(!isFromSeachController){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList:) name:@"NotifyTableReload" object:nil];
    }
    //[self.tableView allowsMultipleSelection];
    
    [self resetBottomToolbar];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
if (![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
IF_IOS5_OR_GREATER(
                   
                   //self.navigationController.toolbarHidden = NO;
                   //self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;               
                   
                   )
}
    
    
    //scroll to selected verse from search or from saved point
    [self scrollToVerseId];
}

  /*
 - (void)viewDidUnload
 {
     [super viewDidUnload];
 }

 - (void)viewWillAppear:(BOOL)animated
 {
 [super viewWillAppear:animated];
 }
 

 
 - (void)viewWillDisappear:(BOOL)animated
 {
 [super viewWillDisappear:animated];
 }
 
 - (void)viewDidDisappear:(BOOL)animated
 {
 [super viewDidDisappear:animated];
 }
 */
#pragma Rotation Support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }*/
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self.tableViewVerses reloadData];
}
#pragma mark private methods
- (void) scrollToVerseId{
    
    MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *dict = [appDelegate.savedLocation objectAtIndex:2];   
    
        
    NSNumber *verseid = [dict valueForKey:@"verse_id"];
    NSUInteger rowid =  [verseid intValue];
    if(rowid > 0){
        --rowid;
    }
    
    /*
    if(rowid < [self.bVerses count]){
        
        
        [self.tableViewVerses scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowid inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        [appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSDictionary dictionary]];
    }else{
        [self.tableViewVerses scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.bVerses count] -1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        [appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSDictionary dictionary]];
    }*/
}
- (void) resetBottomToolbar{
    
    NSMutableArray *arrayOfTools = [[NSMutableArray alloc] initWithCapacity:2];
    
    
    UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionPerformed:)];
        
   
    UIImage *imgin = [UIImage imageNamed:@"zoom_in.png"];
      
       
    UIBarButtonItem *btnZoomInnn = [[UIBarButtonItem alloc] initWithImage:imgin style:UIBarButtonItemStylePlain target:self action:@selector(zoominBtnClicked:)];
        
    
    UIImage *imgout = [UIImage imageNamed:@"zoom_out.png"];
    
    UIBarButtonItem *btnZoomouttt = [[UIBarButtonItem alloc] initWithImage:imgout style:UIBarButtonItemStylePlain target:self action:@selector(zoomoutBtnClicked:)];
    
    
    if(FONT_SIZE <= kFontMinSize) {
        [btnZoomouttt setEnabled:NO];
    }
    
    if(FONT_SIZE >= kFontMaxSize) {
        [btnZoomInnn setEnabled:NO];
    }
    
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil action:nil];
    UIBarButtonItem *flex3 = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil action:nil];
    UIBarButtonItem *flex4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                              target:nil action:nil];
    
    UIImage *imgNext = [UIImage imageNamed:@"next.png"];
        
       
    UIBarButtonItem *barbtnNext = [[UIBarButtonItem alloc] initWithImage:imgNext style:UIBarButtonItemStylePlain target:self action:@selector(nextPrevious:)];
     barbtnNext.tag = 1;
    
    
      
    UIImage *imgPrevious = [UIImage imageNamed:@"previous.png"];
    
        
    UIBarButtonItem *barbtnPrevious = [[UIBarButtonItem alloc] initWithImage:imgPrevious style:UIBarButtonItemStylePlain target:self action:@selector(nextPrevious:)];

    
    if(self.chapterId <= 1) {
        [barbtnPrevious setEnabled:NO];
    }
    
    if(self.chapterId >= self.selectedBook.numOfChapters) {
        [barbtnNext setEnabled:NO];
    }
   // if(![UIDeviceHardware isIpad]){
        
        UIImage *imgSettings = [UIImage imageNamed:@"Gear.png"] ;
        UIBarButtonItem *btnSettings = [[UIBarButtonItem alloc] initWithImage:imgSettings style:UIBarButtonItemStylePlain target:self action:@selector(showPreferences:)];
        
        UIBarButtonItem *flex0 = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil action:nil];

        
        [arrayOfTools addObject:btnSettings];
        [arrayOfTools addObject:flex0];
        
            //}
    
    [arrayOfTools addObject:btnZoomouttt];
    [arrayOfTools addObject:flex1];
    [arrayOfTools addObject:btnZoomInnn];
    
    IF_IOS5_OR_GREATER(//+20120825
                       [arrayOfTools addObject:flex2];
    [arrayOfTools addObject:action];
    )
    UIBarButtonItem *flex00 = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];

    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                  target:self action:@selector(doSearch:)];
    
       [arrayOfTools addObject:flex00];
    [arrayOfTools addObject:btnSearch];
    

    
    [arrayOfTools addObject:flex3];
    [arrayOfTools addObject:barbtnPrevious];
    [arrayOfTools addObject:flex4];
    [arrayOfTools addObject:barbtnNext];
    
    //self.toolBarBottom.items = arrayOfTools;    
    self.bottomToolBar.items = arrayOfTools;    
    //[self.bottomToolBar sizeToFit];
}

#pragma mark MBProtocol delegate 

- (void) setSelectedRow:(NSUInteger)roww IsPrimary:(BOOL)isPrimary{
 
    NSMutableDictionary *dictVerse = [self.bVerses objectAtIndex:roww];
    
    if(isPrimary){
        NSLog(@"selected pr");
        [dictVerse setValue:@"YES" forKey:@"isSelectedPrimary"];
    }else{
        NSLog(@"selected no pr");
        [dictVerse setValue:@"NO" forKey:@"isSelectedPrimary"];
    }
      
    [self.tableViewVerses reloadData];
}


#pragma mark @selector methods
- (void) showPreferences:(id)sender{
    
    SettingsViewController *ctrlr = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:ctrlr animated:YES];
    
    
    //SearchViewController *ctrlr = [[SearchViewController alloc] init];
    //ctrlr.detailViewController = self;
    //[self.navigationController pushViewController:ctrlr animated:YES];
}
- (void) doSearch:(id)sender{
    
   
    
    SearchViewController *ctrlr = [[SearchViewController alloc] init];
    ctrlr.detailViewController = self;
    [self.navigationController pushViewController:ctrlr animated:YES];
}
- (void) zoominBtnClicked:(id)sender{
    
    if(FONT_SIZE < kFontMaxSize){
        
        ++FONT_SIZE;
        BibleDao *bDao = [[BibleDao alloc] init];
        self.bVerses = [bDao getChapter:self.selectedBook.bookId :self.chapterId];
        [self.tableViewVerses reloadData];
        
        [[NSUserDefaults standardUserDefaults] setInteger:FONT_SIZE forKey:@"fontSize"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyTableReload" object:nil userInfo:nil];
        
    }
    //if(FONT_SIZE >= kFontMaxSize){
        
        [self resetBottomToolbar];
    //}
}
- (void) zoomoutBtnClicked:(id)sender{
    
    if(FONT_SIZE > kFontMinSize){
        
        --FONT_SIZE;
        BibleDao *bDao = [[BibleDao alloc] init];
        self.bVerses = [bDao getChapter:self.selectedBook.bookId :self.chapterId];
        [self.tableViewVerses reloadData];
        
        [[NSUserDefaults standardUserDefaults] setInteger:FONT_SIZE forKey:@"fontSize"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyTableReload" object:nil userInfo:nil];        
    }
    //if(FONT_SIZE <= kFontMinSize){
        
        [self resetBottomToolbar];
    //}
}
- (void) actionPerformed:(id)sender{
    
    self.isActionClicked = YES;
    NSMutableArray *arrayOfTools = [[NSMutableArray alloc] initWithCapacity:3];
    
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];
    
    
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil action:nil];
    
    
    UIBarButtonItem *email = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"email", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(emailVerses:)];
    
    UIBarButtonItem *copyText = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"copy", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(copySelectedVerses:)];
    
    [arrayOfTools addObject:email];
    [arrayOfTools addObject:copyText];
    [arrayOfTools addObject:flex];
    [arrayOfTools addObject:cancel];
    
    self.bottomToolBar.items = arrayOfTools;
    
    
    self.tableViewVerses.editing = YES;
    IF_IOS5_OR_GREATER(
    self.tableViewVerses.allowsMultipleSelectionDuringEditing = YES;
                       )
    [self.tableViewVerses reloadData];
    
}

- (void) nextPrevious:(id)sender
{
    
    switch(((UIButton *)sender).tag) {
        case 0:
            self.chapterId--;
            break;
        case 1:
            self.chapterId++;
            break;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self configureiPadView];
    }
    else {
        [self configureView];
    }
}

- (void) emailVerses:(id)sender{
    
    NSArray *arraySelectedIndesPath = [self.tableViewVerses indexPathsForSelectedRows];
    
    
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet:arraySelectedIndesPath];
        }
        
    }
}
- (void) copySelectedVerses:(id)sender{

    
    NSArray *arraySelectedIndesPath = [self.tableViewVerses indexPathsForSelectedRows];
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    NSString *secondaryL = kLangNone;
    if(dictPref !=nil ){
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
    }
    
    
    NSMutableString *verseStr = [[NSMutableString alloc] init ];
    [verseStr appendFormat:@"%@", self.selectedBook.shortName];
    [verseStr appendFormat:@" %i", self.chapterId];
    
    NSUInteger countV = [arraySelectedIndesPath count];
    
    if(countV == 0){
       
        
    }else if(countV == 1 && [secondaryL isEqualToString:kLangNone]){
        
        NSIndexPath *path = [arraySelectedIndesPath objectAtIndex:0];
        [verseStr appendFormat:@" : %@\n", [[self.bVerses objectAtIndex:path.row] valueForKey:@"verse_text"]];
        
    }else{
        
        [verseStr appendFormat:@"\n"];
        for(NSUInteger i=0; i<countV ; i++ ){
            
            NSIndexPath *path = [arraySelectedIndesPath objectAtIndex:i];
            [verseStr appendFormat:@"%@\n", [[self.bVerses objectAtIndex:path.row] valueForKey:@"verse_text"]];
        }
    }
       
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
       
    pasteboard.string = verseStr;
}


- (void) cancelAction:(id)sender{
    
    self.isActionClicked = NO;
    
    [self resetBottomToolbar];
        
    self.tableViewVerses.editing = NO;
    IF_IOS5_OR_GREATER(
    self.tableViewVerses.allowsMultipleSelectionDuringEditing = NO;
                       )
    [self.tableViewVerses reloadData];

}

- (void) openBooks{
    
    MalayalamBibleMasterViewController *masterViewController = [[MalayalamBibleMasterViewController alloc] init];
    UINavigationController *temp = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    [self.navigationController presentModalViewController:temp animated:YES];
    
    

}
- (void) openChapters{
    
    ChapterSelection *picker = [[ChapterSelection alloc] init];
    picker.selectedBook = self.selectedBook;
    [picker configureView:NO];
    
    //picker.delegate = self;
    UINavigationController *temp = [[UINavigationController alloc] initWithRootViewController:picker];
    [self.navigationController presentModalViewController:temp animated:YES];
}
- (void)showChapters:(UIBarButtonItem *)barBtn{
    
    ChapterSelection *picker = [[ChapterSelection alloc] init];
    picker.selectedBook = self.selectedBook;
    [picker configureView:NO];
    picker.delegate = self;
    
    if(self.popoverChapterController == nil){
        self.popoverChapterController = [[UIPopoverController alloc] initWithContentViewController:picker];
        
    }else{
        
        [self.popoverChapterController setContentViewController:picker];
    }
    NSUInteger modv = self.selectedBook.numOfChapters % 6;
    NSUInteger ht = (self.selectedBook.numOfChapters / 6) * 50 + 15;
    if(modv > 0) ht += 50;
    [self.popoverChapterController setPopoverContentSize:CGSizeMake(320, MAX(70, ht))];
    
    [self.popoverChapterController presentPopoverFromBarButtonItem:barBtn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


#pragma mark mail actions

-(void)displayComposerSheet:(NSArray *)arraySelectedIndesPath{
	
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    NSString *secondaryL = kLangNone;
    if(dictPref !=nil ){
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
    }
    
    
    NSMutableString *emailBody = [[NSMutableString alloc] init ];
    [emailBody appendFormat:@"%@", self.selectedBook.shortName];
    [emailBody appendFormat:@" %i", self.chapterId];
    
    NSUInteger countV = [arraySelectedIndesPath count];
   
    if(countV == 0){
        
        //return ? or mail entire chapter ?
        
    }else if(countV == 1 && [secondaryL isEqualToString:kLangNone]){
        
        NSIndexPath *path = [arraySelectedIndesPath objectAtIndex:0];
        [emailBody appendFormat:@" : %@\n", [[self.bVerses objectAtIndex:path.row] valueForKey:@"verse_text"]];
        
    }else{
        
        [emailBody appendFormat:@"\n"];
        for(NSUInteger i=0; i<countV ; i++ ){
            
            NSIndexPath *path = [arraySelectedIndesPath objectAtIndex:i];
            [emailBody appendFormat:@"%@\n", [[self.bVerses objectAtIndex:path.row] valueForKey:@"verse_text"]];
        }
    }
    
    
    
    [emailBody appendFormat:@"\n%@", NSLocalizedString(@"MailFooter", @"footer message")];
    
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Bible Verses"];
	
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self.navigationController presentModalViewController:picker animated:YES];
	
	
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    
    switch (result)
	{
		case MFMailComposeResultCancelled:
			//(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			//(@"Result: saved");
            [self cancelAction:self];
			break;
		case MFMailComposeResultSent:
			//(@"Result: sent");
            [self cancelAction:self];
			break;
		case MFMailComposeResultFailed:
			//(@"Result: failed");
			break;
		default:
			//(@"Result: not sent");
			break;
	}
    [[self navigationController] dismissModalViewControllerAnimated:YES];

}

#pragma mark NotifyTableReload

- (void)refreshList:(NSNotification *)note
{
	
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    NSString *secondaryL = kLangNone;
    if(dictPref !=nil ){
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
        
    }
    if([secondaryL isEqualToString:kLangNone]){
        self.tableViewVerses.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        self.tableViewVerses.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
	//NSDictionary *dict = [note userInfo];
    
    BibleDao *bDao = [[BibleDao alloc] init];
    self.bVerses = [bDao getChapter:self.selectedBook.bookId :self.chapterId];
    [self.tableViewVerses reloadData];
    
}
@end
