//
//  MalayalamBibleDetailViewController.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MalayalamBibleDetailViewController.h"
#import "ChapterPopOverController.h"


@interface MalayalamBibleDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MalayalamBibleDetailViewController


@synthesize masterPopoverController = _masterPopoverController;
@synthesize selectedBook = _selectedBook;
@synthesize chapterId = _chapterId;
@synthesize popoverChapterController = _popoverChapterController;

//@synthesize chapterTableView;

#pragma mark - Managing the detail item

/*
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}
*/

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.selectedBook) {
        self.title = [self.selectedBook shortName];
        if (self.chapterId < 1 || self.chapterId > self.selectedBook.numOfChapters) {
            self.chapterId = 1;
        }
        [self getChapter:self.selectedBook.bookId :self.chapterId];

        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
        
        int numOfButtons = 0;
        UIBarButtonItem* bi;
        
        if(self.chapterId > 1) {
            bi = [[UIBarButtonItem alloc] 
                               initWithImage:[UIImage imageNamed:@"previous.png"]
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(buttonPrevClicked:)];
            bi.style = UIBarButtonItemStylePlain;
            [buttons addObject:bi];
            numOfButtons++;
        }
        
        bi = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [buttons addObject:bi];
        
        if(self.chapterId < self.selectedBook.numOfChapters) {
            bi = [[UIBarButtonItem alloc] 
                               initWithImage:[UIImage imageNamed:@"next.png"] 
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(buttonNextClicked:)];
            bi.style = UIBarButtonItemStylePlain;
            [buttons addObject:bi];
            numOfButtons++;
        }
        
        UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, numOfButtons * 30 + 4, 44.01)];
        [tools setItems:buttons animated:NO];
        //[tools setBackgroundColor:[UIColor clearColor]];
       
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
        
        [self.tableView reloadData];
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

- (void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message 
                                                    message:message 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)chapterSelectionCallback:(int)chapterId
{
    NSLog(@"callback");
}

- (void)getChapter:(int)bookId:(int)chapterId
{
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

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
	
    if(recognizer.direction ==UISwipeGestureRecognizerDirectionLeft){
        
        self.chapterId++;
    }else{
        self.chapterId--;
    }
    
    if (self.chapterId < 1 || self.chapterId > self.selectedBook.numOfChapters) {
        self.chapterId = 1;
    }
    [self getChapter:self.selectedBook.bookId :self.chapterId];
	[self.tableView reloadData];
	
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
        //if (self.chapterId < 1 || self.chapterId > self.selectedBook.numOfChapters) {
            self.chapterId = 1;
        //}
        [self getChapter:self.selectedBook.bookId :self.chapterId];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"അദ്ധ്യായങ്ങൾ" style:UIBarButtonItemStyleBordered target:self action:@selector(showChapters:)];
        
        [self.tableView reloadData];
    }
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}



#pragma mark PopOverDelegate

-(void)dismissWithChapter:(NSUInteger)chapterId{
   
    NSLog(@"dismisssss");
    self.chapterId = chapterId;
        
    [self.popoverChapterController dismissPopoverAnimated:YES]; 
    [self getChapter:self.selectedBook.bookId :self.chapterId];
    
    [self.tableView reloadData];

}
#pragma mark - iPad UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"പുസ്തകങ്ങൾ", @"പുസ്തകങ്ങൾ");
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
    
    return labelSize.height + 10;
    
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
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
    [self configureView];
    }
    
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
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

@end
