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

const NSString *bmBookSection = @"BookPathSection";
const NSString *bmBookRow = @"BookPathRow";

@interface MalayalamBibleMasterViewController(Private)

- (void) selectBookWithName:(NSString *)selectedBookName AndChapter:(int)chapter;
- (void) loadData;
@end

@implementation MalayalamBibleMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize infoViewController = _infoViewController;
@synthesize chapterSelectionController = _chapterSelectionController;

- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray{
    
    
    NSDictionary *dict = [selectionArray objectAtIndex:0];
    NSLog(@"restore savedLocation dict= %@", dict);
    
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
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            self.chapterSelectionController = [[ChapterSelection alloc] initWithNibName:@"ChapterSelection" bundle:nil];
            self.detailViewController = [[MalayalamBibleDetailViewController alloc] init];
            //WithNibName:@"MalayalamBibleDetailViewController_iPhone" bundle:nil
        }else{
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
    
    
    
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(showInfoView:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
        
    
}

- (void) showInfoView:(id)sender
{
    NSLog(@"Info View");
    self.infoViewController = [[Information  alloc] initWithNibName:@"Information" bundle:nil];
    self.infoViewController.title = @"Information";
    [self.navigationController pushViewController:self.infoViewController animated:YES];
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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.savedLocation replaceObjectAtIndex:0 withObject:[NSMutableDictionary dictionaryWithCapacity:2]];
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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:FONT_SIZE];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    // Configure the cell.
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
    
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:FONT_SIZE];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 10;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    // save off this level's selection to our AppDelegate
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"പഴയനിയമം";
    }
    else {
        return @"പുതിയനിയമം";
    }
}
- (void) selectBookWithName:(NSString *)selectedBookName AndChapter:(int)chapter{
    
    if(selectedBookName){
        
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
                [self.navigationController pushViewController:self.detailViewController animated:YES];
            }
        }else{
            
            
            self.detailViewController.selectedBook = selectedBook;
            self.detailViewController.chapterId = chapter;
            [self.detailViewController configureiPadView];
        }
        
    }
    
}

- (void) loadView
{
    [super loadView];
    
}
- (void) loadData{
    books = [NSMutableDictionary dictionary];
    oldTestament = [NSMutableArray array];
    newTestament = [NSMutableArray array];
    
	NSString *pathname = [[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    const char *dbpath = [pathname UTF8String];
    sqlite3 *bibleDB;
    
    if (sqlite3_open(dbpath, &bibleDB) == SQLITE_OK) {
        sqlite3_stmt *statement;
        NSString *querySQL = @"SELECT AlphaCode, book_id, EnglishShortName, num_chptr, MalayalamShortName, MalayalamLongName FROM books";
        const char *queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(bibleDB, queryStmt, -1, &statement, NULL) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW) {
                NSString *alphaCode = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                int bookId = sqlite3_column_int(statement, 1);
                NSString *englishName = [[NSString alloc] initWithUTF8String:
                                         (const char *) sqlite3_column_text(statement, 2)];
                int numOfChapters = sqlite3_column_int(statement, 3);
                NSString *shortName = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 4)];
                NSString *longName = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 5)];
                
                if(bookId > 39) {
                    [newTestament addObject:shortName];
                }
                else {
                    [oldTestament addObject:shortName];
                }
                
                Book *book = [[Book alloc] init];
                book.alphaCode = alphaCode;
                book.bookId = bookId;
                book.englishName = englishName;
                book.numOfChapters = numOfChapters;
                book.shortName = shortName;
                book.longName = longName;
                
                [books setObject:book forKey:shortName];                
            }
            sqlite3_finalize(statement);
        }        
    }
    sqlite3_close(bibleDB);
    
}
@end
