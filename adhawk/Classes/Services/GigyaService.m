//
//  GigyaService.m
//  adhawk
//
//  Created by Daniel Cloud on 7/20/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "GigyaService.h"
#import "GSAPI.h"
#import "Settings.h"

GSAPI *getAPIObject(void)
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[GSAPI alloc] initWithAPIKey:GIGYA_API_KEY viewController:nil];
    })
}

@implementation GigyaService

@synthesize api = _api;

+ (GigyaService *) sharedInstanceWithViewController:(UIViewController *)mainViewController
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] initWithViewController:mainViewController];
    })
}

- (id) init {
    [super init];
    
    _api = getAPIObject();
    
    return self;
}

- (id) initWithViewController:(UIViewController *)mainViewController {
    self = [super init];
    
    if(self)
    {
        _api = [[GSAPI alloc] initWithAPIKey:GIGYA_API_KEY viewController:mainViewController];
    }
    
    return self;
}


@end
