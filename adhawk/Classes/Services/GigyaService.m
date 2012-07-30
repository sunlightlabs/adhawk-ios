//
//  GigyaService.m
//  adhawk
//
//  Created by Daniel Cloud on 7/20/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "GigyaService.h"
#import "GSAPI.h"
#import "Settings.h"

#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


GSAPI *getAPIObject(void)
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[GSAPI alloc] initWithAPIKey:GIGYA_API_KEY viewController:nil];
    })
}

GSObject *getParamsObject(void)
{
    GSObject *pParams = [[GSObject new] autorelease];
    [pParams putStringValue:@"twitter,facebook" forKey:@"enabledProviders"];
    [pParams putStringValue:FACEBOOOK_APP_ID forKey:@"facebookAppid"];
    return pParams;
}

@implementation GigyaService

@synthesize api = _api;
@synthesize params = _params;

+ (GigyaService *) sharedInstanceWithViewController:(UIViewController *)mainViewController
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] initWithViewController:mainViewController];
    })
}

- (id) init {
    [super init];
    
    _api = getAPIObject();
    _params = getParamsObject();
    
    return self;
}

- (id) initWithViewController:(UIViewController *)mainViewController {
    self = [super init];
    
    if(self)
    {
        _api = [[GSAPI alloc] initWithAPIKey:GIGYA_API_KEY viewController:mainViewController];
        _params = getParamsObject();
    }
    
    return self;
}

- (void) showLoginUI
{
    [self.api showLoginUI:[self params] delegate:self context:nil];
}

- (void) showAddConnectionsUI
{
    [self.api showAddConnectionsUI:[self params] delegate:self context:nil];
}

#pragma mark - UIActionSheetDelegate callbacks

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Share Action Click");
    NSString *clickedButtonLabel = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"Share button clicked: %@", clickedButtonLabel);
//    [TestFlight passCheckpoint:logMessage];
    GSObject *pParams = [[GSObject new] autorelease];
    [pParams putStringValue:@"I found out something on Ad Hawk!" forKey:@"status"];
    [pParams putStringValue:@"AdHawk iOS" forKey:@"cid"];

    if (buttonIndex == 0) {
        [TestFlight passCheckpoint:@"Share 'Twitter' clicked"];
        [pParams putStringValue:@"twitter" forKey:@"enabledProviders"];
        // If the user allows tweets to have locations associated...
//        [pParams putGSObjectValue:[GSObject objectWithJSONString:@"{lat:0, lon:0}"] forKey:@"userLocation"];
    }
    else if (buttonIndex == 1) {
        [TestFlight passCheckpoint:@"Share 'Facebook' clicked"];
        [pParams putStringValue:@"twitter" forKey:@"enabledProviders"];
    }
    [self.api sendRequest:@"socialize.setStatus" params:pParams delegate:self context:nil];

}

#pragma mark - GSAddConnectionsUIDelegate callbacks

// Fired when add connection operation (and getUserInfo that follows it) completes.    
- (void) gsAddConnectionsUIDidConnect:(NSString*)provider user:(GSObject*)user context:(id)context
{}

// Fired when an error occurrs, either from webView or as result of the connect process.
- (void) gsAddConnectionsUIDidFail:(int)errorCode errorMessage:(NSString*)errorMessage context:(id)context
{}

// Fired when the Add Connections UI is shown.
- (void) gsAddConnectionsUIDidLoad:(id)context
{}

// Fired when the Add Connections UI is closed (for any reason - canceled, error , operation completed OK).
- (void) gsAddConnectionsUIDidClose:(id)context
{}


#pragma mark - GSLoginUIDelegate callbacks

// Fired when login operation (and getUserInfo that follows it) complete.
-(void) gsLoginUIDidLogin:(NSString*)provider user:(GSObject*)user context:(id)context
{
    NSLog(@"gsLoginUIDidLogin");
}

// Fired when error occurred, either from webView or as result of login process, or get user info that followed it.
-(void) gsLoginUIDidFail:(int)errorCode errorMessage:(NSString*)errorMessage context:(id)context
{
    NSLog(@"gsLoginUIDidFail: %@", errorMessage);
}

// Fired when network selection page is shown.
-(void) gsLoginUIDidLoad:(id)context
{
    NSLog(@"gsLoginUIDidLoad");
}

// Fired when the login UI is closed (for any reason - canceled, error, operation completed OK). 
-(void) gsLoginUIDidClose:(id)context
{
    NSLog(@"gsLoginUIDidClose");
}


#pragma mark - GSResponseDelegate callbacks

// This method should handle the response.
- (void) gsDidReceiveResponse:(NSString*)method response:(GSResponse*)response context:(id)context
{
    NSLog(@"response: \n%@", [response ResponseText]);
}

#pragma mark - GSEventDelegate callbacks

// Fired whenever a user successfully logs in to Gigya.
-(void) gsDidLogin:(NSString*)provider user:(GSObject*)user context:(id)context
{}

// Fired whenever a user logs out from Gigya.
-(void) gsDidLogout
{}

// Fired whenever a user is connected to a provider
-(void) gsDidAddConnection:(NSString*)provider user:(GSObject*)user context:(id)context	
{}

// Fired whenever a user is disconnected from a provider.
-(void) gsDidRemoveConnection:(NSString*)provider context:(id)context
{}

#pragma mark - UIApplicationDelegate callbacks

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// This function will be called in future releases of iOS, but existing applications do not call it, and specifically - Facebook
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"GigyaService openURL sourceApplication");
    if(self.api != nil)
        return [self.api handleOpenURL:url];
    return NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// This function will be deprecated in the future, but the current version of Facebook calls this function
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"GigyaService handleOpenURL");
    if(self.api != nil)
        return [self.api handleOpenURL:url];
    return NO;
}

@end
