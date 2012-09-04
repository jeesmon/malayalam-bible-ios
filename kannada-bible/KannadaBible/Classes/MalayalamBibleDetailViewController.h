//
//  MalayalamBibleDetailViewController.h
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Book.h"
#import "PopOverDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "MBProtocol.h"



@interface MalayalamBibleDetailViewController : UIViewController <UISplitViewControllerDelegate, PopOverDelegate, MFMailComposeViewControllerDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate, MBProtocol>// 
{
    NSMutableArray *bVerses;

    UIPopoverController *popoverChapterController;
    
    UITableView *tableViewVerses;
    
    //UITableView *tableWebViewVerses;
    
    BOOL isActionClicked;
    BOOL isFromSeachController;
    UIToolbar *bottomToolBar;
}

@property (strong, nonatomic) NSMutableArray *bVerses;
@property(nonatomic, assign) BOOL isActionClicked;
@property(nonatomic, assign) BOOL isFromSeachController;
@property (strong, nonatomic) Book *selectedBook;
@property (assign, readwrite) int chapterId;
@property(nonatomic, retain) UIPopoverController *popoverChapterController;

//@property(nonatomic, retain) UITableView *tableWebViewVerses;
@property(nonatomic, retain) UITableView *tableViewVerses;
@property(nonatomic, retain) UIToolbar *bottomToolBar;

- (void)showAlert:(NSString *)message;



- (void)configureiPadView;
- (void)configureView;
@end
