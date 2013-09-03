//
//  ColorViewController.h
//  Malayalam Bible
//
//  Created by jijo on 4/22/13.
//
//

#import <UIKit/UIKit.h>


@protocol MBColourSelectorDelegate <NSObject>
@required
- (void)colorStringDidChange:(NSString *)newColor;
@end

@interface ColorViewController : UITableViewController{
    
    id <MBColourSelectorDelegate> delegatee;
    NSArray *arrayColors;
    NSString *selectedColor;
}

- (id)initWithStyle:(UITableViewStyle)style SelectedColor:(NSString *)selColor Delegate:(id)delgte;

@end
