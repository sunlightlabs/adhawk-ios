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

@implementation AdHawkAPI

@synthesize currentAd, currentAdHawkURL, baseUrl=ADHAWK_API_BASE_URL;

+ (AdHawkAPI *) sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    [super init];
    [AdHawkAPI registerMappings];
    
    return self;
}

+ (RKObjectManager *)registerMappings
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
//    [manager.router routeClass:[AdHawkAd class] toResourcePath:@"/ad/"];
//    [manager.router routeClass:[AdHawkQuery class] toResourcePath:@"/ad/" forMethod:RKRequestMethodPOST];
    
    [RKObjectManager setSharedManager:manager];
    
    return manager;
}

//- (NSURL *)loadAdURLForFingerprint:(NSString*)fingerprint {
//    NSMutableDictionary* birdIsTheWord = [NSMutableDictionary dictionaryWithCapacity:0];
//    [birdIsTheWord setObject:fingerprint forKey:@"fingerprint"];
//    [birdIsTheWord setObject:[NSNumber numberWithInt:0] forKey:@"lat"];
//    [birdIsTheWord setObject:[NSNumber numberWithInt:0] forKey:@"lon"];
//    
//    NSURL *url = [NSURL URLWithString:self.baseUrl];
//    NSURLRequest *req = [NSURLRequest initWithURL:url];
//    req.HTTPMethod=@"POST";
//    
//    return url;
//}

- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader {
    NSLog(@"Object Loader Finished: %@", objectLoader.resourcePath);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    NSLog(@"Loaded Object");
    if ([object isKindOfClass:[AdHawkAd class]]) {
        NSLog(@"Got back an AdHawk ad object!");
        self.currentAd = (AdHawkAd *)object;
        self.currentAdHawkURL = self.currentAd.result_url;
    }
}


- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"Object Loader Failed: %@", error.localizedDescription);
}



@end
