//
//  AdDetailViewController.m
//  adhawk
//
//  Created by Jim Snavely on 6/22/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdDetailViewController.h"
#import "AppMacros.h"

@implementation AdDetailViewController

@synthesize webView, targetURL;

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
    TFPLog(@"Requesting: @%", targetURL);
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

@end
