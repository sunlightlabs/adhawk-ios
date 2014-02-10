//
//  AdHawkAPI.h
//  adhawk
//
//  Created by Daniel Cloud on 7/12/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AdHawkLocationManager.h"
#import "AdHawkAd.h"

NSURL *endPointURL(NSString *path);
RKObjectManager *setUpAPI(void);

@protocol AdHawkAPIDelegate <NSObject>
@required
-(void) adHawkAPIDidReturnURL:(NSURL *) url;
-(void) adHawkAPIDidReturnNoResult;
-(void) adHawkAPIDidFailWithError:(NSError *) error;
@end

@interface AdHawkAPI : NSObject
{
    RKObjectMapping *_adHawkAdMapping;
}

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, strong) AdHawkAd *currentAd;
@property (nonatomic, copy) NSURL *currentAdHawkURL;
@property (readonly, nonatomic) id <AdHawkAPIDelegate> searchDelegate;

+ (AdHawkAPI *)sharedInstance;
- (void)searchForAdWithFingerprint:(NSString*)fingerprint delegate:(id)delegate;
- (AdHawkAd *)getAdHawkAdFromURL:(NSURL *)reqURL;

@end
