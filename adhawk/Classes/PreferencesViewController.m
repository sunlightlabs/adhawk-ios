//
//  PreferencesViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 8/3/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "PreferencesViewController.h"

@implementation PreferencesViewController

@synthesize shareLocationSwitch, twitterAccountSwitch, facebookAccountSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self->_prefMan = [AdHawkPreferencesManager sharedInstance];
    [shareLocationSwitch setOn:self->_prefMan.locationEnabled];
    [twitterAccountSwitch setOn:self->_prefMan.twitterAccountEnabled];
    [facebookAccountSwitch setOn:self->_prefMan.facebookAccountEnabled];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self->_prefMan updateStoredPreferences];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)handleShareLocationSwitch:(UISwitch *)p_shareLocationSwitch
{
    self->_prefMan.locationEnabled = p_shareLocationSwitch.on;
    NSLog(@"handleShareLocationSwitch state: %@", self->_prefMan.locationEnabled ? @"ON" : @"OFF");
}

-(IBAction)handleTwitterAccountSwitch:(UISwitch *)p_twitterAccountSwitch
{
    NSLog(@"handleTwittterAccountSwitch state: %@", p_twitterAccountSwitch.on ? @"ON" : @"OFF");
//    Need to call a gigya method to deconnect account
    self->_prefMan.twitterAccountEnabled = p_twitterAccountSwitch.on;
}

-(IBAction)handleFacebookAccountSwitch:(UISwitch *)p_facebookAccountSwitch
{
    NSLog(@"handleFacebookAccountSwitch state: %@", p_facebookAccountSwitch.on ? @"ON" : @"OFF");
    //    Need to call a gigya method to deconnect account
    self->_prefMan.facebookAccountEnabled = p_facebookAccountSwitch.on;
}

@end
