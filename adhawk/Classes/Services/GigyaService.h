//
//  GigyaService.h
//  adhawk
//
//  Created by Daniel Cloud on 7/20/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSAPI.h"

GSAPI *getAPIObject(void);

@interface GigyaService : NSObject {
    GSAPI *_api;
}
+ (GigyaService *)sharedInstanceWithViewController:(UIViewController *)mainViewController;

@property (readonly, nonatomic) GSAPI *api;

@end
