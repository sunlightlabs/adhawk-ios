//
//  AboutViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/25/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AboutViewController.h"
#import "Settings.h"

@implementation AboutViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Make sure about page doesn't have about button!
    [self.navigationItem setRightBarButtonItems:[[NSArray alloc] initWithObjects:_settingsButton, nil] animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"AboutView loaded");
    NSMutableURLRequest *_urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:ADHAWK_ABOUT_URL]];
    [webView loadRequest:_urlReq];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)p_webView shouldStartLoadWithRequest:(NSURLRequest *)p_request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStartLoad = [super webView:p_webView shouldStartLoadWithRequest:p_request navigationType:navigationType];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[p_request URL]];
        [p_webView stopLoading];
        return NO;
    }

    return shouldStartLoad;
}


- (void)webView:(UIWebView *)p_webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
