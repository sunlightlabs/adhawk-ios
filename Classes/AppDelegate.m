//
//  AppDelegate.m
//  adhawk
//
//  Created by James Snavely on 3/3/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import "AdHawkPreferencesManager.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation AppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    dispatch_async(dispatch_get_main_queue(), ^{
        [[AdHawkPreferencesManager sharedInstance] setupPreferences];
    });

    [self setupStyle];

#if CONFIGURATION_Beta
    #define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__)
    [TestFlight takeOff:TESTFLIGHT_APP_TOKEN];
    NSLog(@"Running in Beta configuration");
#endif

#if CONFIGURATION_Release
    #define NSLog(...)
#endif

#if CONFIGURATION_Debug
    NSLog(@"Running in Debug configuration");
#endif

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

//    Set up views
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]
                                      instantiateViewControllerWithIdentifier:@"AppNavigationController"];


    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AdHawkPreferencesManager sharedInstance] updateStoredPreferences];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AdHawkPreferencesManager sharedInstance] updateStoredPreferences];
}

- (void)setupStyle
{
    UIApplication *app = [UIApplication sharedApplication];
    app.statusBarStyle = UIStatusBarStyleLightContent;

    UIColor *lightGreyColor = [UIColor colorWithRed:218 green:218 blue:218 alpha:1.0f];
    UIColor *darkColor = [UIColor colorWithWhite:0.100 alpha:1.000];

    self.window.tintColor = lightGreyColor;
    self.window.backgroundColor = darkColor;

//    Toolbar appearance
    UIToolbar *toolBar = [UIToolbar appearance];
    toolBar.barTintColor = darkColor;

//    UINavigationBar appearance
    UINavigationBar *navbar = [UINavigationBar appearance];
    navbar.barTintColor = darkColor;

//    UISwitch appearance
    UISwitch *uiswitch = [UISwitch appearance];
    uiswitch.tintColor = lightGreyColor;

    UIWebView *webview = [UIWebView appearance];
    webview.backgroundColor = lightGreyColor;

}

@end
