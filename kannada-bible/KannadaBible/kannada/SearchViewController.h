//
//  SearchViewController.h
//  Malayalam Bible
//
//  Created by jijo on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MalayalamBibleDetailViewController.h"


@interface SearchViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>{
 

    UISearchDisplayController	*searchDisplayController;
    UILabel *labelSearch;
    NSArray *arrayResults;
    NSString *primaryL;
    BOOL isFirstTime;
    UIActivityIndicatorView *activityView;
}
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) MalayalamBibleDetailViewController *detailViewController;
@property (nonatomic, assign)  BOOL isFirstTime;
@property (nonatomic, retain) UISearchDisplayController	*searchDisplayController;
@property (nonatomic, retain) UILabel *labelSearch;
@property (nonatomic, retain) NSArray *arrayResults;
@property (nonatomic, retain) NSString *primaryL;

@end
