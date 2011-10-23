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
#import "ChapterPickerController.h"

#define FONT_SIZE 17.0f

@interface MalayalamBibleDetailViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDelegate>
{
    NSMutableArray *verses;
    UIView *pickerViewContainer;
    ChapterPickerController *chapterPickerController;
    UIView *chapterPickerViewContainer;
    UITableView *chapterTableView;
}

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) Book *selectedBook;
@property (assign, readwrite) int chapterId;

@property (nonatomic, retain) IBOutlet UIView *pickerViewContainer;
@property (nonatomic, retain) IBOutlet ChapterPickerController *chapterPickerController;
@property (nonatomic, retain) IBOutlet UIView *chapterPickerViewContainer;
@property (nonatomic, retain) IBOutlet UITableView *chapterTableView;

- (void)showAlert:(NSString *)message;
- (void)getChapter:(int)bookId:(int)chapterId;
- (void)chapterSelectionCallback:(int)chapterId;

@end
