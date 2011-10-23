//
//  ChapterSelection.m
//  Malayalam Bible
//
//  Created by Jeesmon Jacob on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ChapterSelection.h"

#define FONT_SIZE 17.0f

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
        
    NSInteger width = self.view.frame.size.width;
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
}

- (void) buttonClicked: (id)sender
{
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];   
    temporaryBarButtonItem.title = @"അദ്ധ്യായങ്ങൾ";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    UIButton *btn = (UIButton *)sender;
    
    self.detailViewController = [[MalayalamBibleDetailViewController alloc] initWithNibName:@"MalayalamBibleDetailViewController_iPhone" bundle:nil];                
    self.detailViewController.selectedBook = self.selectedBook;
    self.detailViewController.chapterId = btn.tag;
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) loadView
{
    [super loadView];
    NSLog(@"loadView");
}

@end
