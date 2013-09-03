//
//  FontSizeCell.m
//  Malayalam Bible
//
//  Created by jijo Pulikkottil on 29/08/13.
//
//

#import "FontSizeCell.h"
#import "MBConstants.h"

@implementation FontSizeCell

@synthesize fontSizeSlider, lblSample;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.fontSizeSlider = [[UISlider alloc] init];
        [self.fontSizeSlider addTarget:self action:@selector(sliderValueChanged:)
           forControlEvents:UIControlEventValueChanged];
        self.fontSizeSlider.minimumValue = kFontMinSize;
        self.fontSizeSlider.maximumValue = kFontMaxSize;
        [self.fontSizeSlider setValue:FONT_SIZE animated:YES];
        self.lblSample = [[UILabel alloc] init];
        
        self.lblSample.text = @"Sample Text";
        self.lblSample.font = [UIFont systemFontOfSize:FONT_SIZE];
        self.lblSample.textAlignment = UITextAlignmentCenter;
        
        [self.contentView addSubview:self.fontSizeSlider];
        [self.contentView addSubview:self.lblSample];
    }
    return self;
}
-(void)sliderValueChanged:(UISlider *)sender
{
    MBLog(@"slider value = %f", sender.value);
    FONT_SIZE = sender.value;
    self.lblSample.font = [UIFont systemFontOfSize:FONT_SIZE];
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    CGSize cgSize = contentRect.size;
    
    self.fontSizeSlider.frame = CGRectMake(60, 38, cgSize.width-120, 20);
    self.lblSample.frame = CGRectMake(0, 10, cgSize.width, 25);
}
@end
