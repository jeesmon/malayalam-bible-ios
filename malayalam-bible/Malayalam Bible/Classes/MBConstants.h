//
//  MBConstants.h
//  Malayalam Bible
//
//  Created by jijo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


extern  CGFloat FONT_SIZE;

#define kFontMaxSize 25
#define kFontMinSize 9
#define kActionViewWidth    250

extern const NSString *bmBookSection;
//extern const NSString *bmBookRow;

extern  NSString * const kLangPrimary;
extern  NSString * const kLangEnglishASV;
extern  NSString * const kLangEnglishKJV;
extern  NSString * const kLangNone;

extern  NSString * const kStorePreference;

extern  NSString * const kBookAll;
extern  NSString * const kBookNewTestament;
extern  NSString * const kBookOldTestament;

extern  NSString * const kFontName;

extern CGFloat statusBarHeight;
extern BOOL isDetailControllerVisible;

@interface MBConstants : NSObject

@end
