//
//  AdHawkPreferencesManager.m
//  adhawk
//
//  Created by Daniel Cloud on 8/3/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkPreferencesManager.h"

NSString *const kAdHawkLocationEnabled = @"AdHawkLocationEnabled";
NSString *const kAdHawkLastLocationLatitude = @"kAdHawkLastLocationLatitude";
NSString *const kAdHawkLastLocationLongitude = @"kAdHawkLastLocationLongitude";
NSString *const kAdHawkLastLocationTimestamp = @"kAdHawkLastLocationTimestamp";

@interface AdHawkPreferencesManager ()

@property (nonatomic, weak) NSUserDefaults *userDefaults;

@end

@implementation AdHawkPreferencesManager

@synthesize locationEnabled = _locationEnabled;
@synthesize lastLocation = _lastLocation;

@synthesize userDefaults;

+ (AdHawkPreferencesManager *)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    _locationEnabled = [self.userDefaults boolForKey:kAdHawkLocationEnabled];
    CLLocationDegrees lat = [self.userDefaults doubleForKey:kAdHawkLastLocationLatitude];
    CLLocationDegrees lon = [self.userDefaults doubleForKey:kAdHawkLastLocationLongitude];
    NSDate *timestamp = [self.userDefaults objectForKey:kAdHawkLastLocationTimestamp];
    _lastLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon)
                                                  altitude:0
                                        horizontalAccuracy:kCLLocationAccuracyKilometer
                                          verticalAccuracy:kCLLocationAccuracyKilometer
                                                 timestamp:timestamp];

    return self;
}

- (void)setupPreferences
{
    NSArray *testValue = [self.userDefaults arrayForKey:@"SettingsList"];

    if (testValue == nil) {
        NSDictionary *appDefaults = @{
                                       kAdHawkLocationEnabled: @NO,
                                       kAdHawkLastLocationLatitude: @NO,
                                       kAdHawkLastLocationLongitude: @NO,
                                       kAdHawkLastLocationTimestamp: @NO,
                                       };

        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setLocationEnabled:(BOOL)isOn
{
    _locationEnabled = isOn;
    [self.userDefaults setBool:_locationEnabled forKey:kAdHawkLocationEnabled];
}

- (void)setLastLocation:(CLLocation *)lastLocation
{
    _lastLocation = lastLocation;
    [self.userDefaults setDouble:_lastLocation.coordinate.latitude forKey:kAdHawkLastLocationLatitude];
    [self.userDefaults setDouble:_lastLocation.coordinate.longitude forKey:kAdHawkLastLocationLongitude];
    [self.userDefaults setObject:_lastLocation.timestamp forKey:kAdHawkLastLocationTimestamp];
}

- (void)updateStoredPreferences
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
