//
//  AdDetailViewController.h
//  adhawk
//
//  Created by Jim Snavely on 6/22/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdHawkBaseViewController.h"

@interface AdDetailViewController : AdHawkBaseViewController {
    IBOutlet UIWebView *webView;
    NSString *targetURL;
}

@property (strong,nonatomic) NSString *targetURL;

@property (strong,nonatomic) UIWebView *webView;

@end
