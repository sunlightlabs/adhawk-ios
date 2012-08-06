//
//  SimpleWebViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/27/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "SimpleWebViewController.h"
#import "Settings.h"



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
    [webView.scrollView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)];
    webView.backgroundColor = [UIColor whiteColor];
    for (UIView* shadowView in [webView.scrollView subviews])
    {
        if ([shadowView isKindOfClass:[UIImageView class]]) {
            [shadowView setHidden:YES];
        }
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
    
//    Check headers for custom x-header
    NSMutableURLRequest *customRequest = [p_request copy];
    
    BOOL needRequestOverride = [[p_request allHTTPHeaderFields] objectForKey:@"X-Client-App"] == nil ? YES : NO;
    
    if (needRequestOverride) {
        NSLog(@"Overriding headers");
        [customRequest addValue:CLIENT_APP_HEADER forHTTPHeaderField:@"X-Client-App"];
        [p_webView loadRequest:customRequest];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)p_webView
{
    NSLog(@"Url: %@", [[p_webView.request URL] absoluteString]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webViewDidStartLoad:(UIWebView *)p_webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

- (void)webView:(UIWebView *)p_webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error: %@", [error localizedDescription]);
    UIAlertView *e_alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"I understand" otherButtonTitles:nil];
    [e_alert show];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
