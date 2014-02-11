//
//  AdDetailViewController.m
//  adhawk
//
//  Created by Jim Snavely on 6/22/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdDetailViewController.h"
#import "Settings.h"

@implementation AdDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self enableSocial];
}

- (BOOL)webView:(UIWebView *)p_webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStartLoad = [super webView:p_webView shouldStartLoadWithRequest:request navigationType:navigationType];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        [p_webView stopLoading];

        return NO;
    }
    
    return shouldStartLoad;
}

@end
