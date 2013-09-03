//
//  RootWindow.m
//  Malayalam Bible
//
//  Created by jijo on 10/8/12.
//
//

#import "RootWindow.h"
#import "MalayalamBibleAppDelegate.h"
#import <objc/runtime.h>
#import "MBConstants.h"

@implementation RootWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)sendEvent:(UIEvent *)event {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
    
    MalayalamBibleAppDelegate *appDelegate = (MalayalamBibleAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //NSArray *allTouches = [[event allTouches] allObjects];
	UITouch *touch = [[event allTouches] anyObject];
	UIView *touchView = [touch view];
	//UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	/*UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if([UIApplication sharedApplication].statusBarHidden) {
		interfaceOrientation = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
	}*/
    if(isDetailControllerVisible)
    if (touchView && ([touchView isDescendantOfView:appDelegate.detailViewController.webViewVerses])) {
        
		bibleEvent = [touchView isDescendantOfView:appDelegate.detailViewController.webViewVerses];
        
        
        //
		// touchesBegan
		//
		/*if (touch.phase==UITouchPhaseBegan) {
			//touchAndHold = NO;
			ignoreMovementEvents = NO;
			movement = NO;
         			
			startTouchPosition1 = [touch locationInView:self];
			if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
				//switch x & y if in landscape mode
				CGFloat dummyX = startTouchPosition1.x;
				startTouchPosition1.x = startTouchPosition1.y;
				startTouchPosition1.y = dummyX;
			}
			//startTouchPosition1 = [touch locationInView:touchView];
			startTouchTime = touch.timestamp;
			
			if ([[event allTouches] count] > 1) {
				startTouchPosition2 = [[allTouches objectAtIndex:1] locationInView:self];
				previousTouchPosition1 = startTouchPosition1;
				previousTouchPosition2 = startTouchPosition2;
			}
			//DLog(@"pos.x = %f && pos.y == %f", startTouchPosition1.x, startTouchPosition1.y);
            [appDelegate.detailViewController toucheBegan:touch];
		}
        */
		//
		// touchesMoved
		//
		
		if (touch.phase==UITouchPhaseMoved) {
            //			if([holdTimer isValid]) {
            //				[holdTimer invalidate];
            //				self.holdTimer = nil;
            //			}
			//touchAndHold = NO;
            /*const char* className = class_getName([touch.view class]);
            NSLog(@"yourObject is a: %s", className);
            
            if( 0 != strcmp("UIWebSelectionHandle", className)){
                
                movement = YES;
                //DLog(@"--- UITouchPhaseMoved ---");
                if(bibleEvent && !ignoreMovementEvents && ([[event allTouches] count] == 3)) {
                    CGPoint currentTouchPosition = [touch locationInView:self];
                    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                        //switch x & y if in landscape mode
                        CGFloat dummyX = currentTouchPosition.x;
                        currentTouchPosition.x = currentTouchPosition.y;
                        currentTouchPosition.y = dummyX;
                    }
                    BOOL reverseSwipe = NO;
                    if(interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                        reverseSwipe = YES;
                    }
                    
                    
                    
                }
                [appDelegate.detailViewController toucheMoved:touch];

            }
            */
            
            
						/*if ([[event allTouches] count] > 1) {
             CGPoint currentTouchPosition1 = [[allTouches objectAtIndex:0] locationInView:self];
             CGPoint currentTouchPosition2 = [[allTouches objectAtIndex:1] locationInView:self];
             
             CGFloat currentFingerDistance = CGPointDist(currentTouchPosition1, currentTouchPosition2);
             CGFloat previousFingerDistance = CGPointDist(previousTouchPosition1, previousTouchPosition2);
             if (fabs(currentFingerDistance - previousFingerDistance) > ZOOM_DRAG_MIN) {
             NSNumber *movedDistance = [NSNumber numberWithFloat:currentFingerDistance - previousFingerDistance];
             if (currentFingerDistance > previousFingerDistance) {
             DLog(@"zoom in");
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ZOOM_IN object:movedDistance];
             } else {
             DLog(@"zoom out");
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ZOOM_OUT object:movedDistance];
             }
             }
             }*/
		}
        
		
		//
		// touchesEnded
		///
		if (touch.phase==UITouchPhaseEnded) {
            //			if([holdTimer isValid]) {
            //				[holdTimer invalidate];
            //				self.holdTimer = nil;
            //			}
			
            if ( [touch tapCount] == 2) {
                
                if(bibleEvent) {
                  
                    [appDelegate.detailViewController toggleFullScreen];
					//[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationBibleToggleFullscreen" object:nil];
				}
            }
            
			/*if (!movement && ([[event allTouches] count] == 2)) {
				//DLog(@"toggle-fullscreen-tap");
				
				if(bibleEvent) {
                  
					//[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationBibleToggleFullscreen" object:nil];
				}
			}*/
			
			/*CGPoint currentTouchPosition = [touch locationInView:self];
			if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
				//switch x & y if in landscape mode
				CGFloat dummyX = currentTouchPosition.x;
				currentTouchPosition.x = currentTouchPosition.y;
				currentTouchPosition.y = dummyX;
			}
			BOOL reverseSwipe = NO;
			if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
				reverseSwipe = YES;
			}
			
			
			startTouchPosition1 = CGPointMake(-1, -1);
            
            [appDelegate.detailViewController toucheEnded:touch];*/
		}
    }
    }

    
    [super sendEvent:event];
}

@end
