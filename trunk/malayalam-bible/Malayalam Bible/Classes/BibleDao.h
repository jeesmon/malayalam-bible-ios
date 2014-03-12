//
//  BibleDao.h
//  Malayalam Bible
//
//  Created by jijo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"
#import "Folders.h"

@interface BibleDao : NSObject

- (BOOL) executeQuery:(NSString *)sql;
- (NSDictionary *)fetchBookNames;
- (NSDictionary *) getChapter:(int)bookId Chapter:(int)chapterId;

+ (NSString *)getTitleBooks;
+ (NSString *)getTitleOldTestament;
+ (NSString *)getTitleNewTestament;
+ (NSString *)getTitleChapter;
+ (NSString *)getTitleChapterButton;
- (NSMutableArray *) getSerachResultWithText:(NSString *)searchText InScope:(NSInteger)scope AndBookId:(int)bookid;
- (Book *)fetchBookWithSection:(NSInteger)section Row:(NSInteger)row;
- (Book *)getBookUsingId:(NSInteger)bookid;


- (Folders *) getDefaultFolder;
- (Folders *) getDefaultFolderOfNotes;
- (NSMutableArray *)getAllNotes;
- (NSMutableArray *)getAllBookMarks;
- (NSMutableArray *)getAllFolders;
- (NSMutableArray *)getAllColordVersesOfBook:(NSInteger)bookiid ChapterId:(NSInteger)chpteriid;
- (NSMutableArray *)getAllColordVersesOfColor:(NSString *)colorcode;
- (Book *)fetchBookWithId:(int)bookid;
@end

//+20130903
@interface UIColor (MyProject)

+(UIColor *) defaultWindowColor;

@end