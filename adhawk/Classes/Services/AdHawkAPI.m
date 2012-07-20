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
#import "AdHawkQuery.h"

NSURL *endPointURL(NSString * path)
{
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:ADHAWK_API_BASE_URL]];
    
}

RKObjectManager *setUpAPI(void)
{
    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:[RKURL URLWithBaseURLString:ADHAWK_API_BASE_URL]];
    manager.acceptMIMEType = RKMIMETypeJSON;
    manager.serializationMIMEType = RKMIMETypeJSON;
    
    RKObjectMapping* adMapping = [RKObjectMapping mappingForClass:[AdHawkAd class]];
    [adMapping mapAttributes: @"result_url", nil];    
    
    RKObjectMapping* queryMapping = [RKObjectMapping mappingForClass:[AdHawkQuery class]];
    [queryMapping mapAttributes:@"fingerprint", @"lon", @"lat", nil];
    [manager.mappingProvider setSerializationMapping:queryMapping forClass:[AdHawkQuery class]];
    
    [manager.mappingProvider setMapping:adMapping forKeyPath:@""];
    
    [RKObjectManager setSharedManager:manager];
    
    return manager;
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
    [super init];
    setUpAPI();
    
    return self;
}

- (void)searchForAdWithFingerprint:(NSString*)fingerprint delegate:(id)delegate {
    searchDelegate = delegate;
    NSMutableDictionary* birdIsTheWord = [NSMutableDictionary dictionaryWithCapacity:3];
    [birdIsTheWord setObject:fingerprint forKey:@"fingerprint"];
    [birdIsTheWord setObject:[NSNumber numberWithInt:0] forKey:@"lat"];
    [birdIsTheWord setObject:[NSNumber numberWithInt:0] forKey:@"lon"];
    
//    NSURL *reqURL = endPointURL(@"/ad/");
    
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

- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader {
    NSLog(@"Object Loader Finished: %@", objectLoader.resourcePath);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    NSLog(@"Loaded Object");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([object isKindOfClass:[AdHawkAd class]]) {
        TFPLog(@"Got back an AdHawk ad object!");
        self.currentAd = (AdHawkAd *)object;
        self.currentAdHawkURL = self.currentAd.result_url;
        [[self searchDelegate] adHawkAPIDidReturnURL:self.currentAdHawkURL];
    }
    else {
        TFPLog(@"Got back an object, but it didn't conform to AdHawkAd");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"The server didn't return data AdHawk could identify" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil]; 
        [alertView show];
    }

}


- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"Object Loader Failed: %@", error.localizedDescription);
}



@end
