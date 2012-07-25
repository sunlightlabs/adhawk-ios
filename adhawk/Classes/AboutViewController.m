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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    TFPLog(@"AboutView loaded");
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ADHAWK_ABOUT_URL]]];
}

@end
