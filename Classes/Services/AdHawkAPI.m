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

@interface AdHawkAPI ()

- (AdHawkAd *)convertResponseToAdHawkAd:(id)responseObject;

@end

@implementation AdHawkAPI

@synthesize baseURL, manager, requestSerializer, currentAd, currentAdHawkURL, searchDelegate;

+ (AdHawkAPI *) sharedInstance
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
        self.baseURL = [NSURL URLWithString:ADHAWK_API_BASE_URL];

        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.requestSerializer setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"User-Agent"];

        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];
        manager.requestSerializer = self.requestSerializer;
    }

    return self;
}

- (void)searchForAdWithFingerprint:(NSString*)fingerprint delegate:(id)delegate {
    searchDelegate = delegate;
    NSNumber *lat = [NSNumber numberWithInt:0];
    NSNumber *lon = [NSNumber numberWithInt:0];
    
    CLLocation *location = [[AdHawkLocationManager sharedInstance] lastBestLocation];
    
    if (location != nil) {
        lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        lon = [NSNumber numberWithDouble:location.coordinate.longitude];
    }

    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithCapacity:3];
    [postParams setObject:fingerprint forKey:@"fingerprint"];
    [postParams setObject:lat forKey:@"lat"];
    [postParams setObject:lon forKey:@"lon"];
    if (TESTING == YES) [TestFlight passCheckpoint:@"Submitted Fingerprint"];

    [self.manager POST:@"ad/" parameters:postParams success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"It Worked: %@", responseObject);
        AdHawkAd *ad = [self convertResponseToAdHawkAd:responseObject];
        if (ad && ![ad.resultURL isEqual:[NSNull null]]) {
            TFLog(@"Got back an AdHawk ad object!");
            self.currentAd = ad;
            self.currentAdHawkURL = self.currentAd.resultURL;
            [[self searchDelegate] adHawkAPIDidReturnURL:self.currentAdHawkURL];
        }
        else {
            TFLog(@"currentAdHawkURL is null: issue adHawkAPIDidReturnNoResult");
            [[self searchDelegate] adHawkAPIDidReturnNoResult];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        TFLog(@"searchForAdWithFingerprint Error: %@", error.localizedDescription);
        [[self searchDelegate] adHawkAPIDidReturnNoResult];
    }];
}

- (AdHawkAd *)getAdHawkAdFromURL:(NSURL *)reqURL
{
    NSMutableURLRequest *adhawkRequest = [[NSMutableURLRequest alloc] initWithURL:reqURL];
    [adhawkRequest setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"X-Client-App"];
    [adhawkRequest setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"User_Agent"];
    [adhawkRequest setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"User-Agent"];
    NSLog(@"Requesting: %@", [[adhawkRequest URL] absoluteString]);

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:adhawkRequest];
    [UIAlertView showAlertViewForRequestOperationWithErrorOnCompletion:operation delegate:self];

    __weak AdHawkAPI *weakSelf = self;

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        AdHawkAd *ad = [weakSelf convertResponseToAdHawkAd:responseObject];
        weakSelf.currentAd = ad;
        weakSelf.currentAdHawkURL = self.currentAd.resultURL;
    } failure:nil];

    return self.currentAd;
}

- (AdHawkAd *)convertResponseToAdHawkAd:(id)responseObject
{
    AdHawkAd *ad;
    if ([responseObject respondsToSelector:@selector(valueForKey:)]) {
        NSString *urlString = [responseObject valueForKey:@"result_url"];
        NSString *shareText = [responseObject valueForKey:@"share_text"];
        if (![urlString isEqual:[NSNull null]] || ![shareText isEqual:[NSNull null]]) {
            ad = [AdHawkAd new];
            ad.resultURL = [NSURL URLWithString:urlString];
            ad.shareText = shareText;
        }
    }
    return ad;
}

@end
