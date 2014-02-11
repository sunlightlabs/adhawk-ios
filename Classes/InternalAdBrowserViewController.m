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

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)p_webView shouldStartLoadWithRequest:(NSURLRequest *)p_request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStartLoad = [super webView:p_webView shouldStartLoadWithRequest:p_request navigationType:navigationType];

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        AdDetailViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"AdDetailViewController"];
        
        AdHawkAd *theAd = [[AdHawkAPI sharedInstance] getAdHawkAdFromURL:[p_request URL]];

        if (theAd != NULL) {
            [p_webView stopLoading];
            vc.targetURL = theAd.resultURL;
            [self.navigationController pushViewController:vc animated:YES];
        }

        return NO;
    }
    
    return shouldStartLoad;
}

- (void)webView:(UIWebView *)p_webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error: %@", [error localizedDescription]);
}

@end
