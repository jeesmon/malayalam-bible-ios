//
//  BibleDao.m
//  Malayalam Bible
//
//  Created by jijo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BibleDao.h"
#import "/usr/include/sqlite3.h"
#import "Book.h"

@implementation BibleDao


- (NSDictionary *)fetchBookNames{
    
   NSMutableDictionary *books = [NSMutableDictionary dictionary];
   NSMutableArray *oldTestament = [NSMutableArray array];
   NSMutableArray *newTestament = [NSMutableArray array];
    
	NSString *pathname = [[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    const char *dbpath = [pathname UTF8String];
    sqlite3 *bibleDB;
    
    if (sqlite3_open(dbpath, &bibleDB) == SQLITE_OK) {
        sqlite3_stmt *statement;
        NSString *querySQL = @"SELECT AlphaCode, book_id, EnglishShortName, num_chptr, MalayalamShortName, MalayalamLongName FROM books";
        const char *queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(bibleDB, queryStmt, -1, &statement, NULL) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *alphaCode = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                int bookId = sqlite3_column_int(statement, 1);
                NSString *englishName = [[NSString alloc] initWithUTF8String:
                                         (const char *) sqlite3_column_text(statement, 2)];
                int numOfChapters = sqlite3_column_int(statement, 3);
                NSString *shortName = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 4)];
                NSString *longName = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 5)];
                
                if(bookId > 39) {
                    [newTestament addObject:shortName];
                }
                else {
                    [oldTestament addObject:shortName];
                }
                
                Book *book = [[Book alloc] init];
                book.alphaCode = alphaCode;
                book.bookId = bookId;
                book.englishName = englishName;
                book.numOfChapters = numOfChapters;
                book.shortName = shortName;
                book.longName = longName;
                
                [books setObject:book forKey:shortName];                
            }
            sqlite3_finalize(statement);
        }else{
            
            NSLog(@"err: %@", sqlite3_errmsg(bibleDB));
        }
    }
    sqlite3_close(bibleDB);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:books, @"books", oldTestament, @"oldTestament", newTestament, @"newTestament", nil];
}

- (NSMutableArray *) getChapter:(int)bookId:(int)chapterId
{
    
    
    
   NSMutableArray *verses = [NSMutableArray array];
    
    NSString *pathname = [[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    const char *dbpath = [pathname UTF8String];
    sqlite3 *bibleDB;
    
    if (sqlite3_open(dbpath, &bibleDB) == SQLITE_OK) {
        sqlite3_stmt *statement;
        NSString *querySQL = [NSString stringWithFormat:@"SELECT verse_id, verse_text FROM verses where book_id = %d AND chapter_id = %d order by verse_id", bookId, chapterId];
        const char *queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(bibleDB, queryStmt, -1, &statement, NULL) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW) {
                int verseId = sqlite3_column_int(statement, 0);
                NSString *verse = [[NSString alloc] initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 1)];
                NSString *verseWithId;
                if(verseId > 0) {
                    verseWithId = [NSString stringWithFormat:@"%d. %@", verseId, verse];
                }
                else {
                    verseWithId = verse;
                }
                [verses addObject:verseWithId];
            }
            sqlite3_finalize(statement);
        }        
    }
    sqlite3_close(bibleDB);
    
    return verses;
}
@end
