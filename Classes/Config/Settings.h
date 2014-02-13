//
//  Settings.h
//  adhawk
//
//  Created by Daniel Cloud on 7/10/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//


/*
#ifdef TESTING
    #define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif
*/

FOUNDATION_EXPORT NSString *const kTestFlightAppToken;

FOUNDATION_EXPORT NSString *const kAdHawkBaseURL;

FOUNDATION_EXPORT NSString *const kClientAppHeader;

FOUNDATION_EXPORT NSString *const kAdHawkUserAgent;

FOUNDATION_EXPORT NSString *const kCrashlyticsApiKey;

#pragma mark - Test related

FOUNDATION_EXPORT NSString *const kAdHawkAboutURL;

FOUNDATION_EXPORT NSString *const kAdHawkBrowseURL;

FOUNDATION_EXPORT NSString *const kAdHawkTroubleshootingURL;

FOUNDATION_EXPORT NSString *const kAdHawkFacebookAppId;

FOUNDATION_EXPORT NSString *const kAdHawkTestFingerprint;

// 15.0 is optimal for kAdHawkRecordDuration NSTimeInterval
FOUNDATION_EXPORT NSTimeInterval const kAdHawkRecordDuration;