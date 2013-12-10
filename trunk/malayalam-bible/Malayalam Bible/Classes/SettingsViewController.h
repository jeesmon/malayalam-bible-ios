//
//  SettingsViewController.h
//  Malayalam Bible
//
//  Created by jijo on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController{
    
    NSMutableArray *arraySettings;
    
    NSArray *arrayLangs;
    
    NSArray *arrayPrefs;
    
   
    
    NSString *selectedPrimary;
    NSString *selectedSecondary;
}



@end
