//
//  AdHawkLocationManager.m
//  adhawk
//
//  Created by Daniel Cloud on 8/2/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkLocationManager.h"
#import "AdHawkPreferencesManager.h"

@implementation AdHawkLocationManager

@synthesize lastBestLocation;

+ (AdHawkLocationManager *)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    self.lastBestLocation = [AdHawkPreferencesManager sharedInstance].lastLocation;
    self->_manager = [[CLLocationManager alloc] init];
    self->_manager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self->_manager.distanceFilter = 500;

    return self;
}

- (void)attemptLocationUpdateOver:(NSTimeInterval)attemptTime
{
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    BOOL hasNotDeterminedAuth = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ? YES : NO;
    BOOL locationPrefEnabled = [AdHawkPreferencesManager sharedInstance].locationEnabled;

    if (locationServicesEnabled == YES && (hasNotDeterminedAuth || locationPrefEnabled)) {
        NSLog(@"startUpdatingLocation");
        self->_manager.delegate = self;
        [self->_manager startUpdatingLocation];
    } else {
        NSLog(@"Can't start updating location: location services is %@ and user pref is %@. Auth status is: %@", 
              (locationServicesEnabled ? @"ENABLED" : @"DISABLED"),
              (locationPrefEnabled ? @"ENABLED" : @"DISABLED"),
              (hasNotDeterminedAuth ? @"Not Determined" : @"Determined"));
    }
    [self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:attemptTime];
}

- (void)stopUpdatingLocation:(NSString *)state
{
    NSLog(@"Stop updating location: %@", state);
    [self->_manager stopUpdatingLocation];
    self->_manager.delegate = nil;
}

#pragma mark CLLocationManager delegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    NSLog(@"locationAge is %g", locationAge);
    NSLog(@"newLocation.horizontalAccuracy: %g", newLocation.horizontalAccuracy);
    if (locationAge > 15.0) return;
    if ([newLocation horizontalAccuracy] < 0) return;
    
    if (self.lastBestLocation == nil || [self.lastBestLocation horizontalAccuracy] > [newLocation horizontalAccuracy]) {
        self.lastBestLocation = newLocation;
        [AdHawkPreferencesManager sharedInstance].lastLocation = [self.lastBestLocation copy];
        NSLog(@"Updated location at %@", [NSDateFormatter localizedStringFromDate:self.lastBestLocation.timestamp
                                                                        dateStyle:NSDateFormatterShortStyle
                                                                        timeStyle:NSDateFormatterShortStyle]);
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              self.lastBestLocation.coordinate.latitude,
              self.lastBestLocation.coordinate.longitude);

        if (self.lastBestLocation.horizontalAccuracy <= manager.desiredAccuracy) {
            [self stopUpdatingLocation:@"Acquired Location"];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location update failed: %@", [error localizedDescription]);
    
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [AdHawkPreferencesManager sharedInstance].locationEnabled = (status == kCLAuthorizationStatusAuthorized) ? YES : NO;
}

@end
