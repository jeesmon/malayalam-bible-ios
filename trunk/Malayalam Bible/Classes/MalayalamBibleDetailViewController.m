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
@synthesize toolBarBottom = _toolBarBottom;


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
        
        
        
        
        [self getChapter:self.selectedBook.bookId :self.chapterId];
        
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
        
        [self resetBottomToolbar];
        self.tableView.editing = NO;
        self.tableView.allowsMultipleSelectionDuringEditing = NO;

        [self.tableView reloadData];
        
        //To show from the beginning of a chaper
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}


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

- (void)getChapter:(int)bookId:(int)chapterId
{
    
    // save off this level's selection to our AppDelegate
    MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:chapterId]];
    [appDelegate.savedLocation replaceObjectAtIndex:2 withObject:[NSDictionary dictionary]];
    
    verses = [NSMutableArray array];
    
    NSString *pathname = [[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    const char *dbpath = [pathname UTF8String];
    sqlite3 *bibleDB;
    
    if (sqlite3_open(dbpath, &bibleDB) == SQLITE_OK) {
        sqlite3_stmt *statement;
        NSString *querySQL = [NSString stringWithFormat:@"SELECT verse_id, verse_text FROM verses where book_id = %d AND chapter_id = %d order by verse_id", bookId, chapterId];
        const char *queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(bibleDB, queryStmt, -1, &statement, NULL) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW) {
                int verseId = sqlite3_column_int(statement, 0);
                NSString *verse = [[NSString alloc] initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 1)];
                NSString *verseWithId;
                if(verseId > 0) {
                    verseWithId = [NSString stringWithFormat:@"%d. %@", verseId, verse];
                }
                else {
                    verseWithId = verse;
                }
                [verses addObject:verseWithId];
            }
            sqlite3_finalize(statement);
        }        
    }
    sqlite3_close(bibleDB);
    
}
#pragma mark User Swipe Handiling
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
	
    if(!self.tableView.isEditing){
        
        if(recognizer.direction ==UISwipeGestureRecognizerDirectionLeft){
            
            self.chapterId++;
        }else{
            self.chapterId--;
        }
        
        /*if (self.chapterId < 1 || self.chapterId > self.selectedBook.numOfChapters) {
         self.chapterId = 1;
         }
         [self getChapter:self.selectedBook.bookId :self.chapterId];
         [self.tableView reloadData];
         //To show from the beginning of a chaper
         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
         */
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
        [self getChapter:self.selectedBook.bookId :self.chapterId];
        
        UIToolbarCustom* tools = [[UIToolbarCustom alloc] initWithFrame:CGRectMake(0, 0, 190, 44)];
        [tools setBackgroundColor:[UIColor clearColor]];
        
        UIBarButtonItem* chapterItem =[[UIBarButtonItem alloc] initWithTitle:@"അദ്ധ്യായങ്ങൾ" style:UIBarButtonItemStyleBordered target:self action:@selector(showChapters:)];
        
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
        
        
        self.tableView.editing = NO;
        self.tableView.allowsMultipleSelectionDuringEditing = NO;
        [self resetBottomToolbar];

        [self.tableView reloadData];
        
        //To show from the beginning of a chaper
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
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
    /*[self getChapter:self.selectedBook.bookId :self.chapterId];
    
    [self.tableView reloadData];
    //To show from the beginning of a chaper
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    */
}
#pragma mark - iPad UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Books", @"പുസ്തകങ്ങൾ");
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
    return [NSString stringWithFormat:@"അദ്ധ്യായം %d", self.chapterId];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [verses objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:FONT_SIZE];
    CGSize constraintSize = CGSizeMake(self.view.frame.size.width-40, MAXFLOAT);//280
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    //if([[tableView cellForRowAtIndexPath:indexPath] isSelected]){
        
        //labelSize.height += 100;
    //}
    
    return labelSize.height + 10;
    
}

 
/* on iPad, if a chapter has 2-3 verses (if table has 2-3 cells), the toolbar will appear on biddle of the screen, so we can add the toolbar to this view instead of set as footer. 
*/
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 45.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    
    if(self.toolBarBottom == nil){
        UIToolbar *toolBarB = [[UIToolbar alloc] init];
        toolBarB.barStyle = UIBarStyleBlackTranslucent;
        
        
        
        toolBarB.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        toolBarB.frame = CGRectMake(0, 0, self.view.frame.size.width, 45);
        
        
        
        
        self.toolBarBottom = toolBarB;

        
        [self resetBottomToolbar];
        
    }
    return self.toolBarBottom;
}


#pragma mark MemoryHandling


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
       
    self.tableView.allowsSelection = NO;
    
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
    
    self.toolBarBottom.items = arrayOfTools;    

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
    
    self.toolBarBottom.items = arrayOfTools;
    
    
    self.tableView.editing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView reloadData];
    
}

- (void) emailVerses:(id)sender{
    
    NSArray *arraySelectedIndesPath = [self.tableView indexPathsForSelectedRows];
    
    
    
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
        
    self.tableView.editing = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self.tableView reloadData];

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
    
	//+20101105
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Bible Verses"];
	
	
	// Set up recipients
	//NSArray *toRecipients = [NSArray arrayWithObject:emailid]; 
	// NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
	// NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
	
	//[picker setToRecipients:toRecipients];
	//[picker setCcRecipients:ccRecipients];	
	//[picker setBccRecipients:bccRecipients];
	
	// Attach an image to the email
	// NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
	// NSData *myData = [NSData dataWithContentsOfFile:path];
	// [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
	
	// Fill out the email body text
	//NSString *emailBody = @"It is raining in sunny California!";
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
