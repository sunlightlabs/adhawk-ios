//
//  InternalAdBrowserViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/26/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "InternalAdBrowserViewController.h"
#import "AdDetailViewController.h"

@implementation InternalAdBrowserViewController

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

- (BOOL)webView:(UIWebView *)p_webView shouldStartLoadWithRequest:(NSURLRequest *)p_request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStartLoad = [super webView:p_webView shouldStartLoadWithRequest:p_request navigationType:navigationType];

    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        AdDetailViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"adDetailVC"];
        [vc setTargetURLString:[[p_request URL] absoluteString]];
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    
    return shouldStartLoad;
}


@end
