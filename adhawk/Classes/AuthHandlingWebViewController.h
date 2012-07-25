//
//  AuthHandlingWebViewController.h
//  adhawk
//
//  Created by Daniel Cloud on 7/25/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdHawkBaseViewController.h"

@interface AuthHandlingWebViewController : AdHawkBaseViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    NSString *targetURL;
    BOOL _authed;

}

@property (strong,nonatomic) NSString *targetURL;

@property (strong,nonatomic) UIWebView *webView;

@end
