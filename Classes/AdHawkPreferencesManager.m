//
//  AdHawkPreferencesManager.m
//  adhawk
//
//  Created by Daniel Cloud on 8/3/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkPreferencesManager.h"

NSString * const kAdHawkLocationEnabled = @"AdHawkLocationEnabled";

@implementation AdHawkPreferencesManager

@synthesize locationEnabled;

+ (AdHawkPreferencesManager *) sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id) init
{
    self = [super init];
    self->_userDefaults = [NSUserDefaults standardUserDefaults];
    return self;
}

// NSUserDefaultsDidChangeNotification

- (void) setupPreferences
{
    NSArray *testValue = [self->_userDefaults arrayForKey:@"SettingsList"];
    if (testValue == nil) {
        NSArray *settingsList = [NSArray arrayWithObjects:kAdHawkLocationEnabled, nil];
        NSDictionary *appDefaults = @{ @"SettingsList" : settingsList,
                                       kAdHawkLocationEnabled: [NSNumber numberWithBool:NO]
                                       };

        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    locationEnabled = [self->_userDefaults boolForKey:kAdHawkLocationEnabled];
}

- (void) setLocationEnabled:(BOOL)isOn
{
    locationEnabled = isOn;
    [self->_userDefaults setBool:isOn forKey:kAdHawkLocationEnabled];
}

- (void) updateStoredPreferences
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
