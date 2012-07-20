/*
 * Copyright 2010 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "GSFBLoginDialog.h"
#import "GSFBRequest.h"

@protocol GSFBSessionDelegate;

/**
 * Main Facebook interface for interacting with the Facebook developer API.
 * Provides methods to log in and log out a user, make requests using the REST
 * and Graph APIs, and start user interface interactions (such as
 * pop-ups promoting for credentials, permissions, stream posts, etc.)
 */
@interface GSFacebook : NSObject<GSFBLoginDialogDelegate>{
  NSString* _accessToken;
  NSDate* _expirationDate;
  id<GSFBSessionDelegate> _sessionDelegate;
  GSFBRequest* _request;
  GSFBDialog* _loginDialog;
  GSFBDialog* _fbDialog;
  NSString* _appId;
  NSArray* _permissions;
	NSString	*m_pLocalAppID;
}

@property(nonatomic, retain) NSString	*m_pLocalAppID;

@property(nonatomic, copy) NSString* accessToken;

@property(nonatomic, copy) NSDate* expirationDate;

@property(nonatomic, assign) id<GSFBSessionDelegate> sessionDelegate;

- (BOOL)authorize:(NSString *)application_id
      permissions:(NSArray *)permissions
         delegate:(id<GSFBSessionDelegate>)delegate
safariAuth:(BOOL)bSafariAuth
			 localAppID: pLocalAppID;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)logout:(id<GSFBSessionDelegate>)delegate;

- (void)requestWithParams:(NSMutableDictionary *)params
              andDelegate:(id <GSFBRequestDelegate>)delegate;

- (void)requestWithMethodName:(NSString *)methodName
                    andParams:(NSMutableDictionary *)params
                andHttpMethod:(NSString *)httpMethod
                  andDelegate:(id <GSFBRequestDelegate>)delegate;

- (void)requestWithGraphPath:(NSString *)graphPath
                 andDelegate:(id <GSFBRequestDelegate>)delegate;

- (void)requestWithGraphPath:(NSString *)graphPath
                   andParams:(NSMutableDictionary *)params
                 andDelegate:(id <GSFBRequestDelegate>)delegate;

- (void)requestWithGraphPath:(NSString *)graphPath
                   andParams:(NSMutableDictionary *)params
               andHttpMethod:(NSString *)httpMethod
                 andDelegate:(id <GSFBRequestDelegate>)delegate;

- (void)dialog:(NSString *)action
   andDelegate:(id<GSFBDialogDelegate>)delegate;

- (void)dialog:(NSString *)action
     andParams:(NSMutableDictionary *)params
   andDelegate:(id <GSFBDialogDelegate>)delegate;

- (BOOL)isSessionValid;

@end

////////////////////////////////////////////////////////////////////////////////

/**
 * Your application should implement this delegate to receive session callbacks.
 */
@protocol GSFBSessionDelegate <NSObject>

@optional

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin;

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled;

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout;

@end
