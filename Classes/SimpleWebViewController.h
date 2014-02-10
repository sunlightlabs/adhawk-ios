//
//  SimpleWebViewController.h
//  adhawk
//
//  Created by Daniel Cloud on 7/27/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdHawkBaseViewController.h"

@interface SimpleWebViewController : AdHawkBaseViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    NSURL *_targetURL;
    BOOL _authed;
    
}

@property (strong,nonatomic) UIWebView *webView;

- (void) setTargetURLString:(NSString *)p_targetURLString;
- (NSString *) targetURLString;

@end


