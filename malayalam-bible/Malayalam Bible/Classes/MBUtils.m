//
//  MBUtils.m
//  Malayalam Bible
//
//  Created by jijo on 5/8/13.
//
//
#import <UIKit/UIColor.h>
#import "MBUtils.h"

@implementation MBUtils

+ (NSURL *)getBaseURL{
    
    //[NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]]
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths objectAtIndex:0];
    NSString *storePath = [basePath stringByAppendingPathComponent:@"narayam"];
    NSURL *url = [NSURL fileURLWithPath:storePath];
    
    return url;
    
}
+ (NSString *) getHighlightColorof:(NSString *)colorConst{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *colorcode = [def valueForKey:colorConst];
    
    if(colorcode == nil){
        
        if([colorConst isEqualToString:kStoreColor1]){
            colorcode = @"#FFCCD5";
            [def setValue:colorcode forKey:kStoreColor1];
            [def synchronize];
        }
        else if([colorConst isEqualToString:kStoreColor2]){
            colorcode = @"#CCFFDD";
            [def setValue:colorcode forKey:kStoreColor2];
            [def synchronize];
        }
        else if([colorConst isEqualToString:kStoreColor3]){
            colorcode = @"#CCE5FF";
            [def setValue:colorcode forKey:kStoreColor3];
            [def synchronize];
        }else if([colorConst isEqualToString:kStoreColor4]){
            colorcode = @"FFFF99";
            [def setValue:colorcode forKey:kStoreColor4];
            [def synchronize];
        }else if([colorConst isEqualToString:kStoreColor5]){
            colorcode = @"#EECCFF";
            [def setValue:colorcode forKey:kStoreColor5];
            [def synchronize];
        }
    }
    
    
    return colorcode;
}
@end

@implementation UIColor(MBCategory)

// takes @"#123456"
+ (UIColor *)colorWithHexString:(NSString *)str {
    /*const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:x];*/
    NSString *noHashString = [str stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}// takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}


@end