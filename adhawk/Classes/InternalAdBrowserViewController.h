//
//  InternalAdBrowserViewController.h
//  adhawk
//
//  Created by Daniel Cloud on 7/26/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleWebViewController.h"

@interface InternalAdBrowserViewController : SimpleWebViewController <NSURLConnectionDelegate>
{
    BOOL _interceptedRequest;
}
@end
