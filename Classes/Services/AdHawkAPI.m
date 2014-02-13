//
//  AdHawkAPI.m
//  adhawk
//
//  Created by Daniel Cloud on 7/12/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkAPI.h"
#import "AdHawkAd.h"
#import <AFNetworking.h>
#import <UIAlertView+AFNetworking.h>

@implementation AdHawkAPI

@synthesize baseURL, manager, requestSerializer, searchDelegate;

+ (instancetype)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    
    if (self) {
        // MARK: Set up object manager baseURL, headers, and mimetypes
        self.baseURL = [NSURL URLWithString:kAdHawkBaseURL];

        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.requestSerializer setValue:kAdHawkUserAgent forHTTPHeaderField:@"User-Agent"];

        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
        manager.requestSerializer = self.requestSerializer;
    }

    return self;
}

- (void)searchForAdWithFingerprint:(NSString *)fingerprint delegate:(id)delegate
{
    searchDelegate = delegate;
    NSNumber *lat = [NSNumber numberWithInt:0];
    NSNumber *lon = [NSNumber numberWithInt:0];
    
    CLLocation *location = [[AdHawkLocationManager sharedInstance] lastBestLocation];
    
    if (location != nil) {
        lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        lon = [NSNumber numberWithDouble:location.coordinate.longitude];
    }

    NSDictionary *postParams = @{ @"fingerprint": fingerprint,
                                  @"lat": lat,
                                  @"lon": lon
                                };

#if TESTFLIGHT
    [TestFlight passCheckpoint:@"Submitting Fingerprint"];
#endif

    [self.manager POST:@"ad/" parameters:postParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"It Worked: %@", responseObject);
        AdHawkAd *ad = [self convertResponseToAdHawkAd:responseObject];

        if (ad && ![ad.resultURL isEqual:[NSNull null]]) {
            TFLog(@"Got back an AdHawk ad object!");
            [[self searchDelegate] adHawkAPIDidReturnAd:ad];
        } else {
            TFLog(@"currentAdHawkURL is null: issue adHawkAPIDidReturnNoResult");
            [[self searchDelegate] adHawkAPIDidReturnNoResult];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        TFLog(@"searchForAdWithFingerprint Error: %@", error.localizedDescription);
        [[self searchDelegate] adHawkAPIDidReturnNoResult];
    }];
}

- (AdHawkAd *)convertResponseToAdHawkAd:(id)responseObject
{
    AdHawkAd *ad;

    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        ad = [AdHawkAd objectFromDictionary:(NSDictionary *)responseObject];
    }

    return ad;
}

@end
