//
//  AdHawkPreferencesManager.m
//  adhawk
//
//  Created by Daniel Cloud on 8/3/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AdHawkPreferencesManager.h"

NSString * const kAdHawkLocationEnabled = @"AdHawkLocationEnabled";
NSString * const kAdHawkTwitterAccountEnabled = @"AdHawkTwitterAccountEnabled";
NSString * const kAdHawkFacebookAccountEnabled = @"AdHawkFacebookAccountEnabled";

@implementation AdHawkPreferencesManager

@synthesize locationEnabled, facebookAccountEnabled, twitterAccountEnabled;

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
        NSArray *settingsList = [NSArray arrayWithObjects:kAdHawkLocationEnabled, kAdHawkTwitterAccountEnabled, kAdHawkFacebookAccountEnabled, nil];
        NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
                                     settingsList, @"SettingsList",
                                     [NSNumber numberWithBool:NO], kAdHawkLocationEnabled,
                                     [NSNumber numberWithBool:NO], kAdHawkTwitterAccountEnabled,
                                     [NSNumber numberWithBool:NO], kAdHawkFacebookAccountEnabled, nil];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    locationEnabled = [self->_userDefaults boolForKey:kAdHawkLocationEnabled];
    twitterAccountEnabled = [self->_userDefaults boolForKey:kAdHawkTwitterAccountEnabled];
    facebookAccountEnabled = [self->_userDefaults boolForKey:kAdHawkFacebookAccountEnabled];
}

- (void) setLocationEnabled:(BOOL)isOn
{
    locationEnabled = isOn;
    [self->_userDefaults setBool:isOn forKey:kAdHawkLocationEnabled];
}

- (void) setTwitterAccountEnabled:(BOOL)isOn
{
    twitterAccountEnabled = isOn;
    [self->_userDefaults setBool:isOn forKey:kAdHawkTwitterAccountEnabled];
}

- (void) setFacebookAccountEnabled:(BOOL)isOn
{
    facebookAccountEnabled = isOn;
    [self->_userDefaults setBool:isOn forKey:kAdHawkFacebookAccountEnabled];
}

- (void) updateStoredPreferences
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
