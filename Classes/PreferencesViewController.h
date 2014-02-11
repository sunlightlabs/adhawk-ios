//
//  PreferencesViewController.h
//  adhawk
//
//  Created by Daniel Cloud on 8/3/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdHawkPreferencesManager.h"
#import "AdHawkBaseViewController.h"

@interface PreferencesViewController : AdHawkBaseViewController
{
    AdHawkPreferencesManager *_prefMan;
}

@property (nonatomic, strong) IBOutlet UISwitch *shareLocationSwitch;

-(IBAction)handleShareLocationSwitch:(UISwitch *)p_shareLocationSwitch;

@end
