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
    BOOL _authed;
}

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, copy) NSURL *targetURL;
@property (nonatomic) BOOL loadTargetURLonViewWillAppear;

- (void)setAndLoadTargetURL:(NSURL *)url;

@end


