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
#import "MBConstants.h"

@implementation BibleDao


//remove old table malayalam-bible.db

- (NSDictionary *)fetchBookNames{
    
   NSMutableDictionary *books = [NSMutableDictionary dictionary];
   NSMutableArray *oldTestament = [NSMutableArray array];
   NSMutableArray *newTestament = [NSMutableArray array];
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    NSString *querySQL = nil;
    
    if(dictPref ==nil || [kLangMalayalam isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        querySQL = @"SELECT AlphaCode, book_id, EnglishShortName, num_chptr, MalayalamShortName, MalayalamLongName FROM books";
        
    }else{
    
         querySQL = @"SELECT AlphaCode, book_id, MalayalamShortName, num_chptr, EnglishShortName , MalayalamLongName FROM books";
    }
        
        
	   
    sqlite3 *bibleDB;
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"malayalam-english-bible.db"];
	
		
    success = [fileManager fileExistsAtPath:dbPath];
	
    if (!success){
		
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"malayalam-english-bible.db"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
    
	if (sqlite3_open([dbPath UTF8String], &bibleDB) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        
        
        const char *queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(bibleDB, queryStmt, -1, &statement, NULL) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *alphaCode = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                int bookId = sqlite3_column_int(statement, 1);
                //NSString *englishName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
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
                //book.englishName = englishName;
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
    
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    NSString *querySQL = nil;
       
    if(dictPref ==nil || [kLangMalayalam isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        querySQL = [NSString stringWithFormat:@"SELECT verse_id, verse_text FROM verses where book_id = %d AND chapter_id = %d order by verse_id", bookId, chapterId];
        
    }else if([kLangEnglishASV isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        querySQL = [NSString stringWithFormat:@"SELECT verse_id, verse_text FROM verses_asv where book_id = %d AND chapter_id = %d order by verse_id", bookId, chapterId];
    }else{
        
        querySQL = [NSString stringWithFormat:@"SELECT verse_id, verse_text FROM verses_kjv where book_id = %d AND chapter_id = %d order by verse_id", bookId, chapterId];
    }
    
        
    NSMutableArray *verses = [NSMutableArray array];
    
    sqlite3 *bibleDB;
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"malayalam-english-bible.db"];
	
    
    success = [fileManager fileExistsAtPath:dbPath];
	
    if (!success){
		
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"malayalam-english-bible.db"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
    
	if (sqlite3_open([dbPath UTF8String], &bibleDB) == SQLITE_OK) {
        sqlite3_stmt *statement;
       
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
        }else{
            
            NSLog(@"err: %@", sqlite3_errmsg(bibleDB));
        }
    }
    sqlite3_close(bibleDB);
    
    return verses;
}

+ (NSString *)getTitleBooks{
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    if(dictPref ==nil || [kLangMalayalam isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        return @"പുസ്തകങ്ങൾ";
        
    }         
    return @"Books";
    
    
}
+ (NSString *)getTitleOldTestament{
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    if(dictPref ==nil || [kLangMalayalam isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        return @"പഴയനിയമം";
        
    }         
    return @"Old Testament";
}
+ (NSString *)getTitleNewTestament{
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    if(dictPref ==nil || [kLangMalayalam isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        return @"പുതിയനിയമം";
        
    }         
    return @"New Testament";
}
+ (NSString *)getTitleChapter{
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    if(dictPref ==nil || [kLangMalayalam isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        return @"അദ്ധ്യായം";
        
    }         
    return @"Chapter";
}
+ (NSString *)getTitleChapterButton{
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    if(dictPref ==nil || [kLangMalayalam isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        return @"അദ്ധ്യായങ്ങൾ";
        
    }         
    return @"Chapters";
    
}
@end
