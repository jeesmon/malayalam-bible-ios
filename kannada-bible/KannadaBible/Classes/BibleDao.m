//
//  BibleDao.m
//  Malayalam Bible
//
//  Created by jijo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BibleDao.h"
#import "/usr/include/sqlite3.h"

#import "MBConstants.h"
#import "ApplicationInfo.h"


const CGFloat Line_Height = 1.2;

@implementation BibleDao


//remove old table malayalam-bible.db

-(NSString *)getdbpath{
    
    if([ApplicationInfo isMalayalamApp]){
        return [[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    }else{
        return [[NSBundle mainBundle] pathForResource:@"kannada-bible" ofType:@"db" inDirectory:@"/"];
    }
    
}

- (NSDictionary *)fetchBookNames{
    
   NSMutableDictionary *books = [NSMutableDictionary dictionary];
   NSMutableArray *oldTestament = [NSMutableArray array];
   NSMutableArray *newTestament = [NSMutableArray array];
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    NSString *querySQL = @"SELECT AlphaCode, book_id, EnglishShortName, num_chptr, MalayalamShortName, MalayalamLongName FROM books";
    
    NSString *primaryL = kLangPrimary;
    NSString *secondaryL = kLangNone;
    
    if(dictPref !=nil ){
            
        primaryL = [dictPref valueForKey:@"primaryLanguage"];
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
        
    }
             
        
	   
    /*sqlite3 *bibleDB;
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
    
	if (sqlite3_open([dbPath UTF8String], &bibleDB) == SQLITE_OK) {*/
    NSString *pathname = [self getdbpath];//[[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    const char *dbpath = [pathname UTF8String];
    sqlite3 *bibleDB;
    
    if (sqlite3_open(dbpath, &bibleDB) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        
        
        const char *queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(bibleDB, queryStmt, -1, &statement, NULL) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *alphaCode = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                int bookId = sqlite3_column_int(statement, 1);
                NSString *englishName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                int numOfChapters = sqlite3_column_int(statement, 3);
                NSString *mallayalamName = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 4)];
                NSString *longName = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 5)];
                
                NSString *shortName = nil;
                if([primaryL isEqualToString:kLangPrimary]){
                    
                    shortName = mallayalamName;
                    
                }else{
                    shortName = englishName;
                }
                
                NSMutableString *displayValue = [NSMutableString stringWithString:shortName];
                if([secondaryL isEqualToString:kLangPrimary]){
                    
                    [displayValue appendFormat:@"\n%@", mallayalamName];                    
                }else if([secondaryL isEqualToString:kLangEnglishKJV] || [secondaryL isEqualToString:kLangEnglishASV]){
                    [displayValue appendFormat:@"\n%@", englishName];                    
                }
                              
                if(bookId > 39) {
                    [newTestament addObject:displayValue];
                }
                else {
                    [oldTestament addObject:displayValue];
                }
                
                Book *book = [[Book alloc] init];
                book.alphaCode = alphaCode;
                book.bookId = bookId;
                //book.englishName = englishName;
                book.numOfChapters = numOfChapters;
                book.shortName = shortName;
                book.longName = longName;
                
                [books setObject:book forKey:displayValue];                
            }
            sqlite3_finalize(statement);
        }else{
            
            NSLog(@"err: %@", sqlite3_errmsg(bibleDB));
        }
    }
    sqlite3_close(bibleDB);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:books, @"books", oldTestament, @"oldTestament", newTestament, @"newTestament", nil];
}
- (Book *)fetchBookWithSection:(NSInteger)section Row:(NSInteger)row{
    
       
    row++;
    
    int rowid = row;
    if(section > 0){//+20120810
        rowid = 39 + row;
    }
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    NSString *querySQL = nil;
    
    NSString *primaryL = kLangPrimary;
    NSString *secondaryL = kLangNone;
    
    if(dictPref !=nil ){
        
        primaryL = [dictPref valueForKey:@"primaryLanguage"];
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
        
    }
    if([primaryL isEqualToString:kLangPrimary]){
        
        querySQL = @"SELECT AlphaCode, book_id, EnglishShortName, num_chptr, MalayalamShortName, MalayalamLongName FROM books where rowid = ?";
        
    }else{
        querySQL = @"SELECT AlphaCode, book_id, EnglishShortName, num_chptr, MalayalamShortName, MalayalamLongName FROM books where rowid = ?";
    }

    Book *book = [[Book alloc] init];
    
    NSString *pathname = [self getdbpath];//[[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    const char *dbpath = [pathname UTF8String];
    sqlite3 *bibleDB;
    
    if (sqlite3_open(dbpath, &bibleDB) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        
        
        const char *queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(bibleDB, queryStmt, -1, &statement, NULL) == SQLITE_OK){
            
            sqlite3_bind_int(statement, 1, rowid);
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *alphaCode = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                int bookId = sqlite3_column_int(statement, 1);
                NSString *englishName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                int numOfChapters = sqlite3_column_int(statement, 3);
                NSString *mallayalamName = [[NSString alloc] initWithUTF8String:
                                            (const char *) sqlite3_column_text(statement, 4)];
                NSString *longName = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 5)];
                
                NSString *shortName = nil;
                if([primaryL isEqualToString:kLangPrimary]){
                    
                    shortName = mallayalamName;
                    
                }else{
                    shortName = englishName;
                }
                
                NSMutableString *displayValue = [NSMutableString stringWithString:shortName];
                if([secondaryL isEqualToString:kLangPrimary]){
                    
                    [displayValue appendFormat:@"\n%@", mallayalamName];                    
                }else if([secondaryL isEqualToString:kLangEnglishKJV] || [secondaryL isEqualToString:kLangEnglishASV]){
                    [displayValue appendFormat:@"\n%@", englishName];                    
                }
                
               
                
                
                book.alphaCode = alphaCode;
                book.bookId = bookId;
                //book.englishName = englishName;
                book.numOfChapters = numOfChapters;
                book.shortName = shortName;
                book.longName = longName;
                
                              
            }
            sqlite3_finalize(statement);
        }else{
            
            NSLog(@"err: %@", sqlite3_errmsg(bibleDB));
        }
    }
    sqlite3_close(bibleDB);
    
    return book;
}

- (NSMutableArray *) getSerachResultWithText:(NSString *)searchText InScope:(NSString *)scope{
    
    NSMutableArray *arrayVerses = [[NSMutableArray alloc] initWithCapacity:1];
    
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
      
    NSString *primaryL = kLangPrimary;
    NSString *secondaryL = kLangNone;
    
    if(dictPref !=nil ){
        
        primaryL = [dictPref valueForKey:@"primaryLanguage"];
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
        
    }
    
    NSString *scopeStr = @"";
    if([scope isEqualToString:kBookNewTestament]){
        
        scopeStr = @"books.book_id >= 40 and";
        
    }else if([scope isEqualToString:kBookOldTestament]){
        
        scopeStr = @"books.book_id < 40 and";
    }
    
    NSMutableString *querS = nil;
    NSString *orderBy = @"";
    if([primaryL isEqualToString:kLangPrimary]){
        
        querS = [NSMutableString stringWithFormat:@"SELECT MalayalamShortName, chapter_id, verse_id, verse_text, books.book_id, books.num_chptr FROM verses,books where %@ books.book_id = verses.book_id and verse_text ", scopeStr];
        orderBy = @" order by verses.book_id, verses.chapter_id, verses.verse_id";
        
    }else if([primaryL isEqualToString:kLangEnglishASV]){
        
        querS = [NSMutableString stringWithFormat:@"SELECT EnglishShortName, chapter_id, verse_id, verse_text, books.book_id, books.num_chptr FROM verses_asv,books where %@ books.book_id = verses_asv.book_id and verse_text ", scopeStr];
        orderBy = @" order by verses_asv.book_id, verses_asv.chapter_id, verses_asv.verse_id";
        
    }else{
        
        querS = [NSMutableString stringWithFormat:@"SELECT EnglishShortName, chapter_id, verse_id, verse_text, books.book_id, books.num_chptr FROM verses_kjv,books where %@ books.book_id = verses_kjv.book_id and verse_text ", scopeStr];
        orderBy = @" order by verses_kjv.book_id, verses_kjv.chapter_id, verses_kjv.verse_id";
    }
    [querS appendString:@"like '%"];
    [querS appendString:searchText];
    [querS appendString:@"%'"];
    
    [querS appendString:orderBy];
        
   
    
   
        
    //(@"querS = %@", querS);
    
    NSString *pathname = [self getdbpath];//[[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    const char *dbpath = [pathname UTF8String];
    sqlite3 *bibleDB;
    
    if (sqlite3_open(dbpath, &bibleDB) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        
        
        const char *queryStmt = [querS UTF8String];
        if (sqlite3_prepare_v2(bibleDB, queryStmt, -1, &statement, NULL) == SQLITE_OK){
            
            
            NSString *preheaderTitle = nil;
            NSString *headerTitle = nil;
            
            NSMutableArray *arraySection = [[NSMutableArray alloc] init];
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                
                NSMutableString *str = [NSMutableString string];
                
                const char *bookname = (const char *) sqlite3_column_text(statement, 0);
                const char *chapter = (const char *) sqlite3_column_text(statement, 1);
                const char *rowId = (const char *) sqlite3_column_text(statement, 2);
                const char *verse = (const char *) sqlite3_column_text(statement, 3);
                int bookid =  sqlite3_column_int(statement, 4);
                int numofchapter =  sqlite3_column_int(statement, 5);
                
                headerTitle = [NSString stringWithUTF8String:bookname];
                if(preheaderTitle == nil){
                    
                    preheaderTitle = headerTitle;
                }
                NSString *strChapter = (chapter != NULL) ? [NSString stringWithUTF8String:chapter] : @"1";
                if(chapter){
                    [str appendString:strChapter];
                }
                
                NSString *strRowId = (rowId != NULL) ? [NSString stringWithUTF8String:rowId] : @"1";
                if(rowId){
                    [str appendFormat:@":%@ ",strRowId];
                }
                NSString *origVerse = @"";
                if(verse){
                    
                    NSMutableString *versse = [NSMutableString stringWithUTF8String:verse];
                    origVerse = [NSString stringWithFormat:@"%@%@", str,versse];
                     
                    NSRange rangeS;
                    if([primaryL isEqualToString:kLangPrimary]){
                        
                        rangeS = [versse rangeOfString:searchText];
                        
                    }else{
                        
                        rangeS = [versse rangeOfString:[searchText copy] options:NSCaseInsensitiveSearch];
                    }
                    
                    if(rangeS.length > 0){
                       
                        [versse replaceCharactersInRange:rangeS withString:[NSString stringWithFormat:@"<span style=\"BACKGROUND-COLOR: yellow\">%@</span>", searchText]];
                    }                    
                    
                    
                    [str appendString:versse];
                }
                
                
                Book *bookDetails = [[Book alloc] init];
                //book.alphaCode = alphaCode;
                bookDetails.bookId = bookid;
                //book.englishName = englishName;
                bookDetails.numOfChapters = numofchapter;
                bookDetails.shortName = headerTitle;
                //book.longName = longName;
                
                                
                NSString *htmlContent = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {font-family: \"%@\"; font-size: %@;}</style></head><body><div style=\"line-height:%fem;\">%@<div></body></html>", kFontName, [NSNumber numberWithInt:FONT_SIZE],Line_Height, str];
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:origVerse, @"verse_text",htmlContent, @"verse_html",bookDetails, @"book_details",strChapter, @"chapter",strRowId, @"verse_id",  nil];
                
                if(![headerTitle isEqualToString:preheaderTitle]){
                    
                    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
                    [row setValue:preheaderTitle 
                           forKey:@"headerTitle"];
                    [row setValue:[NSArray arrayWithArray:arraySection] forKey:@"rowValues"]; 
                    
                    [arrayVerses addObject:row];
                    
                    
                    arraySection = [[NSMutableArray alloc] init];
                    [arraySection addObject:dict];
                    preheaderTitle = headerTitle;
                    
                }else{
                    
                    [arraySection addObject:dict];
                }
            }//end while each row
            sqlite3_finalize(statement);
            
            
            if([arraySection count] > 0){
                
               
                
                NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
                [row setValue:headerTitle 
                       forKey:@"headerTitle"];
                [row setValue:[NSArray arrayWithArray:arraySection] forKey:@"rowValues"]; 
                
                [arrayVerses addObject:row];                
                
            }
            
        }else{
            
            NSLog(@"err: %@", sqlite3_errmsg(bibleDB));
        }

    }
    sqlite3_close(bibleDB);
    
    return arrayVerses;
}

- (NSMutableArray *) getChapter:(int)bookId:(int)chapterId
{
    
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    NSString *queryMalayalam = [NSString stringWithFormat:@"SELECT verse_id, verse_text FROM verses where book_id = %d AND chapter_id = %d order by verse_id", bookId, chapterId];;
               
    NSString *queryEnglisgASV = [NSString stringWithFormat:@"SELECT verse_id, verse_text FROM verses_asv where book_id = %d AND chapter_id = %d order by verse_id", bookId, chapterId];
 
    NSString *queryEnglisgKJV = [NSString stringWithFormat:@"SELECT verse_id, verse_text FROM verses_kjv where book_id = %d AND chapter_id = %d order by verse_id", bookId, chapterId];
    
    
    NSString *primaryL = kLangPrimary;
    NSString *secondaryL = kLangNone;
    
    if(dictPref !=nil ){
        
        primaryL = [dictPref valueForKey:@"primaryLanguage"];
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
        
    }
        
    NSMutableArray *verses = [NSMutableArray array];
    
    /*sqlite3 *bibleDB;
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
    
	if (sqlite3_open([dbPath UTF8String], &bibleDB) == SQLITE_OK) {*/
    NSString *pathname = [self getdbpath];//[[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    const char *dbpath = [pathname UTF8String];
    sqlite3 *bibleDB;
    
    if (sqlite3_open(dbpath, &bibleDB) == SQLITE_OK) {
        
        sqlite3_stmt *statement1;
        sqlite3_stmt *statement2;
       
        NSString *queryStmt1 = nil;
        NSString *queryStmt2 = nil;
        if([primaryL isEqualToString:kLangPrimary]){
            
            queryStmt1 = queryMalayalam;
            
        }else if([primaryL isEqualToString:kLangEnglishASV]){
            
            queryStmt1 = queryEnglisgASV;
            
        }else{
            queryStmt1 = queryEnglisgKJV;            
        }
        if([secondaryL isEqualToString:kLangPrimary]){
            
            queryStmt2 = queryMalayalam;
        }else if([secondaryL isEqualToString:kLangEnglishASV]){
            queryStmt2 = queryEnglisgASV;
        }else if([secondaryL isEqualToString:kLangEnglishKJV]){
            queryStmt2 = queryEnglisgKJV;
        }else{
            
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init ];
        
        
        if (sqlite3_prepare_v2(bibleDB, [queryStmt1 UTF8String], -1, &statement1, NULL) == SQLITE_OK){
            
            
            while(sqlite3_step(statement1) == SQLITE_ROW) {
                int verseId = sqlite3_column_int(statement1, 0);
                NSString *verse = [[NSString alloc] initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement1, 1)];
                
                
                NSString *verseWithId;
                if(verseId > 0) {
                    verseWithId = [NSString stringWithFormat:@"%d. %@", verseId, verse];
                }
                else {
                    verseWithId = verse;
                }
                
                
                
                
                if(queryStmt2 != nil){
                    
                    NSMutableDictionary *dictVerse = [NSMutableDictionary dictionaryWithObjectsAndKeys:verseWithId, @"verse_text", nil];
                    [dict setObject:dictVerse forKey:[NSNumber numberWithInt:verseId]];
                    
                }else{
                    
                    //NSString *htmlContent = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {font-family: \"%@\"; font-size: %@; background-color:black;}</style></head><body><div style=\"line-height:%fem;color:white;\">%@</div></body></html>", kFontName, [NSNumber numberWithInt:FONT_SIZE],Line_Height, verseWithId];
                    NSString *htmlContent = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body { font-family: \"%@\"; font-size: %@;}</style><body><div style=\"line-height:%fem;\">%@</div></body></head></html>",kFontName, [NSNumber numberWithInt:FONT_SIZE], Line_Height, verseWithId];
                    
                    NSMutableDictionary *dictVerse = [NSMutableDictionary dictionaryWithObjectsAndKeys:verseWithId, @"verse_text",htmlContent, @"verse_html",  nil];
                    [verses addObject:dictVerse];
                    
                }
                
                
            }
            sqlite3_finalize(statement1);
        }else{
            
            NSLog(@"err: %@", sqlite3_errmsg(bibleDB));
        }
        
        if(queryStmt2 != nil){
            
            if (sqlite3_prepare_v2(bibleDB, [queryStmt2 UTF8String], -1, &statement2, NULL) == SQLITE_OK){
                
                
                while(sqlite3_step(statement2) == SQLITE_ROW) {
                    int verseId = sqlite3_column_int(statement2, 0);
                    NSString *verse = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement2, 1)];
                    
                    
                    NSString *verseWithId;
                    if(verseId > 0) {
                        verseWithId = [NSString stringWithFormat:@"%d. %@", verseId, verse];
                    }
                    else {
                        verseWithId = verse;
                    }
                    
                    NSMutableDictionary *dictVersePrim = [dict objectForKey:[NSNumber numberWithInt:verseId]];
                    
                    
                    
                    
                    if(dictVersePrim == nil){
                                               
                        
                        NSString *htmlContent = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {font-family: \"%@\"; font-size: %@;}</style></head><body><div style=\"line-height:%fem;color:blue;\">%@</div></body></html>", kFontName, [NSNumber numberWithInt:FONT_SIZE], Line_Height, verseWithId];
                        
                        NSMutableDictionary *dictVerse = [NSMutableDictionary dictionaryWithObjectsAndKeys:verseWithId, @"verse_text",htmlContent, @"verse_html",  nil];
                        
                        [verses addObject:dictVerse];
                        
                    }else{
                        
                        NSString *primaryVerse = [dictVersePrim valueForKey:@"verse_text"];
                        //<Font color=\"blue\">//</Font>
                        NSString *htmlContent = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {font-family: \"%@\"; font-size: %@;}</style></head><body><div style=\"line-height:%fem;\">%@</div><div style=\"line-height:%fem;\"><br></div><div style=\"color:gray;line-height:%fem;\">%@</div></body></html>", kFontName, [NSNumber numberWithInt:FONT_SIZE],Line_Height, primaryVerse, 0.3, Line_Height, verseWithId];
                        
                        //NSString *htmlContent = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {font-family: \"%@\"; font-size: %@;}</style></head><body><div style=\"line-height:1.4em;\"><table><tr><td>%@</td><td  width=\"50%\"><div style=\"color:blue;\">%@</td></tr></table></div></body></html>", kFontName, [NSNumber numberWithInt:FONT_SIZE], primaryVerse, verseWithId];
                        
                        NSDictionary *dictVerse = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@\n%@", primaryVerse, verseWithId], @"verse_text",htmlContent, @"verse_html",  nil];
                        
                        //NSMutableDictionary *dictVerse = [NSMutableDictionary dictionaryWithObjectsAndKeys:primaryVerse,@"verse_text", verseWithId, @"verse_text2",htmlContent, @"verse_html",  nil];
                        
                        [verses addObject:dictVerse];
                    }
                    
                    //removing the verses from dict
                    [dict removeObjectForKey:[NSNumber numberWithInt:verseId]];
                    
                    
                    
                }
                sqlite3_finalize(statement2);
            }else{
                
                NSLog(@"err: %@", sqlite3_errmsg(bibleDB));
            }

        }
        
        sqlite3_close(bibleDB);
        
       //to include additional verses from primary lang if exist
        
        NSEnumerator *enumm = [dict keyEnumerator];
        NSString *key = [enumm nextObject];
        while(key){
            
            
            NSDictionary *dictVersePrim = [dict objectForKey:key];
            
            NSString *primaryVerse = [dictVersePrim valueForKey:@"verse_text"];
            
            //(@"dictVersePrim value of html = %@", [dictVersePrim valueForKey:@"verse_html"]);
            
            NSString *htmlContent = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {font-family: \"%@\"; font-size: %@;}</style></head><body><div style=\"line-height:%fem;\">%@<div></body></html>", kFontName, [NSNumber numberWithInt:FONT_SIZE], Line_Height, primaryVerse];
            
            NSMutableDictionary *dictVerse = [NSMutableDictionary dictionaryWithObjectsAndKeys:primaryVerse, @"verse_text",htmlContent, @"verse_html",  nil];
            
            if([key intValue] < [verses count]){
                                
                [verses insertObject:dictVerse atIndex:[key intValue]];
                
            }else{
                
                
                [verses addObject:dictVerse];
            }
            
            key = [enumm nextObject];
        }
    }
    
    
    
    return verses;
}

+ (NSString *)getTitleBooks{
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    if(dictPref ==nil || [kLangPrimary isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        return NSLocalizedString(@"bookname_primarylanguage", @"");
        
    }         
    return NSLocalizedString(@"bookname_English", @"");//@"Books";
    
    
}
+ (NSString *)getTitleOldTestament{
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    if(dictPref ==nil || [kLangPrimary isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        return NSLocalizedString(@"oldbook_primarylanguage", @"");
        
    }         
    return NSLocalizedString(@"oldbook_English", @"");//@"Old Testament";
}
+ (NSString *)getTitleNewTestament{
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    if(dictPref ==nil || [kLangPrimary isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        return NSLocalizedString(@"newbook_primarylanguage", @"");//@"പുതിയനിയമം";
        
    }         
    return NSLocalizedString(@"newbook_english", @"");//@"New Testament";
}
+ (NSString *)getTitleChapter{
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    if(dictPref ==nil || [kLangPrimary isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
        return NSLocalizedString(@"chapter_primarylanguage", @"");//"അദ്ധ്യായം";
        
    }         
    return NSLocalizedString(@"chapter_english", @"");//@"Chapter";
}
+ (NSString *)getTitleChapterButton{
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    
    
    if(dictPref ==nil || [kLangPrimary isEqualToString:[dictPref valueForKey:@"primaryLanguage"]]){
        
       
        return NSLocalizedString(@"chapters_primarylanguage", @"");//@"അദ്ധ്യായങ്ങൾ";
        
    }   
    
    return NSLocalizedString(@"chapters_english", @"");
    
}
@end
