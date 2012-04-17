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

@interface MalayalamBibleMasterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UISearchDisplayDelegate, UISearchBarDelegate > {
    NSMutableDictionary *books;
    NSMutableArray *newTestament;
    NSMutableArray *oldTestament;
    
    BOOL isNeedReload;
    UITableView *tableViewBooks;
    
    //For Search Controller
    BOOL isSearching;
    UISearchDisplayController	*searchDisplayController;
    UILabel *labelSearch;
    NSArray *arrayResults;
    NSString *primaryL;
    BOOL isFirstTime;
    UIActivityIndicatorView *activityView;
    
    
}

@property (strong, nonatomic) MalayalamBibleDetailViewController *detailViewController;
@property (strong, nonatomic) Information *infoViewController;
@property (strong, nonatomic) ChapterSelection *chapterSelectionController;
@property (strong, nonatomic) UITableView *tableViewBooks;
@property (nonatomic, assign) BOOL isNeedReload;
//For Search Controller
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (nonatomic, assign)  BOOL isFirstTime;
@property (nonatomic, assign)  BOOL isSearching;
@property (nonatomic, retain) UISearchDisplayController	*searchDisplayController;
@property (nonatomic, retain) UILabel *labelSearch;
@property (nonatomic, retain) NSArray *arrayResults;
@property (nonatomic, retain) NSString *primaryL;

- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray;

@end
