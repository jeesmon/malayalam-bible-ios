//
//  FontSizeCell.h
//  Malayalam Bible
//
//  Created by jijo Pulikkottil on 29/08/13.
//
//

#import <UIKit/UIKit.h>

@interface FontSizeCell : UITableViewCell{
    
    UILabel *lblSample;
    UISlider *fontSizeSlider;
}

@property(nonatomic) UISlider *fontSizeSlider;
@property(nonatomic) UILabel *lblSample;

@end
