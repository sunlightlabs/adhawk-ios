//
//  AdDetailViewController.h
//  whopaid
//
//  Created by Jim Snavely on 6/22/12.
//  Copyright (c) 2012 Thomsonreuters. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdDetailViewController : UIViewController {
    IBOutlet UIWebView *webView;
    NSString *targetURL;
}

@property (strong,nonatomic) NSString *targetURL;

@property (strong,nonatomic) UIWebView *webView;

@end
