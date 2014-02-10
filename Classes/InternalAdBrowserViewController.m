//
//  InternalAdBrowserViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/26/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "InternalAdBrowserViewController.h"
#import "AdDetailViewController.h"
#import "AdHawkAPI.h"
#import "AdHawkAd.h"
#import "Settings.h"

@implementation InternalAdBrowserViewController

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
    _interceptedRequest = NO;
	// Do any additional setup after loading the view.
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

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)p_webView shouldStartLoadWithRequest:(NSURLRequest *)p_request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStartLoad = [super webView:p_webView shouldStartLoadWithRequest:p_request navigationType:navigationType];

    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        AdDetailViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"adDetailVC"];
        
        AdHawkAd *theAd = [[AdHawkAPI sharedInstance] getAdHawkAdFromURL:[p_request URL]];
        if (theAd != NULL) {
            [p_webView stopLoading];
            _interceptedRequest = YES;
            NSString *absoluteURLString = [theAd.resultURL absoluteString];
            [vc setTargetURLString:absoluteURLString];
            [self.navigationController pushViewController:vc animated:YES];
        }

        return NO;
    }
    
    return shouldStartLoad;
}

- (void)webView:(UIWebView *)p_webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error: %@", [error localizedDescription]);
    if (!_interceptedRequest) {
        UIAlertView *e_alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"I understand" otherButtonTitles:nil];
        [e_alert show];
    }
    _interceptedRequest = NO; // Reset for next time?
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
