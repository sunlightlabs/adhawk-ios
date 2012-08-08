//
//  AppDelegate.h
//  adhawk
//
//  Created by James Snavely on 3/3/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    RKReachabilityObserver *_netReachability;
}

@property (strong, nonatomic) UIWindow *window;
- (void) handleReachabilityChange;
@end
