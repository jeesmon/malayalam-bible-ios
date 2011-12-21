//
//  ChapterPickerController.h
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@interface ChapterPickerController : NSObject <UIPickerViewDataSource, UIPickerViewDelegate> {
    UIPickerView *pickerView;
    UILabel *chapters;
    UIButton *button;
    int selectedChapter;
}

@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (assign, readwrite) int numOfChapters;
@property (nonatomic, retain) IBOutlet UIButton *button;

- (void)buttonClicked: (id)sender;

@end