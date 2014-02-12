//
//  AdHawkPreferencesManager.h
//  adhawk
//
//  Created by Daniel Cloud on 8/3/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kAdHawkLocationEnabled;

@interface AdHawkPreferencesManager : NSObject{
    NSUserDefaults *_userDefaults;
}

@property (nonatomic) BOOL locationEnabled;

+ (AdHawkPreferencesManager *)sharedInstance;
- (void)setupPreferences;
- (void)updateStoredPreferences;

@end
