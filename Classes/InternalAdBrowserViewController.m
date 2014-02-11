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
#import <AFNetworking.h>
#import <AFNetworking/UIAlertView+AFNetworking.h>

@interface InternalAdBrowserViewController ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *sessionManager;

- (void)loadAdForURL:(NSURL *)url;

@end

@implementation InternalAdBrowserViewController

@synthesize sessionManager;

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!self.sessionManager) {
        self.sessionManager = [AFHTTPRequestOperationManager manager];
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"X-Client-App"];
        [requestSerializer setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"User-Agent"];
        [requestSerializer setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"User_Agent"];
        self.sessionManager.requestSerializer = requestSerializer;
    }
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)p_webView shouldStartLoadWithRequest:(NSURLRequest *)p_request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStartLoad = [super webView:p_webView shouldStartLoadWithRequest:p_request navigationType:navigationType];

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [p_webView stopLoading];
        [self loadAdForURL:[p_request URL]];

        return NO;
    }
    
    return shouldStartLoad;
}

- (void)loadAdForURL:(NSURL *)url
{
    NSLog(@"Requesting: %@", [url absoluteString]);

    [self.activityIndicator startAnimating];
    __weak InternalAdBrowserViewController *weakSelf = self;
    AFHTTPRequestOperation *operation = [self.sessionManager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        AdHawkAd *ad = [[AdHawkAPI sharedInstance] convertResponseToAdHawkAd:responseObject];
        AdDetailViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"AdDetailViewController"];

        if (ad) {
            vc.targetURL = ad.resultURL;
            vc.shareText = ad.shareText;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure");
    }];

    [UIAlertView showAlertViewForRequestOperationWithErrorOnCompletion:operation delegate:self];
}

@end
