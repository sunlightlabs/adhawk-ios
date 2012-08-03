//
//  AdHawkBaseViewController.h
//  adhawk
//
//  Created by Daniel Cloud on 7/23/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>

@interface AdHawkBaseViewController : UIViewController <UIActionSheetDelegate>
{
    NSArray *_navButtons;
    NSMutableArray *_toolBarItems;
    UIBarButtonItem *_settingsButton;
    UIBarButtonItem *_socialButton;
    UIBarButtonItem *_aboutButton;
    UIBarButtonItem *_logoItem;
    UIToolbar *_toolbar;
    BOOL _socialEnabled;
}
@property (nonatomic) BOOL socialEnabled;

-(IBAction)showSocialActionSheet:(id)sender;
- (void) enableSocial;
- (void) showSettingsView;
- (void) showAboutView;

@end
