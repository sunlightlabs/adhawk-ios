//
//  AdHawkAPI.h
//  adhawk
//
//  Created by Daniel Cloud on 7/12/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject;

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AdHawkAd.h"

@interface AdHawkAPI : NSObject <RKObjectLoaderDelegate, RKRequestQueueDelegate>
+ (AdHawkAPI *)sharedInstance;
@property (readonly, strong) NSString *baseUrl;
@property (nonatomic, strong) AdHawkAd *currentAd;
@property (nonatomic, strong) NSURL *currentAdHawkURL;
@end
