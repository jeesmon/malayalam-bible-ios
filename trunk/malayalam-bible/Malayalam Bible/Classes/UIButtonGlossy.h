//
//  UIButtonGlossy.h
//  MobileEdge
//
//  Created by jijo on 12/10/09.
//  Copyright 2009 __iEnterprises__.  All rights reserved.  Maintained by __Notetech__.
//

#import <UIKit/UIKit.h>


@interface UIButton (Glossy)

+ (void)setPathToRoundedRect:(CGRect)rect forInset:(NSUInteger)inset inContext:(CGContextRef)context;
+ (void)drawGlossyRect:(CGRect)rect withColor:(UIColor*)color inContext:(CGContextRef)context;
- (void)setBackgroundToGlossyRectOfColor:(UIColor*)color withBorder:(BOOL)border forState:(UIControlState)state;
- (UIButton*)shinyButton:(UIButton *)button WithWidth:(NSUInteger)width height:(NSUInteger)height color:(UIColor*)color color2:(UIColor *)color2;
@end

