//
//  MBUtils.h
//  Malayalam Bible
//
//  Created by jijo on 5/8/13.
//
//

#import <Foundation/Foundation.h>

#define kStoreThemeColor @"ThemeColor"

#define kStoreColor1 @"Color1"
#define kStoreColor2 @"Color2"
#define kStoreColor3 @"Color3"
#define kStoreColor4 @"Color4"
#define kStoreColor5 @"Color5"

@interface MBUtils : NSObject
+ (NSURL *)getBaseURL;
+ (NSString *) getHighlightColorof:(NSString *)colorConst;
@end

@interface UIColor(MBCategory)

+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;

@end