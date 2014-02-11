//
//  AdHawkAd.m
//  adhawk
//
//  Created by Daniel Cloud on 7/12/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkAd.h"

@implementation AdHawkAd

@synthesize resultURL;
@synthesize shareText;

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary
{
    NSString *urlString = [dictionary valueForKey:@"result_url"];
    NSString *shareText = [dictionary valueForKey:@"share_text"];

    AdHawkAd *object;

    if (![urlString isEqual:[NSNull null]] || ![shareText isEqual:[NSNull null]]) {
        object = [self new];
        object.resultURL = [NSURL URLWithString:urlString];
        object.shareText = shareText;
    }

    return object;
}

@end
