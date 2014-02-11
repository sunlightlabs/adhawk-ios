//
//  SimpleWebViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/27/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "SimpleWebViewController.h"
#import "Settings.h"
#import "UIWebView+AFNetworking.h"

@interface SimpleWebViewController ()

- (void)loadTargetURL;

@end

@implementation SimpleWebViewController

@synthesize webView;
@synthesize activityIndicator;
@synthesize targetURL;
@synthesize loadTargetURLonViewWillAppear;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.loadTargetURLonViewWillAppear = @YES;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.webView.delegate = self;
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)];
    self.webView.backgroundColor = [UIColor whiteColor];

    for (UIView *shadowView in [webView.scrollView subviews]) {
        if ([shadowView isKindOfClass:[UIImageView class]]) {
            [shadowView setHidden:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.loadTargetURLonViewWillAppear) {
        [self loadTargetURL];
    }
}

#pragma mark - SimpleWebViewController methods

- (void)setAndLoadTargetURL:(NSURL *)url
{
    self.targetURL = url;
    [self loadTargetURL];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)p_webView shouldStartLoadWithRequest:(NSURLRequest *)p_request navigationType:(UIWebViewNavigationType)navigationType
{
    self.targetURL = (self.targetURL != [p_request URL]) ? [p_request URL] : self.targetURL;

    if ([[self.targetURL host] isEqualToString:@"cdns.gigya.com"]) {
        [p_webView stopLoading];
    }

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

- (void)webView:(UIWebView *)p_webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error: %@", [error localizedDescription]);
    UIAlertView *e_alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"I understand" otherButtonTitles:nil];
    [e_alert show];
}

#pragma mark - Private

- (void)loadTargetURL
{
    if (self.targetURL && ![[self.targetURL absoluteString] isEqualToString: @""]) {
        NSLog(@"Requesting: %@", [self.targetURL absoluteString]);
        NSURLRequest *req = [NSURLRequest requestWithURL:self.targetURL];
        [self.webView loadRequest:req];
        if (TESTING == YES) [TestFlight passCheckpoint:@"Requested Ad detail page"];
    }
}

@end
