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

@class AFHTTPSessionManager;
@class AFHTTPRequestSerializer;

@protocol AdHawkAPIDelegate <NSObject>
@required
- (void)adHawkAPIDidReturnAd:(AdHawkAd *)ad;
- (void)adHawkAPIDidReturnNoResult;
- (void)adHawkAPIDidFailWithError:(NSError *)error;
@end

@interface AdHawkAPI : NSObject

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
@property (weak, readonly, nonatomic) id <AdHawkAPIDelegate> searchDelegate;

+ (instancetype)sharedInstance;
- (void)searchForAdWithFingerprint:(NSString *)fingerprint delegate:(id)delegate;
- (AdHawkAd *)convertResponseToAdHawkAd:(id)responseObject;

@end
