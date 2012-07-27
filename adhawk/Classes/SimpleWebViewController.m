//
//  SimpleWebViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/27/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "SimpleWebViewController.h"

@implementation SimpleWebViewController

@synthesize webView;

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
    webView.delegate = self;
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


- (void) setTargetURLString:(NSString *)p_targetURLString
{
    _targetURL = [NSURL URLWithString:p_targetURLString];
}

- (NSString *) targetURLString
{
    return [_targetURL absoluteString];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)p_webView shouldStartLoadWithRequest:(NSURLRequest *)p_request navigationType:(UIWebViewNavigationType)navigationType
{
    _targetURL = (_targetURL != [p_request URL]) ? [p_request URL] : _targetURL;
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)p_webView
{
    TFPLog(@"Url: %@", [[p_webView.request URL] absoluteString]);
}

- (void)webViewDidStartLoad:(UIWebView *)p_webView
{}

- (void)webView:(UIWebView *)p_webView didFailLoadWithError:(NSError *)error
{
    TFPLog(@"error: %@", [error localizedDescription]);
    UIAlertView *e_alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"I understand" otherButtonTitles:nil];
    [e_alert show];
}

@end
