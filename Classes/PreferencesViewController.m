//
//  PreferencesViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 8/3/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "PreferencesViewController.h"

@implementation PreferencesViewController

@synthesize shareLocationSwitch;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self->_prefMan updateStoredPreferences];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setRightBarButtonItems:nil animated:YES];
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

@end
