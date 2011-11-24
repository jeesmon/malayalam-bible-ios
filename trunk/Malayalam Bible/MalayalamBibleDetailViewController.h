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
#import "SwipeController.h"

#define FONT_SIZE 17.0f

@interface MalayalamBibleDetailViewController : SwipeController <UISplitViewControllerDelegate, PopOverDelegate>
{
    NSMutableArray *verses;
    //UITableView *chapterTableView;
    UIPopoverController *popoverChapterController;
}


@property (strong, nonatomic) Book *selectedBook;
@property (assign, readwrite) int chapterId;
@property(nonatomic, retain) UIPopoverController *popoverChapterController;

//@property (nonatomic, retain) IBOutlet UITableView *chapterTableView;

- (void)showAlert:(NSString *)message;
- (void)getChapter:(int)bookId:(int)chapterId;
- (void)chapterSelectionCallback:(int)chapterId;

- (void)configureiPadView;

@end
