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

@synthesize currentAd, currentAdHawkURL, searchDelegate;

+ (AdHawkAPI *) sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];

    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:[RKURL URLWithBaseURLString:ADHAWK_API_BASE_URL]];
    [manager.client setValue:ADHAWK_APP_USER_AGENT forHTTPHeaderField:@"User-Agent"];
    manager.acceptMIMEType = RKMIMETypeJSON;
    manager.serializationMIMEType = RKMIMETypeJSON;    
    
    [RKObjectManager setSharedManager:manager];
    _adMapping = [RKObjectMapping mappingForClass:[AdHawkAd class]];
    [_adMapping mapAttributes: @"result_url", nil];    
    [_adMapping mapAttributes:@"share_text", nil];
    [manager.mappingProvider setMapping:_adMapping forKeyPath:@""];
    
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
//    if (nil != self._lastBestLocation) {
//        lat = [NSNumber numberWithDouble:self._lastBestLocation.coordinate.latitude];
//        lon = [NSNumber numberWithDouble:self._lastBestLocation.coordinate.longitude];
//    }
    
    NSMutableDictionary* birdIsTheWord = [NSMutableDictionary dictionaryWithCapacity:3];
    [birdIsTheWord setObject:fingerprint forKey:@"fingerprint"];
    [birdIsTheWord setObject:lat forKey:@"lat"];
    [birdIsTheWord setObject:lon forKey:@"lon"];
    TFLog(@"Submitting fingerprint... ");
    
//    NSURL *reqURL = endPointURL(@"/ad/");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    RKObjectManager* manager = [RKObjectManager sharedManager];
    [manager loadObjectsAtResourcePath:@"/ad/" usingBlock:^(RKObjectLoader * loader) {
        loader.serializationMIMEType = RKMIMETypeJSON;
        loader.objectMapping = [manager.mappingProvider objectMappingForClass:[AdHawkAd class]];
        loader.resourcePath = @"/ad/";
        loader.method = RKRequestMethodPOST;
        loader.delegate = self;
        [loader setBody:birdIsTheWord forMIMEType:RKMIMETypeJSON];
        [TestFlight passCheckpoint:@"Submitted Fingerprint"];
    }];
    
//    NSURLRequest *req = [NSURLRequest initWithURL:url];
//    req.HTTPMethod=@"POST";


}

- (AdHawkAd *)getAdHawkAdFromURL:(NSURL *)reqURL
{
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
        the_ad.result_url = [NSURL URLWithString:[jsonDict objectForKey:@"result_url"]];
        the_ad.share_text = (NSString *)[jsonDict objectForKey:@"share_text"];
        self.currentAd = the_ad; 
        self.currentAdHawkURL = self.currentAd.result_url;
        
        return the_ad;
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Ad Hawk encountered an error while trying to load this resource" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }

    
    return NULL;
}

#pragma mark - ObjectLoaderDelegate messages

- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader {
    NSLog(@"Object Loader Finished: %@", objectLoader.resourcePath);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    TFLog(@"Loaded Object");
    
    RKResponse *response = objectLoader.response;
    NSLog(@"response: %@", [response bodyAsString]);
    
    if ([object isKindOfClass:[AdHawkAd class]]) {
        TFLog(@"Got back an AdHawk ad object!");
        self.currentAd = (AdHawkAd *)object;
        self.currentAdHawkURL = self.currentAd.result_url;
        if (self.currentAdHawkURL != NULL) {
            [[self searchDelegate] adHawkAPIDidReturnURL:self.currentAdHawkURL];

        }
        else {
            TFLog(@"currentAdHawkURL is null: issue adHawkAPIDidReturnNoResult");
            [[self searchDelegate] adHawkAPIDidReturnNoResult];
        }
    }
    else {
        TFLog(@"Got back an object, but it didn't conform to AdHawkAd");
        [[self searchDelegate] adHawkAPIDidReturnNoResult];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    TFLog(@"%@", error.localizedDescription);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Server Error", @"title",
//                              @"There was a problem retrieving information from the Ad Hawk server.", @"message", nil];
//    NSError *p_error = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
    [[self searchDelegate] adHawkAPIDidReturnNoResult];
}

#pragma mark - RKRequestDelegate messages


- (void) request:(RKRequest *)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive
{
    NSLog(@"Received %d of %d", totalBytesReceived, totalBytesExpectedToReceive);
}

- (void) request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    NSLog(@"Received response from server: %@", response.localizedStatusCodeString);
}


- (void)requestDidTimeout:(RKRequest *)request
{
    TFLog(@"Request timed out!");
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Server Timed Out", @"title",
                              @"The Ad Hawk's server response timed out.", @"message", nil];
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:kCFURLErrorTimedOut userInfo:userInfo];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[self searchDelegate] adHawkAPIDidFailWithError:error];
}

@end
