//
//  AboutViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/25/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AboutViewController.h"
#import "Settings.h"

@implementation AboutViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Make sure about page doesn't have about button!
    [self.navigationItem setRightBarButtonItems:[[NSArray alloc] initWithObjects:_settingsButton, nil] animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    TFPLog(@"AboutView loaded");
    NSMutableURLRequest *_urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:ADHAWK_ABOUT_URL]];
    [webView loadRequest:_urlReq];
}

@end
