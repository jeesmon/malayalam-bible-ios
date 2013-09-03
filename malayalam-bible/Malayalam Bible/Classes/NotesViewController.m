//
//  NotesViewController.m
//  Malayalam Bible
//
//  Created by jijo on 8/23/13.
//
//

#import "NotesViewController.h"
#import "BibleDao.h"
#import "Notes.h"
#import "MalayalamBibleAppDelegate.h"
#import "NotesAddViewController.h"
#import "UIDeviceHardware.h"

@interface NotesViewController ()

@end

@implementation NotesViewController

@synthesize arrayNotes;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        BibleDao *daoo = [[BibleDao alloc] init];
        self.arrayNotes = [daoo getAllNotes];
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addClicked:(UIBarButtonItem *)btn{
    
        
    //Folder
    BibleDao *daoo = [[BibleDao alloc] init];
    
    Folders *folder = [daoo getDefaultFolderOfNotes];
    
    
    MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    //BookMarks *bookMark = [NSEntityDescription insertNewObjectForEntityForName:@"BookMarks" inManagedObjectContext:nil];
    
    Notes *newNot = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:context];

    [newNot setFolder:folder];
    
    NotesAddViewController *contrlr = [[NotesAddViewController alloc] init];
    contrlr.notesNew = newNot;
    contrlr.delegatee = self;
    //contrlr.verseTitle = [self getSelectedVerseTitle];
    UINavigationController *navCtrlr = [[UINavigationController alloc] initWithRootViewController:contrlr];
    //controller.delegate = self;
    
    if([UIDeviceHardware isIpad]){
        
        
        navCtrlr.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    
    [[self navigationController] presentModalViewController:navCtrlr animated:YES];
}
#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if(self.arrayNotes.count == 0){
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.numberOfLines = 0;
        lbl.text = NSLocalizedString(@"no.notes", @"");
        //    UIView *fview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
        //    [fview setBackgroundColor:[UIColor greenColor]];
        return  lbl;
    }
    return nil;
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 300;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayNotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSObject *obj = [self.arrayNotes objectAtIndex:indexPath.row];
    

        
        Notes *notee = (Notes *)obj;

    NSString *desc = notee.notesdescription;
    if(desc){
        
        NSArray *array = [desc componentsSeparatedByString:@"\n"];
        NSString *title = [array objectAtIndex:0];
        
        NSRange rge = [desc rangeOfString:title];
        
        cell.textLabel.text = title;
        cell.detailTextLabel.text = [desc substringFromIndex:rge.length];
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
    
    Notes *notee = [self.arrayNotes objectAtIndex:indexPath.row];
    
    
    NotesAddViewController *contrlr = [[NotesAddViewController alloc] init];
    contrlr.notesNew = notee;
    contrlr.isEditingNote = YES;
    contrlr.delegatee = self;
    [self.navigationController pushViewController:contrlr animated:YES];

}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
    return UITableViewCellEditingStyleDelete;
       
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	    	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Notes *notee = [self.arrayNotes objectAtIndex:indexPath.row];
        
        MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context =  [appDelegate managedObjectContext];
        
        [self.arrayNotes removeObjectAtIndex:indexPath.row];
        [context deleteObject:notee];
        
        NSError *error;
        [context save:&error];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];

    }
}

#pragma mark MBProtocol

- (void)addedNotes:(Notes *)note{
    
    if(note){
        [self.arrayNotes addObject:note];
    }else{
        //BibleDao *daoo = [[BibleDao alloc] init];
        //self.arrayNotes = [daoo getAllNotes];
    }
    
    [self.tableView reloadData];
}
@end
