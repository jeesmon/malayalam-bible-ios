//
//  ChapterSelection.h
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "MalayalamBibleDetailViewController.h"

@interface ChapterSelection : UIViewController {
    UIScrollView *scrollViewBar;
    UILabel *lblChapter;
}

@property (nonatomic, retain) UIScrollView *scrollViewBar;
@property (nonatomic, retain) UILabel *lblChapter;

@property (strong, nonatomic) Book *selectedBook;
@property (strong, nonatomic) MalayalamBibleDetailViewController *detailViewController;

-(void) configureView;
- (void)restoreLevelWithSelectionArray:(NSArray *)selectionArray;
@end
