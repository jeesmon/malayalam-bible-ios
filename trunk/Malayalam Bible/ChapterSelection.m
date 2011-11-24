//
//  ChapterSelection.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ChapterSelection.h"

#define FONT_SIZE 17.0f


@interface ChapterSelection (Private)

- (void) openPageWithChapter:(NSUInteger)chapter;

@end

@implementation ChapterSelection

@synthesize scrollViewBar;
@synthesize selectedBook = _selectedBook;
@synthesize detailViewController = _detailViewController;

const CGFloat tagWidthOffset = 10.0f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.selectedBook.shortName;
    [self configureView];
}

- (void) configureView
{        
    NSInteger width = 0;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        width = 320;
    }
    else {
        width = 460;
    }
    
    NSInteger buttonWidth = 40;
    NSInteger buttonHeight = 40;
    NSInteger spacer = 10;
    NSInteger offsetStart = 55;
    NSInteger xOffset = offsetStart;
    NSInteger yOffset = 50;
    for (int i=0; i<self.selectedBook.numOfChapters; i++) {
        NSString *number = [NSString stringWithFormat:@"%d", i+1];
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        if(xOffset > width) {
            xOffset = offsetStart;
            yOffset = yOffset + buttonHeight + spacer;
        }
        
        tagButton.tag = i + 1;
        tagButton.frame = CGRectMake(xOffset, yOffset, buttonWidth, buttonHeight);
        tagButton.titleLabel.textColor = [UIColor blackColor];
        tagButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        
        [tagButton setTitle:number forState:UIControlStateNormal];
        [tagButton setTitle:number forState:UIControlStateHighlighted];
        [tagButton setTitle:number forState:UIControlStateSelected];
        [tagButton setTitle:number forState:UIControlStateDisabled];
        
        [tagButton addTarget: self 
            action: @selector(buttonClicked:) 
            forControlEvents: UIControlEventTouchDown];
        
        [scrollViewBar addSubview:tagButton];
        
        xOffset += buttonWidth + spacer;
    }
    
    [scrollViewBar setContentSize:CGSizeMake(width, yOffset + 200)];
    
    [self.view addSubview:scrollViewBar];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];   
    temporaryBarButtonItem.title = @"അദ്ധ്യായങ്ങൾ";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictSavedState = [def objectForKey:@"SavedState"];
    
    NSNumber *numberChpater = [dictSavedState valueForKey:@"ChaperId"];
    if(numberChpater){
        NSUInteger bmChapterid =  [numberChpater intValue];
        [self openPageWithChapter:bmChapterid];
    }
        
}
- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictSavedState = [NSMutableDictionary dictionaryWithDictionary:[def objectForKey:@"SavedState"]];
    [dictSavedState removeObjectForKey:@"ChaperId"];
    [def synchronize];
}
- (void) buttonClicked: (id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictSavedState =  [NSMutableDictionary dictionaryWithDictionary:[def objectForKey:@"SavedState"]];
    
    [dictSavedState setObject:[NSNumber numberWithInt:btn.tag] forKey:@"ChaperId"];
   
    [def synchronize];
       

    
    [self openPageWithChapter:btn.tag];
}

- (void) openPageWithChapter:(NSUInteger)chapter{
    
    self.detailViewController = [[MalayalamBibleDetailViewController alloc] init];                
    self.detailViewController.selectedBook = self.selectedBook;
    self.detailViewController.chapterId = chapter;
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"orientation change");
    
    NSArray *viewsToRemove = [scrollViewBar subviews];
    int i = 0;
    for (UIView *v in viewsToRemove) {
        if(i++ > 0) {
            [v removeFromSuperview];
        }
    }
    
    [self configureView];
}

@end
