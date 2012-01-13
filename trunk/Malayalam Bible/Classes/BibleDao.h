//
//  BibleDao.h
//  Malayalam Bible
//
//  Created by jijo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BibleDao : NSObject

- (NSDictionary *)fetchBookNames;
- (NSMutableArray *) getChapter:(int)bookId:(int)chapterId;

@end
