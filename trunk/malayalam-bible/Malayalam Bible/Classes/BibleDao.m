//
//  BibleDao.m
//  Malayalam Bible
//
//  Created by jijo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BibleDao.h"
#import "sqlite3.h"

#import "MBConstants.h"
#import "ApplicationInfo.h"
#import "MalayalamBibleAppDelegate.h"

#import "UIDeviceHardware.h"

#import "BookMarks.h"
#import "Notes.h"
#import "ColordVerses.h"

#import "MBUtils.h"

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
//+20121017
- (NSDictionary *)fetchBookNames{
    
   NSMutableArray *books = [NSMutableArray array];
    NSMutableArray *indexArrray = [NSMutableArray array];
       
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
                              
                /*if(bookId > 39) {
                    [newTestament addObject:displayValue];
                }
                else {
                    [oldTestament addObject:displayValue];
                }*/
                
                Book *book = [[Book alloc] init];
                book.alphaCode = alphaCode;
                book.bookId = bookId;
                //book.englishName = englishName;
                book.numOfChapters = numOfChapters;
                book.shortName = shortName;
                book.longName = longName;
                book.displayValue = displayValue;
                
                
                [books addObject:book];
                
                NSInteger lengthI = 4;
                if([displayValue intValue] > 0)
                {
                    lengthI = 5;
                }
                if([displayValue length] > lengthI){
                    [indexArrray addObject:[NSString stringWithFormat:@"  %@ ",[displayValue substringToIndex:lengthI]]];
                }else{
                    //[indexArrray addObject:[displayValue substringToIndex:[displayValue length]]];
                    [indexArrray addObject:[NSString stringWithFormat:@" %@ ", displayValue]];
                }
                
                
            }
            sqlite3_finalize(statement);
        }else{
            
            MBLogAll(@"err: %s", sqlite3_errmsg(bibleDB));
        }
    }
    sqlite3_close(bibleDB);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:books, @"books", indexArrray, @"index", nil];
}
//+20121017
- (Book *)fetchBookWithSection:(NSInteger)section Row:(NSInteger)row{
    
       
   
    
    int rowid = section+1;
    
    
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
                book.displayValue = displayValue;
                              
            }
            sqlite3_finalize(statement);
        }else{
            
            MBLogAll(@"err: %s", sqlite3_errmsg(bibleDB));
        }
    }
    sqlite3_close(bibleDB);
    
    return book;
}

- (Book *)getBookUsingId:(NSInteger)bookid{
    
    
        
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
    NSString *querySQL = nil;
    
    NSString *primaryL = kLangPrimary;
    NSString *secondaryL = kLangNone;
    
    if(dictPref !=nil ){
        
        primaryL = [dictPref valueForKey:@"primaryLanguage"];
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
        
    }
    if([primaryL isEqualToString:kLangPrimary]){
        
        querySQL = @"SELECT AlphaCode, book_id, EnglishShortName, num_chptr, MalayalamShortName, MalayalamLongName FROM books where book_id = ?";
        
    }else{
        querySQL = @"SELECT AlphaCode, book_id, EnglishShortName, num_chptr, MalayalamShortName, MalayalamLongName FROM books where book_id = ?";
    }
    
    Book *book = [[Book alloc] init];
    
    NSString *pathname = [self getdbpath];//[[NSBundle mainBundle] pathForResource:@"malayalam-bible" ofType:@"db" inDirectory:@"/"];
    const char *dbpath = [pathname UTF8String];
    sqlite3 *bibleDB;
    
    if (sqlite3_open(dbpath, &bibleDB) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        
        
        const char *queryStmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(bibleDB, queryStmt, -1, &statement, NULL) == SQLITE_OK){
            
            sqlite3_bind_int(statement, 1, bookid);
            
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
                book.displayValue = displayValue;
                
            }
            sqlite3_finalize(statement);
        }else{
            
            MBLogAll(@"err: %s", sqlite3_errmsg(bibleDB));
        }
    }
    sqlite3_close(bibleDB);
    
    return book;
}

- (NSMutableArray *) getSerachResultWithText:(NSString *)searchText InScope:(NSInteger)scope AndBookId:(int)bookid{
    
    NSMutableArray *arrayVerses = [[NSMutableArray alloc] initWithCapacity:1];
    
    
    NSMutableDictionary *dictPref = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePreference];
    
      
    NSString *primaryL = kLangPrimary;
    NSString *secondaryL = kLangNone;
    
    if(dictPref !=nil ){
        
        primaryL = [dictPref valueForKey:@"primaryLanguage"];
        secondaryL = [dictPref valueForKey:@"secondaryLanguage"];
        
    }
    
    NSString *scopeStr = @"";
    if(scope == 3  && bookid > 0) {
        scopeStr = [NSString stringWithFormat:@"books.book_id = %i and", bookid];
    }else{
        
        if(scope == 2){
            
            scopeStr = @"books.book_id >= 40 and";
            
        }else if(scope == 1){
            
            scopeStr = @"books.book_id < 40 and";
        }
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
            
            MBLogAll(@"err: %s", sqlite3_errmsg(bibleDB));
        }

    }
    sqlite3_close(bibleDB);
    
    //MBLog(@"arrayVerses = %@", arrayVerses);
    
    return arrayVerses;
}
- (NSString *)getHexStringForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"#%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}
- (NSDictionary *) getChapter:(int)bookId  Chapter:(int)chapterId
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
    sqlite3 *bibleDB = nil;
    
    NSMutableString *functions = [NSMutableString stringWithString:@" var newClassName; var i; var isExist; var classes; function scrollToDivId(divid){   var ele = document.getElementById(divid); window.scrollTo(ele.offsetLeft,ele.offsetTop);} function getPosition(divid){ var ele = document.getElementById(divid); return ele.offsetTop; }"];//el.style.color=\"#FF0000\";
    //el.style.fontWeight == 'bold' ? 'normal' : 'bold';
    
    NSString *selectionClass = @"lightgray";
    
    //[functions appendFormat:@" function makeBold(noteid){var el = document.getElementById(noteid);el.style.fontWeight =  'bold'; } function makeNormal(noteid){var el = document.getElementById(noteid);el.style.fontWeight = 'normal';}  function toggleSelection(fontid) {  newClassName = \"\"; isExist = false; classes = document.getElementById(fontid).className.split(\" \");for(i = 0; i < classes.length; i++) {if(classes[i] == \"%@\") { isExist = true; break; }} if(isExist){ for(i = 0; i < classes.length; i++) { if(classes[i] != \"%@\") {newClassName += classes[i] + \" \";} } document.getElementById(fontid).className = newClassName;}else{if(classes.length == 0){document.getElementById(fontid).className = \"%@\";}else{ document.getElementById(fontid).className += (\" \"+%@);} } alert(document.getElementById(fontid).className)}", selectionClass, selectionClass, selectionClass, selectionClass];
    
    //[functions appendFormat:@" function makeBold(noteid){var el = document.getElementById(noteid);el.style.fontWeight =  'bold'; } function makeNormal(noteid){var el = document.getElementById(noteid);el.style.fontWeight = 'normal';}  function toggleSelection(fontid) {   var elem = document.getElementById(fontid); if(elem.className.length > 0){ if(elem.className == \"lightgray\"){ if(elem.jijol.length>0){elem.className = elem.jijol;}else{elem.className =\"\";} }else{elem.jijol=elem.className; elem.className = \"lightgray\";}  }else{elem.className = \"lightgray\";}  ;}"];
    
    [functions appendFormat:@" function makeBold(noteid){var el = document.getElementById(noteid);el.style.fontWeight =  'bold'; } function makeNormal(noteid){var el = document.getElementById(noteid);el.style.fontWeight = 'normal';}  function toggleSelection(fontid) {  var elem = document.getElementById(fontid); if(elem.isselected == \"yes\"){ if(elem.colorcode){elem.style.background = elem.colorcode; }else if(elem.bookmarkcolor){elem.style.background = elem.bookmarkcolor;}else{elem.style.background=\"\"; elem.isselected = \"no\"; } elem.isselected = undefined;}else{elem.isselected = \"yes\"; elem.style.background =\"%@\";} }", selectionClass];
    
    //[functions appendFormat:@" function selectVerse(fontid, colorclass){ document.getElementById(fontid).className = colorclass;  } "];
    [functions appendFormat:@" function selectVerse(fontid, colorvalue){ var elem = document.getElementById(fontid); elem.style.background = colorvalue;  elem.colorcode=colorvalue;elem.isselected = \"no\";} "];
    
    //[functions appendFormat:@" function selectBMVerse(fontid, colorvalue){ var elem = document.getElementById(fontid); elem.style.background = colorvalue; elem.bookmarkcolor=colorvalue;} "];
    [functions appendFormat:@" function selectBMVerse(fontid, colorvalue){ var elem = document.getElementById(fontid); elem.className = \"underline\"; } "];
    [functions appendFormat:@" function deSelectVerse(fontid){ var elem = document.getElementById(fontid); elem.colorcode = undefined; elem.bookmarkcolor=undefined;elem.isselected = \"no\";elem.style.background = \"\";} "];
    
    //[functions appendFormat:@" function selectVerse(fontid, colorclass){ document.getElementById(fontid).className += (\" \"+colorclass); } "];
    
    //[functions appendFormat:@" function selectBMVerse(fontid, colorvalue){ document.getElementById(fontid).className += (\" \"+color2); } "];
    
    
    //[functions appendFormat:@" function selectVerse(fontid, colorclass){ document.getElementById(fontid).style.backgroundColor = colorclass; } "];
    //[functions appendFormat:@" function selectVerse(fontid, colorclass){ var el = document.getElementById(fontid);el.style.backgroundColor=colorclass;  } "];
    //[functions appendFormat:@" function selectVerse(fontid, colorclass){ $('#'+fontid).addClass(colorclass); } function testj(input){ var replacement = $narayam.transliterate( input, '', '' ); return replacement;  } function testj2(input){ return $.narayam.testj4();  }  function testj1(input){ return testj3();  }"];
    //document.getElementById(fontid).className = colorclass;
    
    //NSString *jsssource = @"<script src=\"libs/jquery-1.8.3.min.js\" type=\"text/javascript\" language=\"javascript\"></script><script src=\"libs/jquery.ime/src/jquery.ime.js\" type=\"text/javascript\" language=\"javascript\"></script><script src=\"libs/jquery.ime/src/jquery.ime.preferences.js\" type=\"text/javascript\" language=\"javascript\"></script><script src=\"libs/jquery.ime/src/jquery.ime.selector.js\" type=\"text/javascript\" language=\"javascript\"></script><script src=\"libs/jquery.ime/src/jquery.ime.inputmethods.js\" type=\"text/javascript\" language=\"javascript\"></script><script src=\"javascripts/main.js/bundled_js.js\" type=\"text/javascript\" language=\"javascript\"></script>"];
    //NSString *jsssource = @"<script src=\"libs/jquery-1.8.3.min.js\" type=\"text/javascript\" language=\"javascript\"></script><script src=\"resources/ext.narayam.core/ext.narayam.core.js\" type=\"text/javascript\" language=\"javascript\"></script><script src=\"resources/ext.narayam.js\" type=\"text/javascript\" language=\"javascript\"></script><script src=\"resources/ext.narayam.rules.ml-inscript.js\" type=\"text/javascript\" language=\"javascript\"></script><script src=\"resources/ext.narayam.rules.ml.js\" type=\"text/javascript\" language=\"javascript\"></script><script src=\"resources/osk/ext.narayam.osk.js\" type=\"text/javascript\" language=\"javascript\"></script>";
    //dashed #5b5b5b
    
    NSString *jsssource = @"<meta name=”viewport” content=”width=device-width” />";
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *appColor = [def valueForKey:kStoreThemeColor];
    
    if(appColor == nil){
        if([UIDeviceHardware isOS7Device]){
            //os7MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
            //os7appColor = [self getHexStringForColor:appDelegate.window.tintColor];
        }else{
            appColor = @"#000000";
        }
        //[def setValue:color1 forKey:kStoreColor1];
        //[def synchronize];
    }
    NSString *color1 = [MBUtils getHighlightColorof:kStoreColor1];//[def valueForKey:kStoreColor1];
    
    NSString *color2 = [MBUtils getHighlightColorof:kStoreColor2];//[def valueForKey:kStoreColor2];
    
    NSString *color3 = [MBUtils getHighlightColorof:kStoreColor3];//[def valueForKey:kStoreColor3];
    
    NSString *color4 = [MBUtils getHighlightColorof:kStoreColor4];//[def valueForKey:kStoreColor4];
    
    NSString *color5 = [MBUtils getHighlightColorof:kStoreColor5];//[def valueForKey:kStoreColor5];
    //NSMutableString *mString = [NSMutableString stringWithFormat:@"<html><head> %@ <script type=\"text/javascript\" language=\"JavaScript\"> %@ </script><style type=\"text/css\">html {-webkit-touch-callout: none;} .underline{border-bottom: 1px dashed %@;text-decoration: none;display:inline;background-color:transparent;} body { font-family: \"%@\"; font-size: %@;} a {text-decoration:none;color:#404040;} .yellow { background-color: yellow } .lightgray { background-color: lightgray } .nocolor { background-color:transparent; } .color1 { background-color: %@ }  .color2 { background-color: %@ } .color3 { background-color: %@ } .color4 { background-color: %@ } .color5 { background-color: %@ }</style><body>", jsssource, functions,appColor, kFontName, [NSNumber numberWithInt:FONT_SIZE], color1, color2, color3, color4, color5];
    
    NSMutableString *mString = [NSMutableString stringWithFormat:@"<html><head> %@ <script type=\"text/javascript\" language=\"JavaScript\"> %@ </script><style type=\"text/css\">html {-webkit-touch-callout: none;} .underline{border-bottom: 1px dashed %@;text-decoration: none;display:inline;background-color:transparent;} body { font-family: \"%@\"; font-size: %@;} a {text-decoration:none;color:#404040;} .yellow { background-color: yellow } .lightgray { background-color: lightgray } .nocolor { background-color:transparent; } </style><body>", jsssource, functions,appColor, kFontName, [NSNumber numberWithInt:FONT_SIZE]];
        
    
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
            
            
            //NSArray *arrayBMVerses = [dictBMVerses allKeys];
            
                        
            while(sqlite3_step(statement1) == SQLITE_ROW) {
                
                int verseId = sqlite3_column_int(statement1, 0);
                
                
                NSString *vesrIDStr = [NSString stringWithFormat:@"%i", verseId];
                
                NSString *versenocolor = @"";
                
                /*if([arrayBMVerses containsObject:vesrIDStr]){
                    
                    BookMarks *bm = [dictBMVerses valueForKey:vesrIDStr];
                    
                    //bgcolor = [NSString stringWithFormat:@"background:%@;", bm.folder.folder_color];//@"background:#33FF99";
                    //bgcolor = [NSString stringWithFormat:@"style=\"BACKGROUND-COLOR:%@\"", bm.folder.folder_color];//@"background:#33FF99";
                    fontclass = @"class = \"yellow\"";
                    NSLog(@"inside");
                    versenocolor = @"background:#FFFFFF;color:#000000;";
                    //@"text-decoration: underline;";
                }*/
                
                NSString *verse = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement1, 1)];
                
                
                NSMutableString *htmlContent = [[NSMutableString alloc] init];
                NSString *verseWithId;
                if(verseId > 0) {
                    verseWithId = [NSString stringWithFormat:@"%d. %@", verseId, verse];
                    [htmlContent appendString:[NSString stringWithFormat:@"<html><head></head><b>%d. </b>", verseId]];
                }
                else {
                    verseWithId = verse;
                    
                }
                
                
                
                
                if(queryStmt2 != nil){
                    
                    NSMutableDictionary *dictVerse = [NSMutableDictionary dictionaryWithObjectsAndKeys:verseWithId, @"verse_text", nil];
                    [dict setObject:dictVerse forKey:[NSNumber numberWithInt:verseId]];
                    
                }else{
                    //
                    //NSString *htmlContent = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {font-family: \"%@\"; font-size: %@; background-color:black;}</style></head><body><div style=\"line-height:%fem;color:white;\">%@</div></body></html>", kFontName, [NSNumber numberWithInt:FONT_SIZE],Line_Height, verseWithId];
                    /*NSString *htmlC = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body { font-family: \"%@\"; font-size: %@;}</style><body><div style=\"line-height:%fem;\"><a href=\"melt://showAlert:%i\">%i. </a>%@</div></body></head></html>",kFontName, [NSNumber numberWithInt:FONT_SIZE], Line_Height, verseId,verseId,  verse];*/
                    
                   //NSString *htmlC = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body { font-family: \"%@\"; font-size: %@;} a {text-decoration:none;color:#FFFFFF}</style><body><div style=\"line-height:%fem;%@\"><a href=\"melt://chapterClicked:%i\"><FONT COLOR=\"#000000\">%i. </FONT></a>%@</div></body></head></html>",kFontName, [NSNumber numberWithInt:FONT_SIZE], Line_Height, versenocolor, verseId,verseId,  verse];
                    NSString *htmlC = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body { font-family: \"%@\"; font-size: %@;} a {text-decoration:none;color:#FFFFFF}</style><body><div style=\"line-height:%fem;%@\">c %i.%@</div></body></head></html>",kFontName, [NSNumber numberWithInt:FONT_SIZE], Line_Height, versenocolor, verseId,  verse];
                    //.underline{border-bottom: 1px dashed #999;text-decoration: none;}
                    //display:inline;
                    
                    //NSString *htmlC = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">html {-webkit-touch-callout: none;} .underline{border-bottom: 1px dashed #5b5b5b;text-decoration: none;display:inline;} body { font-family: \"%@\"; font-size: %@;} a {text-decoration:none;%@}</style><body><div style=\"line-height:%fem;\"><a href=\"melt://chapterClicked:%i\">%i. </a><FONT %@>%@</FONT></div></body></head></html>",kFontName, [NSNumber numberWithInt:FONT_SIZE],versenocolor,Line_Height,[verses count],verseId, fontclass, verse];
                    
                    [htmlContent appendString:htmlC];
                    
                    NSMutableDictionary *dictVerse = [NSMutableDictionary dictionaryWithObjectsAndKeys:verseWithId, @"verse_text",htmlC, @"verse_html", [NSNumber numberWithInt:verseId], @"verseid", nil];
                    
                    NSString *divid = [NSString stringWithFormat:@"Verse-%i",verseId];
                    NSString *fontid = [NSString stringWithFormat:@"Font-%i",verseId];
                    NSString *noteid = [NSString stringWithFormat:@"Note-%i",verseId];
                    
                    //[mString appendFormat:@"<a href=\"melt://chapterClicked:%i\">%i. </a><div id=\"%@\"><FONT id=\"%@\" %@>%@</FONT></div>", [verses count],verseId,divid,fontid, fontclass, verse];
                    //[mString appendFormat:@"<div id=\"%@\"><a href=\"melt://chapterClicked:%i\"><b>%i. </b></a><FONT id=\"%@\" %@>%@</FONT></div>", divid,[verses count],verseId,fontid, fontclass, verse];
                    
                    [mString appendFormat:@"<div id=\"%@\"><a id=\"%@\" href=\"melt://chapterClicked:%i\">%i. </a><FONT id=\"%@\"  colorcode=\"\" bookmarkcolor=\"\" isselected=\"\" onClick=\"window.open('melt://verseClicked:%i')\">%@</FONT></div>", divid,noteid,[verses count],verseId,fontid, [verses count], verse];
                    //Line_Height style=\"line-height:%fem;\"
                    
                    [verses addObject:dictVerse];
                }
                
                
            }
            
            
            sqlite3_finalize(statement1);
        }else{
            
            MBLogAll(@"err: %s", sqlite3_errmsg(bibleDB));
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
                                               
                        
                        
                        
                        NSMutableDictionary *dictVerse = [NSMutableDictionary dictionaryWithObjectsAndKeys:verseWithId, @"verse_text", [NSNumber numberWithInt:verseId], @"verseid", nil];
                        
                        NSString *divid = [NSString stringWithFormat:@"Verse-%i",verseId];
                        NSString *fontid = [NSString stringWithFormat:@"Font-%i",verseId];
                        NSString *noteid = [NSString stringWithFormat:@"Note-%i",verseId];
                        
                      
                        
                        [mString appendFormat:@"<div id=\"%@\"><a id=\"%@\" href=\"melt://chapterClicked:%i\"></a><FONT id=\"%@\"  colorcode=\"\" bookmarkcolor=\"\" isselected=\"\" onClick=\"window.open('melt://verseClicked:%i')\">%@</FONT></div><hr>", divid,noteid,[verses count],fontid, [verses count], verseWithId];
                        
                        [verses addObject:dictVerse];
                        
                    }else{
                        
                        NSString *primaryVerse = [dictVersePrim valueForKey:@"verse_text"];
                        
                        NSString *verseCell = [NSString stringWithFormat:@"%@<br>%@", primaryVerse, verseWithId];
                        
                        NSMutableDictionary *dictVerse = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@\n%@", primaryVerse, verseWithId], @"verse_text", [NSNumber numberWithInt:verseId], @"verseid", nil];
                        
                        NSString *divid = [NSString stringWithFormat:@"Verse-%i",verseId];
                        NSString *fontid = [NSString stringWithFormat:@"Font-%i",verseId];
                        NSString *noteid = [NSString stringWithFormat:@"Note-%i",verseId];
                        
                        [mString appendFormat:@"<div id=\"%@\"><a id=\"%@\" href=\"melt://chapterClicked:%i\"></a><FONT id=\"%@\"  colorcode=\"\" bookmarkcolor=\"\" isselected=\"\"  onClick=\"window.open('melt://verseClicked:%i')\">%@</FONT></div><hr>", divid,noteid,[verses count],fontid, [verses count], verseCell];
                        
                        [verses addObject:dictVerse];
                    }
                    
                    //removing the verses from dict
                    [dict removeObjectForKey:[NSNumber numberWithInt:verseId]];
                    
                    
                    
                }
                sqlite3_finalize(statement2);
            }else{
                
                MBLogAll(@"err: %s", sqlite3_errmsg(bibleDB));
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
    
    [mString appendFormat:@"</body></head></html>"];
    
    
    
    return [NSDictionary dictionaryWithObjectsAndKeys:verses, @"verse_array", mString, @"fullverse", nil ];
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
#pragma mark -
#pragma mark Core Data

- (Folders *) getDefaultFolder{
    
    Folders *newFlder = nil;
    
    MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
        
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(folder_label = 'Bookmarks')"];
    [request setPredicate:pred];
    
    NSError *error;
    
    NSArray *array1 = [context executeFetchRequest:request error:&error];
    
    if([array1 count] == 0){
        
        MBLog(@"create a default folder named Bookmarks");
        
        newFlder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:context];
        [newFlder setCreateddate:[NSDate date]];
        [newFlder setFolder_label:@"Bookmarks"];
        [newFlder setFolder_color:@"#FF0000"];
        
        NSError *error;
        [context save:&error];
        
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(folder_label = 'Bookmarks')"];
        [request setPredicate:pred];
                
        NSArray *array = [context executeFetchRequest:request error:&error];
        
        if([array1 count] > 0){
            newFlder = [array objectAtIndex:0];
        }
        
    }else{
        newFlder = [array1 objectAtIndex:0];
    }
    
    
    return newFlder;
}
- (Folders *) getDefaultFolderOfNotes{
    
    Folders *newFlder = nil;
    
    MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(folder_label = 'Notes')"];
    [request setPredicate:pred];
    
    NSError *error;
    
    NSArray *array1 = [context executeFetchRequest:request error:&error];
    
    if([array1 count] == 0){
        
        MBLog(@"create a default folder named Bookmarks");
        
        newFlder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:context];
        [newFlder setCreateddate:[NSDate date]];
        [newFlder setFolder_label:@"Notes"];
        [newFlder setFolder_color:@"#FFAAAA"];
        
        NSError *error;
        [context save:&error];
        
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(folder_label = 'Notes')"];
        [request setPredicate:pred];
        
        NSArray *array = [context executeFetchRequest:request error:&error];
        
        if([array1 count] > 0){
            newFlder = [array objectAtIndex:0];
        }
        
    }else{
        newFlder = [array1 objectAtIndex:0];
    }
    
    
    return newFlder;
}

- (NSMutableArray *)getAllNotes{
   
    NSMutableArray *arrayAllBMs = [[NSMutableArray alloc] init];
     
    
    MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Notes" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    
    NSError *error;
    NSArray *array1 = [context executeFetchRequest:request error:&error];
    
    for(Notes *fld in array1){
        
        [arrayAllBMs addObject:fld];
    }
    
    
    
    return arrayAllBMs;
    
}
- (NSMutableArray *)getAllBookMarks{
    
    //http://stackoverflow.com/questions/5399195/where-can-i-find-a-good-example-of-a-core-data-to-many-relationship
    
    NSMutableArray *arrayAllBMs = [[NSMutableArray alloc] init];
    NSMutableArray *arrayBMs = [[NSMutableArray alloc] init];
    
    
    MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
        
    NSError *error;
    NSArray *array1 = [context executeFetchRequest:request error:&error];
    
    for(Folders *fld in array1){
        
        if([fld.folder_label isEqualToString:@"Bookmarks"]){
            
            NSSet *sett = fld.bookmarks;
            
            if([sett count] > 0){
                                
                NSArray *af1 = [fld.bookmarks allObjects];
                                
                [arrayBMs addObjectsFromArray:af1];
            }
            
            
            
        }else{
         
            if(![fld.folder_label isEqualToString:@"Notes"]){
                
                [arrayAllBMs addObject:fld];
            }
            
        }
    }
    
    [arrayAllBMs addObjectsFromArray:arrayBMs];
        
    return arrayAllBMs;
    
}
- (NSMutableArray *)getAllFolders{
    
  
    
   
   
    MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    
    NSError *error;
    NSArray *array1 = [context executeFetchRequest:request error:&error];
    
    
    
    return [NSMutableArray arrayWithArray:array1];
    
}

- (NSMutableArray *)getAllColordVersesOfBook:(NSInteger)bookiid ChapterId:(NSInteger)chpteriid{
    
   
    
    MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ColordVerses" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    if(bookiid > 0){
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(bookid = %i and chapter = %i)", bookiid, chpteriid];
        [request setPredicate:pred];
    }
    
    
    NSError *error;
    NSArray *array1 = [context executeFetchRequest:request error:&error];
    
    return [NSMutableArray arrayWithArray:array1];
    
}
- (NSMutableArray *)getAllColordVersesOfColor:(NSString *)colorcode{
    
    
    
    MalayalamBibleAppDelegate *appDelegate =   [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =  [appDelegate managedObjectContext];
    
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ColordVerses" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(colorcode = '%@' )", colorcode];
    [request setPredicate:pred];
    
    
    
    NSError *error;
    NSArray *array1 = [context executeFetchRequest:request error:&error];
    
    return [NSMutableArray arrayWithArray:array1];
    
}
@end
