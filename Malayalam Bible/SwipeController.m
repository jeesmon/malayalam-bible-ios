//
//  SwipeController.m
//  Malayalam Bible
//
//  Created by Jijo Pulikkottil on 23/11/11.
//  Copyright (c) 2011 jpulikkottil@gmail.com. All rights reserved.
//

#import "SwipeController.h"

@implementation SwipeController



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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:[self.navigationController topViewController]  action:@selector(handleSwipeFrom:)];
	[self.view addGestureRecognizer:recognizer];
	
	
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:[self.navigationController topViewController] action:@selector(handleSwipeFrom:)];
	swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    
   
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

@end
