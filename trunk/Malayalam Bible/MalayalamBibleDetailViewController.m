//
//  MalayalamBibleDetailViewController.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MalayalamBibleDetailViewController.h"

@interface MalayalamBibleDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MalayalamBibleDetailViewController

@synthesize detailItem = _detailItem;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize selectedBook = _selectedBook;
@synthesize chapterId = _chapterId;

@synthesize chapterTableView;

#pragma mark - Managing the detail item

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

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.selectedBook) {
        self.title = [self.selectedBook shortName];
        if (self.chapterId < 1 || self.chapterId > self.selectedBook.numOfChapters) {
            self.chapterId = 1;
        }        
        [self getChapter:self.selectedBook.bookId :self.chapterId];
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
                if(verseId > 0) {
                    [verses addObject:verse];
                }
            }
            sqlite3_finalize(statement);
        }        
    }
    sqlite3_close(bibleDB);
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
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, [verses objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, [verses objectAtIndex:indexPath.row]];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:FONT_SIZE];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 10;
}

@end
