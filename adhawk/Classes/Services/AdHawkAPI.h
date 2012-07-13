//
//  AdHawkAPI.h
//  adhawk
//
//  Created by Daniel Cloud on 7/12/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface AdHawkAPI : NSObject <RKObjectLoaderDelegate, RKRequestQueueDelegate>
+ (AdHawkAPI *)registerMappings;
//+ (AdHawkAPI *) sharedInstance;
@end
