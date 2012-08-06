//
//  AdDetailViewController.m
//  adhawk
//
//  Created by Jim Snavely on 6/22/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdDetailViewController.h"
#import "AppMacros.h"
#import "Settings.h"

@implementation AdDetailViewController


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self enableSocial];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    webView.delegate = self;
    
    if ([_targetURL absoluteString] != @"") {
        NSLog(@"Requesting: %@", [_targetURL absoluteString]);
        NSURLRequest *req = [NSURLRequest requestWithURL:_targetURL];
        [webView loadRequest:req];
        [TestFlight passCheckpoint:@"Requested Ad detail page"];
    }
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

- (void)webView:(UIWebView *)p_webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



@end

