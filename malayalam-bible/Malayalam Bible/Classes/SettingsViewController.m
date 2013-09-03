//
//  SettingsViewController.m
//  Malayalam Bible
//
//  Created by jijo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
//#import "LanguageViewController.h"
#import "Information.h"
#import "WebViewController.h"
#import "MBConstants.h"
#import "SelectionController.h"
#import "FontSizeCell.h"

#define FontSizeRow 2

@implementation SettingsViewController

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
    
    self.title = @"Settings";
    [super viewDidLoad];

    
    //NSDictionary *dictf = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Languages", @"") ,@"title",NSLocalizedString(@"SelectLanguages", @""), @"subTitle", nil];
    
      
    //arrayPrefs = [NSArray arrayWithObjects:dictf, nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    if(dictPref == nil){
        
        
        dictPref = [[NSMutableDictionary alloc] init];
        [dictPref setValue:kLangPrimary forKey:@"primaryLanguage"];
        [dictPref setValue:kLangNone forKey:@"secondaryLanguage"];
        
        
        
        [[NSUserDefaults standardUserDefaults] setObject:dictPref forKey:kStorePreference];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *selectedPriLan = NSLocalizedString([dictPref valueForKey:@"primaryLanguage"], @"");;
    NSString *selectedSecLan = NSLocalizedString([dictPref valueForKey:@"secondaryLanguage"], @"");
    
    
    
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Primary", @"") ,@"label",selectedPriLan, @"value",[dictPref valueForKey:@"primaryLanguage"], @"languageid", nil];
    
    
    
    NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Secondary", @"") ,@"label",selectedSecLan, @"value",[dictPref valueForKey:@"secondaryLanguage"], @"languageid", nil];
    
    arrayLangs = [NSArray arrayWithObjects:dict1,dict2, nil];

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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setInteger:FONT_SIZE forKey:@"fontSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyTableReload" object:nil userInfo:nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if(section == 0){
        return @"Languages";
    }else if(section == 1){
        return @"Malayalam Typing";
    }else if(section == 3){
        return @"Info";
    }else if(section == FontSizeRow){
        return @"Text Size";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if(section == 0){
        return [arrayLangs count];
        
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == FontSizeRow){
        return 72;
        
    }
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *fontCell = @"";
    if(indexPath.section == FontSizeRow) {
        fontCell = @"YES";
    }
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"CEll%@", fontCell];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        if(indexPath.section == FontSizeRow) {
            cell = [[FontSizeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    
    if(indexPath.section == 0){
        
        
        /*
        // Configure the cell...
        NSDictionary *dict = [arrayPrefs objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict valueForKey:@"title"];
        cell.detailTextLabel.text = [dict valueForKey:@"subTitle"];*/
        
        
        NSDictionary *dict = [arrayLangs objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict valueForKey:@"label"];
        cell.detailTextLabel.text = [dict valueForKey:@"value"];
        // Configure the cell...
        

    }
    else if(indexPath.section == 1){
        cell.textLabel.text = NSLocalizedString(@"SearchHelp", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"MozhiScheme", @"");;
    }
    else if(indexPath.section == 3){
        
        cell.textLabel.text = NSLocalizedString(@"AppInfo", @"");
        cell.detailTextLabel.text = @"";

    }else{
        
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if(indexPath.section == 0){
        /*LanguageViewController *detailViewController = [[LanguageViewController alloc] init];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:detailViewController animated:YES];
         */
        // Navigation logic may go here. Create and push another view controller.
        NSMutableArray *options = [[NSMutableArray alloc] initWithCapacity:4];
        
        NSArray *arrayAllLangs = [NSArray arrayWithObjects:kLangNone, kLangPrimary, kLangEnglishASV, kLangEnglishKJV, nil];
        
        NSDictionary *dict = [arrayLangs objectAtIndex:indexPath.row];
        
        
        
        if([[dict valueForKey:@"label"] isEqualToString:NSLocalizedString(@"Primary", @"")]){
            
            for(NSString *langId in arrayAllLangs){
                
                if(![langId isEqualToString:kLangNone]){
                    
                    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(langId, @""),@"display_value",[ [dict valueForKey:@"languageid"] isEqualToString:langId] ? @"YES" : @"NO", @"isSelected", langId, @"languageid", nil];
                    
                    [options addObject:dict1];
                }
            }
            
            SelectionController *detailViewController = [[SelectionController alloc] initWithStyle:UITableViewStyleGrouped Options:options];
            detailViewController.optionType = 1;
            // Pass the selected object to the new view controller.
            [self.navigationController pushViewController:detailViewController animated:YES];
            
        }else if([[dict valueForKey:@"label"] isEqualToString:NSLocalizedString(@"Secondary", @"")]){
            
            NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
            NSString *primaryL = [dictPref valueForKey:@"primaryLanguage"];
            
            
            for(NSString *langId in arrayAllLangs){
                
                if(![langId isEqualToString:primaryL]){
                    
                    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(langId, @""),@"display_value",[ [dict valueForKey:@"languageid"] isEqualToString:langId] ? @"YES" : @"NO", @"isSelected", langId, @"languageid", nil];
                    
                    [options addObject:dict1];
                }
            }
            
            
            SelectionController *detailViewController = [[SelectionController alloc] initWithStyle:UITableViewStyleGrouped Options:options];
            detailViewController.optionType = 2;
            // Pass the selected object to the new view controller.
            [self.navigationController pushViewController:detailViewController animated:YES];
        }

    }
    else if(indexPath.section == 1){
        WebViewController *webViewCtrlr = [[WebViewController alloc] init];
        webViewCtrlr.title = NSLocalizedString(@"SearchHelp", @"");
        webViewCtrlr.requestURL = [[NSBundle mainBundle] pathForResource:@"lipi" ofType:@"png"];
        [self.navigationController pushViewController:webViewCtrlr animated:YES];
        /*
        //https://github.com/yuvipanda/indic-typing-tool
        WebViewController *webViewCtrlr = [[WebViewController alloc] init];
        
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
    }else if(indexPath.section == FontSizeRow) {
    }else{
        
        Information *infoViewController = [[Information  alloc] initWithNibName:@"Information" bundle:nil];
        infoViewController.title = NSLocalizedString(@"AppInfo", @"");
        [self.navigationController pushViewController:infoViewController animated:YES];
    }
     
     
}

@end
