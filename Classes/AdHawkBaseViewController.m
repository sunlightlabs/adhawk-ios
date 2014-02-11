//
//  AdHawkBaseViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/23/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkBaseViewController.h"
#import "AboutViewController.h"
#import "Settings.h"
#import "AdHawkAPI.h"

@implementation AdHawkBaseViewController

@synthesize socialEnabled;
@synthesize shareText;

- (void)setupUIElements
{
    // Prep navigationController buttons. These will be added to navigationController on viewWillAppear.
    _socialButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSocialActionSheet:)];
//    _settingsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    _settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain 
                                                      target:self action:@selector(showSettingsView)];
//    _aboutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(showAboutView)];
    _aboutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"] style:UIBarButtonItemStylePlain 
                                                   target:self action:@selector(showAboutView)];
    _navButtons = [[NSArray alloc] initWithObjects:_settingsButton, _aboutButton, nil];
    
    // Set logo in Toolbar. [self enableSocial] must be run seprately to add the sharing button to the toolbar.
    UIImage *bgImage = [UIImage imageNamed:@"btm"];
    [[UIToolbar appearance] setBackgroundImage:bgImage forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [self.navigationController.toolbar setTranslucent:YES]; 
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sunlight"]];
    _logoItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _toolBarItems = [[NSMutableArray alloc] initWithObjects:flexibleSpace, _logoItem, nil];
}

// Will add a flexible space and social Button to the toolbaritems.
- (void)enableSocial
{
    if ([_toolBarItems objectAtIndex:0] != _socialButton) {
        [_toolBarItems insertObject:_socialButton atIndex:0];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupUIElements];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setToolbarItems:_toolBarItems animated:NO];
    _toolbar = [self navigationController].toolbar;
    _toolbar.translucent = YES;
    [self.navigationItem setRightBarButtonItems:_navButtons animated:NO];
    [[self navigationController] setToolbarHidden:NO animated:NO];
}

- (void)showSettingsView
{
    NSLog(@"Show settings view");
    UIViewController *svc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PreferencesViewController"];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)showAboutView
{
    NSLog(@"Show about view");
    AboutViewController *avc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutViewController"];
    [self.navigationController pushViewController:avc animated:YES];
    //    [self performSegueWithIdentifier:@"aboutSegue" sender:self];
}

#pragma mark - IBActions

- (IBAction)showSocialActionSheet:(id)sender
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.shareText] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:NULL];
}

@end
