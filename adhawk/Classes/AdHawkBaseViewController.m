//
//  AdHawkBaseViewController.m
//  adhawk
//
//  Created by Daniel Cloud on 7/23/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkBaseViewController.h"
#import "GigyaService.h"

@interface AdHawkBaseViewController ()

@end

@implementation AdHawkBaseViewController

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:(NSCoder *)aDecoder];
    
    if (self) {
        UIBarButtonItem *socialButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSocialActionSheet:)];
        [[self navigationItem] setRightBarButtonItem:socialButton];
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *socialButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSocialActionSheet:)];
        [[self navigationItem] setRightBarButtonItem:socialButton];
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

#pragma mark - IBActions

-(IBAction)showSocialActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share This" delegate:[GigyaService sharedInstanceWithViewController:self] cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tweet", @"Like on Facebook", nil];
    [actionSheet showInView:self.view];
}


@end
