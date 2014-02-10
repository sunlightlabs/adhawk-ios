//
//  AdHawkAPI.m
//  adhawk
//
//  Created by Daniel Cloud on 7/12/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkAPI.h"
#import "Settings.h"
#import "AdHawkAd.h"


NSURL *endPointURL(NSString * path)
{
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:ADHAWK_API_BASE_URL]];
    
}

@implementation AdHawkAPI

@synthesize baseURL, currentAd, currentAdHawkURL, searchDelegate;

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
        RKObjectManager* manager = [RKObjectManager managerWithBaseURL:self.baseURL];
        [manager.HTTPClient setDefaultHeader:@"User-Agent" value:ADHAWK_APP_USER_AGENT];
        [manager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
        manager.requestSerializationMIMEType = RKMIMETypeJSON;

        [RKObjectManager setSharedManager:manager];

        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

        // MARK: Set up AdHawkAd mapping
        _adHawkAdMapping = [RKObjectMapping mappingForClass:[AdHawkAd class]];
        [_adHawkAdMapping addAttributeMappingsFromDictionary:@{@"result_url":@"resultURL", @"share_text":@"shareText"}];
        [manager addResponseDescriptor:[RKResponseDescriptor
                                        responseDescriptorWithMapping:_adHawkAdMapping
                                        method:RKRequestMethodAny
                                        pathPattern:@""
                                        keyPath:nil
                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
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


    [[RKObjectManager sharedManager] getObjectsAtPath:@"/ad/" parameters:postParams
    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"It Worked: %@", [mappingResult firstObject]);
        id object = [mappingResult firstObject];
        if ([object isKindOfClass:[AdHawkAd class]]) {
            TFLog(@"Got back an AdHawk ad object!");
            self.currentAd = (AdHawkAd *)object;
            self.currentAdHawkURL = self.currentAd.resultURL;
            if (self.currentAdHawkURL != NULL) {
                [[self searchDelegate] adHawkAPIDidReturnURL:self.currentAdHawkURL];

            }
            else {
                TFLog(@"currentAdHawkURL is null: issue adHawkAPIDidReturnNoResult");
                [[self searchDelegate] adHawkAPIDidReturnNoResult];
            }
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        TFLog(@"Got back an object, but it didn't conform to AdHawkAd");
        [[self searchDelegate] adHawkAPIDidReturnNoResult];
    }];

}

- (AdHawkAd *)getAdHawkAdFromURL:(NSURL *)reqURL
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSMutableURLRequest *adhawkRequest = [[[NSMutableURLRequest alloc] initWithURL:reqURL] autorelease];
    [adhawkRequest setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"X-Client-App"];
    [adhawkRequest setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"User_Agent"];
    [adhawkRequest setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"User-Agent"];
    NSLog(@"Requesting: %@", [[adhawkRequest URL] absoluteString]);

    NSURLResponse *the_response = [[NSURLResponse alloc] init];
    NSError *urlError = nil;
    NSData *resultData = [NSURLConnection sendSynchronousRequest:adhawkRequest returningResponse:&the_response error:&urlError];
    
    if(!urlError)
    {
        NSLog(@"Got response");
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:nil];
        AdHawkAd *the_ad = [[AdHawkAd alloc] init];
        the_ad.resultURL = [NSURL URLWithString:[jsonDict objectForKey:@"result_url"]];
        the_ad.shareText = (NSString *)[jsonDict objectForKey:@"share_text"];
        self.currentAd = the_ad; 
        self.currentAdHawkURL = self.currentAd.resultURL;
        
        return the_ad;
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Ad Hawk encountered an error while trying to load this resource" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }

    
    return NULL;
}

@end
