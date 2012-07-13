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

//+ (AdHawkAPI *) sharedInstance
//{
//    static dispatch_once_t pred = 0;
//    
//    __strong static id _sharedObject = nil;
//    dispatch_once(&pred, ^{
//        _sharedObject = [[self alloc] init]; // or some other init method
//    });
//    return _sharedObject;
//}

+ (RKObjectManager *)registerMappings
{
    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:[RKURL URLWithBaseURLString:ADHAWK_API_BASE_URL]];
    manager.acceptMIMEType = RKMIMETypeJSON;
    manager.serializationMIMEType = RKMIMETypeJSON;
    
    RKObjectMapping* adMapping = [RKObjectMapping mappingForClass:[AdHawkAd class]];
    [adMapping mapAttributes: @"ad_profile_url", nil];    
    
    RKObjectMapping* queryMapping = [RKObjectMapping mappingForClass:[AdHawkQuery class]];
    [queryMapping mapAttributes:@"fingerprint", @"lon", @"lat", nil];
    [manager.mappingProvider setSerializationMapping:queryMapping forClass:[AdHawkQuery class]];

    [manager.mappingProvider setMapping:adMapping forKeyPath:@""];
//    [manager.router routeClass:[AdHawkAd class] toResourcePath:@"/ad/"];
//    [manager.router routeClass:[AdHawkQuery class] toResourcePath:@"/ad/" forMethod:RKRequestMethodPOST];
    
    [RKObjectManager setSharedManager:manager];
    
    return manager;
}

- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader {
    RKLogDebug(@"Object Loader Finished: %@", objectLoader.resourcePath);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    RKLogDebug(@"Object Loader Failed: %@", error.localizedDescription);
}



@end
