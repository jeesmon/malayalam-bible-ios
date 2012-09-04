//
//  VerseCell.m
//  Malayalam Bible
//
//  Created by jijo on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VerseCell.h"
#import "MBConstants.h"
#import "UIDeviceHardware.h"


@implementation VerseCell

@synthesize webView, verseText, touchView, isSearchResult;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.webView = [[UIWebView alloc] init];
        //self.webView.scalesPageToFit = YES;
        
        
        if([UIDeviceHardware isOS5Device]){
            self.webView.scrollView.scrollEnabled = NO;
        }else{
            for (id subview in webView.subviews){ 
                if ([[subview class] isSubclassOfClass: [UIScrollView class]]) { 
                    UIScrollView *scrollVieww = (UIScrollView *)subview;
                    scrollVieww.scrollEnabled = NO;
                    break;
                }
            }

        }
                        
        [self.contentView addSubview:webView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat adjustWidth = 40.0;
    if(self.isSearchResult){
        adjustWidth = 27.0;
    }
    
    CGRect contentRect = self.contentView.bounds;
	
    
    CGSize cgSize = contentRect.size;
    
   


    UIFont *cellFont = [UIFont fontWithName:kFontName size:FONT_SIZE];
    CGSize constraintSize = CGSizeMake(cgSize.width-adjustWidth, MAXFLOAT);//280
    CGSize labelSize = [verseText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
   
        
    [self.webView setFrame:CGRectMake(0, 0, cgSize.width, labelSize.height + 15)];
   
}



@end
