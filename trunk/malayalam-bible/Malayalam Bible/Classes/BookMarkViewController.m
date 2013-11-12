//
//  BookMarkViewController.m
//  Malayalam Bible
//
//  Created by jijo on 4/22/13.
//
//

#import "BookMarkViewController.h"
#import "BibleDao.h"
#import "BookMarks.h"
#import "Folders.h"
#import "MalayalamBibleDetailViewController.h"
#import "MalayalamBibleAppDelegate.h"
#import "MBConstants.h"

@interface BookMarkViewController ()

@end

@implementation BookMarkViewController

@synthesize detailViewController = _detailViewController;
@synthesize arrayBookmarks;

- (id)initWithStyle:(UITableViewStyle)style BMFolder:(Folders *)folder
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        if(folder == nil){
            BibleDao *daoo = [[BibleDao alloc] init];
            self.arrayBookmarks = [daoo getAllBookMarks];
        }else{

            NSArray *af1 = [folder.bookmarks allObjects];
            self.arrayBookmarks = [NSMutableArray arrayWithArray:af1];
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if(arrayBookmarks.count == 0){
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.numberOfLines = 0;
    lbl.text = NSLocalizedString(@"no.bookmarks", @"");
    //    UIView *fview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    //    [fview setBackgroundColor:[UIColor greenColor]];
    return  lbl;
    }
    return nil;
    
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(arrayBookmarks.count == 0){
    return 300;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.arrayBookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSObject *obj = [self.arrayBookmarks objectAtIndex:indexPath.row];
    
    if([obj isMemberOfClass:[Folders class]]){
        
        Folders *fldr = (Folders *)obj;
        cell.textLabel.text = fldr.folder_label;
        
    }else{
        
        BookMarks *bm = (BookMarks *)obj;
        cell.textLabel.text = bm.bmdescription;
        cell.detailTextLabel.text = bm.versetitle;
    }
    
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSObject *obj = [self.arrayBookmarks objectAtIndex:indexPath.row];
    
    if([obj isMemberOfClass:[Folders class]]){
        
        Folders *fldr = (Folders *)obj;
        
        BookMarkViewController *bmctrlr = [[BookMarkViewController alloc] initWithStyle:UITableViewStyleGrouped BMFolder:fldr];
        bmctrlr.detailViewController = self.detailViewController;
        [self.navigationController pushViewController:bmctrlr animated:YES];
        
    }else{
        
        BookMarks *bm = (BookMarks *)obj;
        
        NSNumber *verseidNum = [NSNumber numberWithInt:[bm.verseid intValue]];
        
        MBLog(@"jj verseidNum = %@", verseidNum);
        
        NSMutableDictionary *dictVerseid = [NSMutableDictionary dictionaryWithObject:verseidNum forKey:@"verse_id"];
        
        MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.savedLocation replaceObjectAtIndex:2 withObject:dictVerseid];
        
        
        BibleDao *daoo = [[BibleDao alloc] init];
        Book *bookdetails = [daoo getBookUsingId:[bm.bookid intValue]];
        
        MBLog(@"jj bm.chapter = %@", bm.chapter);
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            
            self.detailViewController.selectedBook = bookdetails;
            self.detailViewController.chapterId = [bm.chapter intValue];
            [self.detailViewController configureView];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            
        }else{
            
            
            MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            Book *selectBook = bookdetails;
            
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
            
            [appDelegate.savedLocation replaceObjectAtIndex:1 withObject:bm.chapter];
            
            
            NSMutableDictionary *dictthird = [NSMutableDictionary dictionaryWithCapacity:1];
            
            NSNumber *verseid =  [NSNumber numberWithInt:[bm.verseid intValue]];
            [dictthird setValue:verseid forKey:@"verse_id"];
            
            
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            [appDelegate openVerseForiPadSavedLocation];
        }

    }
    
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
    return UITableViewCellEditingStyleDelete;
    
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSObject *obj = [self.arrayBookmarks objectAtIndex:indexPath.row];
        
        if([obj isMemberOfClass:[Folders class]]){
            
        }else{
            
            BookMarks *bm = (BookMarks *)obj;
            
            
            MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
            
            NSManagedObjectContext *context =  [appDelegate managedObjectContext];
            
            [self.arrayBookmarks removeObjectAtIndex:indexPath.row];
            [context deleteObject:bm];
            
            NSError *error;
            [context save:&error];
            
             [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        }
        
        
        
    }
}

@end
