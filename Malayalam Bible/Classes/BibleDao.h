//
//  BibleDao.h
//  Malayalam Bible
//
//  Created by jijo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"

@interface BibleDao : NSObject

- (NSDictionary *)fetchBookNames;
- (NSMutableArray *) getChapter:(int)bookId:(int)chapterId;

+ (NSString *)getTitleBooks;
+ (NSString *)getTitleOldTestament;
+ (NSString *)getTitleNewTestament;
+ (NSString *)getTitleChapter;
+ (NSString *)getTitleChapterButton;
- (NSMutableArray *) getSerachResultWithText:(NSString *)searchText InScope:(NSString *)scope;
- (Book *)fetchBookWithSection:(NSInteger)section Row:(NSInteger)row;
@end
