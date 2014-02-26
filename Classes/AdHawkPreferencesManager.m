//
//  AdHawkPreferencesManager.m
//  adhawk
//
//  Created by Daniel Cloud on 8/3/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkPreferencesManager.h"

NSString *const kAdHawkLocationEnabled = @"AdHawkLocationEnabled";

@interface AdHawkPreferencesManager ()

@property (nonatomic, weak) NSUserDefaults *userDefaults;

@end

@implementation AdHawkPreferencesManager

@synthesize locationEnabled = _locationEnabled;

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

    return self;
}

- (void)setupPreferences
{
    NSArray *testValue = [self.userDefaults arrayForKey:@"SettingsList"];

    if (testValue == nil) {
        NSDictionary *appDefaults = @{
                                       kAdHawkLocationEnabled: @NO,
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

- (void)updateStoredPreferences
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
