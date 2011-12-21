//
//  ChapterPopOverController.h
//  Malayalam Bible
//
//  Created by Jijo Pulikkottil on 22/11/11.
//  Copyright (c) 2011 jpulikkottil@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PopOverDelegate.h"

@interface ChapterPopOverController : UITableViewController{
    
    //id <PopOverDelegate> delegate;
    NSMutableArray *arrayChapters;
}

@property (nonatomic, assign) id <PopOverDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *arrayChapters;


- (id)initWithNumberOfChapters:(NSUInteger)count;

@end




