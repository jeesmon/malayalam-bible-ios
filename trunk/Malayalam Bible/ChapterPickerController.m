//
//  ChapterPickerController.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ChapterPickerController.h"

@implementation ChapterPickerController

#define LABEL_TAG 43

@synthesize pickerView;
@synthesize numOfChapters = _numOfChapters;
@synthesize button;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {	
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.numOfChapters;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{   
    if(row == 0) {
        [button setTitle: [NSString stringWithFormat:@"അദ്ധ്യായം %d", row + 1] forState: UIControlStateNormal];
        [button addTarget: self 
                   action: @selector(buttonClicked:) 
         forControlEvents: UIControlEventTouchDown];
        selectedChapter = 1;
    }
    
    return [NSString stringWithFormat:@"അദ്ധ്യായം %d", row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [button setTitle: [NSString stringWithFormat:@"അദ്ധ്യായം %d", row + 1] forState: UIControlStateNormal];
    selectedChapter = row + 1;
}

- (void) buttonClicked: (id)sender
{
    NSNumber *chapter = [NSNumber numberWithInt:selectedChapter];
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"NoteFromChapterPicker"
     object:chapter];
}

- (void)dealloc {
}

@end
