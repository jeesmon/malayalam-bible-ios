//
//  VerseCell.h
//  Malayalam Bible
//
//  Created by jijo on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VerseCell : UITableViewCell {
    
    UIWebView *webView;
    NSString *verseText;
    UIView *touchView;
    
    BOOL isSearchResult;
}
@property(nonatomic, assign) BOOL isSearchResult;
@property(nonatomic, retain) UIView *touchView;
@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) NSString *verseText;

@end
