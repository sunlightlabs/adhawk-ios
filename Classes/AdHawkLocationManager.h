//
//  AdHawkLocationManager.h
//  adhawk
//
//  Created by Daniel Cloud on 8/2/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AdHawkLocationManager : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *_manager;
}

@property (nonatomic, strong) CLLocation *lastBestLocation;

+ (AdHawkLocationManager *)sharedInstance;
- (void)attemptLocationUpdateOver:(NSTimeInterval)attemptTime;
- (void)stopUpdatingLocation:(NSString *)state;

@end
