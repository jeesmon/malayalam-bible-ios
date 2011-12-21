//
//  MalayalamBibleDetailViewController.h
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "/usr/include/sqlite3.h"
#import "Book.h"
#import "PopOverDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>


#define FONT_SIZE 17.0f

@interface MalayalamBibleDetailViewController : UITableViewController <UISplitViewControllerDelegate, PopOverDelegate, MFMailComposeViewControllerDelegate >// UITableViewDataSource, UITableViewDelegate
{
    NSMutableArray *verses;
    UIToolbar *toolBarBottom;
    UIPopoverController *popoverChapterController;
}


@property (strong, nonatomic) Book *selectedBook;
@property (assign, readwrite) int chapterId;
@property(nonatomic, retain) UIPopoverController *popoverChapterController;
@property(nonatomic, retain) UIToolbar *toolBarBottom;

- (void)showAlert:(NSString *)message;
- (void)getChapter:(int)bookId:(int)chapterId;


- (void)configureiPadView;
- (void)configureView;
@end
