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

@interface MalayalamBibleDetailViewController : UITableViewController <UISplitViewControllerDelegate, PopOverDelegate, MFMailComposeViewControllerDelegate >// 
{
    NSMutableArray *verses;

    UIPopoverController *popoverChapterController;
    
    UITableView *tableViewVerses;
}


@property (strong, nonatomic) Book *selectedBook;
@property (assign, readwrite) int chapterId;
@property(nonatomic, retain) UIPopoverController *popoverChapterController;

@property(nonatomic, retain) UITableView *tableViewVerses;

- (void)showAlert:(NSString *)message;
- (void)getChapter:(int)bookId:(int)chapterId;


- (void)configureiPadView;
- (void)configureView;
@end
