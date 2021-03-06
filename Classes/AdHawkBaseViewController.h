//
//  AdHawkBaseViewController.h
//  adhawk
//
//  Created by Daniel Cloud on 7/23/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>

@interface AdHawkBaseViewController : UIViewController
{
    NSArray *_navButtons;
    NSMutableArray *_toolBarItems;
    UIBarButtonItem *_settingsButton;
    UIBarButtonItem *_socialButton;
    UIBarButtonItem *_aboutButton;
    UIBarButtonItem *_logoItem;
    UIToolbar *_toolbar;
}
@property (nonatomic) BOOL socialEnabled;
@property (nonatomic, copy) NSString *shareText;

- (IBAction)showSocialActionSheet:(id)sender;
- (void)enableSocial;
- (void)showSettingsView;
- (void)showAboutView;

@end
