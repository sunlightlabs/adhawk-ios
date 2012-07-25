//
//  AuthHandlingWebViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/25/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AuthHandlingWebViewController.h"
#import "Settings.h"

@implementation AuthHandlingWebViewController

@synthesize webView, targetURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        webView.delegate = self;

    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:(NSCoder *)aDecoder];
    
    if (self) {        
        webView.delegate = self;
    }
    return self;
}



#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    TFPLog(@"User-Agent: %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    TFPLog(@"Url: %@", [[request URL] absoluteString]);
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
    NSMutableURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [webView loadRequest:urlRequest];
    _authed = YES;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
{
    return NO;
}

@end
