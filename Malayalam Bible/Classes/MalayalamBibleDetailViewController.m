//
//  MalayalamBibleDetailViewController.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "MalayalamBibleAppDelegate.h"
#import "MalayalamBibleDetailViewController.h"
#import "ChapterPopOverController.h"
#import "UIToolbarCustom.h"
#import "BibleDao.h"

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

@end

@implementation MalayalamBibleDetailViewController


@synthesize masterPopoverController = _masterPopoverController;
@synthesize selectedBook = _selectedBook;
@synthesize chapterId = _chapterId;
@synthesize popoverChapterController = _popoverChapterController;
@synthesize tableViewVerses = _tableViewVerses;


#pragma mark - Managing the detail item


/** To configure iPhone detail view each time **/
- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.selectedBook) {
        self.title = [self.selectedBook shortName];
        if (self.chapterId < 1 || self.chapterId > self.selectedBook.numOfChapters) {
            self.chapterId = 1;
        }
        // save off this level's selection to our AppDelegate
        MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:self.chapterId]];
        [appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSDictionary dictionary]];    
        
        BibleDao *bDao = [[BibleDao alloc] init];
        verses = [bDao getChapter:self.selectedBook.bookId :self.chapterId];
        
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray         arrayWithObjects:[UIImage imageNamed:@"previous.png"],[UIImage imageNamed:@"next.png"], nil]];
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
        
        if(!self.navigationController.toolbarHidden){
        
        [self resetBottomToolbar];
        self.tableViewVerses.editing = NO;
        self.tableViewVerses.allowsMultipleSelectionDuringEditing = NO;
        }
        
        [self.tableViewVerses reloadData];
        
        //To show from the beginning of a chaper
        [self.tableViewVerses scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

/*
- (void) buttonPrevClicked: (id)sender
{
    self.chapterId--;
    [self configureView];
}

- (void) buttonNextClicked: (id)sender
{
    self.chapterId++;
    [self configureView];
}
*/
- (void) nextPrevious:(id)sender
{
    
    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
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

#pragma mark iPad Specific



- (void)showChapters:(UIBarButtonItem *)barBtn{
    
    ChapterPopOverController *picker = [[ChapterPopOverController alloc] initWithNumberOfChapters:self.selectedBook.numOfChapters];
    picker.delegate = self;
    
    if(self.popoverChapterController == nil){
        self.popoverChapterController = [[UIPopoverController alloc] initWithContentViewController:picker];
        
    }else{
        
        [self.popoverChapterController setContentViewController:picker];
    }
    [self.popoverChapterController setPopoverContentSize:CGSizeMake(220, MIN(44*self.selectedBook.numOfChapters, self.view.frame.size.height))];
    
    [self.popoverChapterController presentPopoverFromBarButtonItem:barBtn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)configureiPadView{
    
    if (self.selectedBook) {
        self.title = [self.selectedBook shortName];
        
        
        if (self.chapterId < 1 || self.chapterId > self.selectedBook.numOfChapters) {
            self.chapterId = 1;
        }
        // save off this level's selection to our AppDelegate
        MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:self.chapterId]];
        [appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSDictionary dictionary]];
        
        BibleDao *bDao = [[BibleDao alloc] init];
        verses = [bDao getChapter:self.selectedBook.bookId :self.chapterId];

        
        UIToolbarCustom* tools = [[UIToolbarCustom alloc] initWithFrame:CGRectMake(0, 0, 190, 44)];
        [tools setBackgroundColor:[UIColor clearColor]];
        
        UIBarButtonItem* chapterItem =[[UIBarButtonItem alloc] initWithTitle:[BibleDao getTitleChapterButton] style:UIBarButtonItemStyleBordered target:self action:@selector(showChapters:)];
        
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray         arrayWithObjects:[UIImage imageNamed:@"previous.png"],[UIImage imageNamed:@"next.png"], nil]];
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
        
        NSArray *items = [[NSArray alloc] initWithObjects:chapterItem, flex, controlItem, nil];
        
        [tools setItems:items animated:NO];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
        
        if(!self.navigationController.toolbarHidden){
        self.tableViewVerses.editing = NO;
        self.tableViewVerses.allowsMultipleSelectionDuringEditing = NO;
        [self resetBottomToolbar];
        }
        [self.tableViewVerses reloadData];
        
        //To show from the beginning of a chaper
        [self.tableViewVerses scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ %d",[BibleDao getTitleChapter], self.chapterId];
}


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(verses) {
        
       return [verses count];
    }
    else {
       return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:FONT_SIZE];
    }
    
    cell.textLabel.text = [verses objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma  mark UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

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
        
   
       [copiedVerse appendFormat:@":%@\n", [verses objectAtIndex:indexPath.row]];
        
        pasteboard.string = copiedVerse;
                
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [verses objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:FONT_SIZE];
    CGSize constraintSize = CGSizeMake(self.view.frame.size.width-40, MAXFLOAT);//280
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
       
    return labelSize.height + 10;
    
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
    
    [self.view addSubview:self.tableViewVerses];
    
    
    
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    IF_IOS5_OR_GREATER(
                       self.navigationController.toolbarHidden = NO;
                       self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;               
                       
    )

   
    
    self.tableViewVerses.allowsSelection = NO;
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:recognizer];
	
	
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [self configureView];
    }
   
    //[self.tableView allowsMultipleSelection];
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
 
 - (void)viewDidAppear:(BOOL)animated
 {
 [super viewDidAppear:animated];
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

#pragma mark private methods

- (void) resetBottomToolbar{
    
    NSMutableArray *arrayOfTools = [[NSMutableArray alloc] initWithCapacity:2];
    
    
    UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionPerformed:)];
    
    
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil action:nil];
    [arrayOfTools addObject:flex];
    [arrayOfTools addObject:action];
    
    //self.toolBarBottom.items = arrayOfTools;    
    self.toolbarItems = arrayOfTools;    

}

#pragma mark @selector methods
- (void) actionPerformed:(id)sender{
    
    
    NSMutableArray *arrayOfTools = [[NSMutableArray alloc] initWithCapacity:3];
    
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];
    
    
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil action:nil];
    
    
    UIBarButtonItem *email = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"email", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(emailVerses:)];
    
    
    
    [arrayOfTools addObject:email];
    [arrayOfTools addObject:flex];
    [arrayOfTools addObject:cancel];
    
    self.toolbarItems = arrayOfTools;
    
    
    self.tableViewVerses.editing = YES;
    self.tableViewVerses.allowsMultipleSelectionDuringEditing = YES;
    [self.tableViewVerses reloadData];
    
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

- (void) cancelAction:(id)sender{
    
    [self resetBottomToolbar];
        
    self.tableViewVerses.editing = NO;
    self.tableViewVerses.allowsMultipleSelectionDuringEditing = NO;
    [self.tableViewVerses reloadData];

}

#pragma mark mail actions

-(void)displayComposerSheet:(NSArray *)arraySelectedIndesPath{
	
    
    NSMutableString *emailBody = [[NSMutableString alloc] init ];
    [emailBody appendFormat:@"%@", self.selectedBook.shortName];
    [emailBody appendFormat:@" %i", self.chapterId];
    
    NSUInteger countV = [arraySelectedIndesPath count];
   
    if(countV == 0){
        
        //return ? or mail entire chapter ?
        
    }else if(countV == 1){
        
        NSIndexPath *path = [arraySelectedIndesPath objectAtIndex:0];
        [emailBody appendFormat:@" : %@\n", [verses objectAtIndex:path.row]];
        
    }else{
        
        [emailBody appendFormat:@"\n"];
        for(NSUInteger i=0; i<countV ; i++ ){
            
            NSIndexPath *path = [arraySelectedIndesPath objectAtIndex:i];
            [emailBody appendFormat:@"%@\n", [verses objectAtIndex:path.row]];
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
			break;
		case MFMailComposeResultSent:
			//(@"Result: sent");
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


@end
