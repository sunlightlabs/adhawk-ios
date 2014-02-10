//
//  AuthHandlingWebViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/25/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AuthHandlingWebViewController.h"
#import "Settings.h"

#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


@implementation AuthHandlingWebViewController

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _authed = NO;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:(NSCoder *)aDecoder];
    
    if (self) {
        _authed = NO;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    webView.delegate = self;
    _authed = NO;
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
    NSLog(@"User-Agent: %@", [p_request valueForHTTPHeaderField:@"User-Agent"]);
    NSLog(@"Url: %@", [[p_request URL] absoluteString]);
    _targetURL = (_targetURL != [p_request URL]) ? [p_request URL] : _targetURL;
//    if(!_authed)
//    {
//        _authed = NO;
//        [[NSURLConnection alloc] initWithRequest:p_request delegate:self];
//        return NO;
//    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)p_webView
{
    NSLog(@"Url: %@", [[p_webView.request URL] absoluteString]);
}

- (void)webViewDidStartLoad:(UIWebView *)p_webView
{}

- (void)webView:(UIWebView *)p_webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error: %@", [error localizedDescription]);
    UIAlertView *e_alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"I understand" otherButtonTitles:nil];
    [e_alert show];
}

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
    NSMutableURLRequest *urlRequest = [NSURLRequest requestWithURL:_targetURL];
    NSLog(@"Look at url: %@", [[urlRequest URL] absoluteString]);
    [webView loadRequest:urlRequest];
    _authed = YES;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
{
    return NO;
}

@end
