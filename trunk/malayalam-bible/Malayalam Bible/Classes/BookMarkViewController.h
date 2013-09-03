//
//  BookMarkViewController.h
//  Malayalam Bible
//
//  Created by jijo on 4/22/13.
//
//

#import <UIKit/UIKit.h>
@class MalayalamBibleDetailViewController;
@class Folders;

@interface BookMarkViewController : UITableViewController{
    
    NSMutableArray *arrayBookmarks;
}
@property(nonatomic, retain) NSMutableArray *arrayBookmarks;
@property (nonatomic, strong) MalayalamBibleDetailViewController *detailViewController;

- (id)initWithStyle:(UITableViewStyle)style BMFolder:(Folders *)folder;

@end
