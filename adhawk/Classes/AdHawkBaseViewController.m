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
#import "GigyaService.h"
#import "AdHawkAPI.h"



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

- (void) showSettingsView
{
    NSLog(@"Show settings view");
    UIViewController *svc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"settingsVC"];
    [self.navigationController pushViewController:svc animated:YES];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share This" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tweet", nil];
    [actionSheet showFromToolbar:[[self navigationController] toolbar]];
}

#pragma mark - UIActionSheetDelegate callbacks

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Share Action Click");
    NSString *clickedButtonLabel = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"Share button clicked: %@", clickedButtonLabel);
    AdHawkAPI *adhawkApi = [AdHawkAPI sharedInstance];
    NSString *share_text = adhawkApi.currentAd != nil ? adhawkApi.currentAd.share_text : @"";
//    GigyaService *gs = [GigyaService sharedInstanceWithViewController:self];
//    NSString *serviceName = nil;
    if (buttonIndex == 0) {
        if (TESTING == YES) [TestFlight passCheckpoint:@"Share 'Twitter' clicked"];
        if ([TWTweetComposeViewController canSendTweet]) {
            TWTweetComposeViewController *tweetVC = [[TWTweetComposeViewController alloc] init];
            [tweetVC setInitialText:share_text];
            [tweetVC setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                NSString *output;
                
                switch (result) {
                    case TWTweetComposeViewControllerResultCancelled:
                        // The cancel button was tapped.
                        output = @"Tweet cancelled.";
                        break;
                    case TWTweetComposeViewControllerResultDone:
                        // The tweet was sent.
                        output = @"Tweet sent.";
                        break;
                    default:
                        break;
                }
                
                NSLog(@"Tweet status: %@", output);
                
                // Dismiss the tweet composition view controller.
                [self dismissModalViewControllerAnimated:YES];
            }];
            [self presentModalViewController:tweetVC animated:YES];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter not configured" message:@"Twitter does not appear to be configured on this device" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alertView show];
        }
//        serviceName = gs.TWITTER;
    }
    else if (buttonIndex == 1) {
        if (TESTING == YES) [TestFlight passCheckpoint:@"Share 'Facebook' clicked"];
//        serviceName = gs.FACEBOOK;
    }
//    [gs shareMessage:share_text toService:serviceName];
}

- (void) handleTweetResult:(BOOL)didTweet
{
//    NSLog(<#__FORMAT__, ...#>)
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
