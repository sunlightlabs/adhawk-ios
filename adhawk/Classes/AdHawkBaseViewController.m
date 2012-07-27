//
//  AdHawkBaseViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/23/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkBaseViewController.h"
#import "AboutViewController.h"
#import "GigyaService.h"

@implementation AdHawkBaseViewController

@synthesize socialEnabled = _socialEnabled;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:(NSCoder *)aDecoder];
    
    if (self) {        
    }
    return self;
}

- (void) setupUIElements
{
    // Prep navigationController buttons. These will be added to navigationController on viewWillAppear.
    _socialButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSocialActionSheet:)];
    _settingsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    _aboutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(showAboutView)];
    _navButtons = [[NSArray alloc] initWithObjects:_settingsButton, _aboutButton, nil];
    
    // Set logo in Toolbar. [self enableSocial] must be run seprately to add the sharing button to the toolbar.
    UIImage *bgImage = [UIImage imageNamed:@"ToolbarBackground"];
    [[UIToolbar appearance] setBackgroundImage:bgImage forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [self.navigationController.toolbar setTranslucent:YES]; 
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sunlight"]];
    _logoItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _toolBarItems = [[NSMutableArray alloc] initWithObjects:flexibleSpace,_logoItem, nil];
}

// Will add a flexible space and social Button to the toolbaritems.
- (void) enableSocial
{
    if ([_toolBarItems objectAtIndex:0] != _socialButton) {
        [_toolBarItems insertObject:_socialButton atIndex:0];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupUIElements];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setToolbarItems:_toolBarItems animated:NO];
    _toolbar = [self navigationController].toolbar;
    _toolbar.translucent = YES;
    [self.navigationItem setRightBarButtonItems:_navButtons animated:NO];
    [[self navigationController] setToolbarHidden:NO animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) showAboutView
{
    NSLog(@"Show about view");
    AboutViewController *avc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"aboutAdHawk"];
    [self.navigationController pushViewController:avc animated:YES];
    //    [self performSegueWithIdentifier:@"aboutSegue" sender:self];
}

#pragma mark - IBActions

-(IBAction)showSocialActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share This" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tweet", @"Like on Facebook", nil];
    [actionSheet showFromToolbar:[[self navigationController] toolbar]];
}

#pragma mark - UIActionSheetDelegate callbacks

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TFPLog(@"Share Action Click");
    NSString *clickedButtonLabel = [actionSheet buttonTitleAtIndex:buttonIndex];
    TFPLog(@"Share button clicked: %@", clickedButtonLabel);
    if (buttonIndex == 0) {
        [TestFlight passCheckpoint:@"Share 'Twitter' clicked"];
        if ([TWTweetComposeViewController canSendTweet]) {
            [[GigyaService sharedInstanceWithViewController:self] showAddConnectionsUI];
        }
        else{
            TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
            
            [tweetViewController setInitialText:@"Hello. This is a tweet."];
            
            [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                
                BOOL didTweet = (result == TWTweetComposeViewControllerResultDone) ? YES : NO;
                
                [self performSelectorOnMainThread:@selector(handleTweetResult:) withObject:nil waitUntilDone:NO];
                
                // Dismiss the tweet composition view controller.
                [self dismissModalViewControllerAnimated:YES];
            }];
            
            [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:NO];
            [self presentModalViewController:tweetViewController animated:YES];
        }
    }
    else if (buttonIndex == 1) {
        [TestFlight passCheckpoint:@"Share 'Facebook' clicked"];
        [[GigyaService sharedInstanceWithViewController:self] showAddConnectionsUI];
    }
    
}

- (void) handleTweetResult:(BOOL)didTweet
{
//    TFPLog(<#__FORMAT__, ...#>)
//    switch (didTweet) {
//        case TWTweetComposeViewControllerResultCancelled:
//            // The cancel button was tapped.
//            output = @"Tweet cancelled.";
//            break;
//        case TWTweetComposeViewControllerResultDone:
//            // The tweet was sent.
//            output = @"Tweet done.";
//            break;
//        default:
//            break;
//    }

}


@end
