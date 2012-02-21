//
//  MalayalamBibleMasterViewController.h
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Information.h"
#import "ChapterSelection.h"

@class MalayalamBibleDetailViewController;

@interface MalayalamBibleMasterViewController : UITableViewController {
    NSMutableDictionary *books;
    NSMutableArray *newTestament;
    NSMutableArray *oldTestament;
    
    BOOL isNeedReload;
}

@property (strong, nonatomic) MalayalamBibleDetailViewController *detailViewController;
@property (strong, nonatomic) Information *infoViewController;
@property (strong, nonatomic) ChapterSelection *chapterSelectionController;
@property (nonatomic, assign) BOOL isNeedReload;

- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray;

@end
