//
//  AdhawkErrorViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/31/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdhawkErrorViewController.h"

@implementation AdhawkErrorViewController

@synthesize popularResultsButton, tryAgainButton, whyNoResultsButton;

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

@end
