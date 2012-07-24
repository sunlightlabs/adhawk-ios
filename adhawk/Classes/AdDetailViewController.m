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

@synthesize webView, targetURL;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    webView.delegate = self;
    
    TFPLog(@"Requesting: %@", targetURL);
    NSURL *url = [NSURL URLWithString:targetURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [webView loadRequest:req];
    [TestFlight passCheckpoint:@"Requested Ad detail page"];
    
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(!_authed)
    {
        _authed = NO;
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{}

- (void)webViewDidStartLoad:(UIWebView *)webView
{}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{}

#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    NSLog(@"got auth challange");
    
    if ([challenge previousFailureCount] == 0) {
        _authed = YES;
        /* SET YOUR credentials, i'm just hard coding them in, tweak as necessary */
        [[challenge sender] useCredential:[NSURLCredential credentialWithUser:ADHAWK_AUTH_USER password:ADHAWK_AUTH_PASSWORD persistence:NSURLCredentialPersistencePermanent] forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    NSLog(@"received response via nsurlconnection");
    
    /** THIS IS WHERE YOU SET MAKE THE NEW REQUEST TO UIWebView, which will use the new saved auth info **/
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [webView loadRequest:urlRequest];
    _authed = YES;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
{
    return NO;
}

@end

