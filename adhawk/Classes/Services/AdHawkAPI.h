//
//  AdHawkAPI.h
//  adhawk
//
//  Created by Daniel Cloud on 7/12/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AdHawkAd.h"

NSURL *endPointURL(NSString *path);
RKObjectManager *setUpAPI(void);

@protocol AdHawkAPIDelegate <NSObject>
@required
-(void) adHawkAPIDidReturnURL:(NSURL *) url;
@end

@interface AdHawkAPI : NSObject <RKObjectLoaderDelegate, RKRequestQueueDelegate>
+ (AdHawkAPI *)sharedInstance;
- (void)searchForAdWithFingerprint:(NSString*)fingerprint delegate:(id)delegate;
@property (nonatomic, strong) AdHawkAd *currentAd;
@property (nonatomic, strong) NSURL *currentAdHawkURL;
@property (readonly, nonatomic) id <AdHawkAPIDelegate> searchDelegate;
@end
