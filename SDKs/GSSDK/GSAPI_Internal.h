//
//  GSAPI.h
//	Version: 2.15.3


#import <Foundation/Foundation.h>
#import "SBJSON.h"
#import	"GSSession.h"
#import	"GSResponse.h"
#import	"GSObject.h"
#import	"GSFBConnect.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
#import <Twitter/TWRequest.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Accounts/Accounts.h>
#endif
#define	GSAPI_SDK_VERSION_STRING	@"iOS_2.15.3"

#define GSAPI_NET_SELECT_URL @"gsapi://network_selected/"
#define GSAPI_UI_URL @"http://socialize.gigya.com/gs/mobile/loginui.aspx"
#define GSAPI_RESULT_URL @"gsapi://login_result/"
#define GSAPI_LOGIN_URL_HTTPS @"https://socialize.gigya.com/socialize.login"
#define GSAPI_CONNECT_URL_HTTPS @"https://socialize.gigya.com/socialize.addConnection"
//#define GSAPI_LOGIN_URL_HTTP @"http://socialize.gigya.com/socialize.login"
//#define GSAPI_CONNECT_URL_HTTP @"http://socialize.gigya.com/socialize.addConnection"
#define GSAPI_TITLE_URL @"gsapi://set_title/"

#define GSAPI_PARAM_NAME_PROVIDER	@"provider"
#define GSAPI_PARAM_NAME_PROVIDER_DISPLAY_NAME	@"displayName"
#define GSAPI_PARAM_NAME_CID	@"cid"
#define GSAPI_PARAM_NAME_FORCE_AUTHENTICATION @"forceAuthentication"
#define GSAPI_PARAM_NAME_LANG	@"lang"
#define GSAPI_PARAM_NAME_ERROR_DESCRIPTION	@"error_description"
#define GSAPI_PARAM_NAME_REQUEST_PARAMS_DICTIONARY @"RequestParamsDict"
#define GSAPI_PARAM_NAME_GSRESPONSE @"GSResponse"
#define GSAPI_PARAM_NAME_SEND_REQUEST_METHOD @"SendRequestMethod"
#define GSAPI_PARAM_NAME_CONEXT @"Context"
#define GSAPI_PARAM_NAME_CAPTION_TEXT @"captionText"
#define GSAPI_PARAM_NAME_EXTRA_PERMISSIONS @"extraPermissions"


#define GetUserInfoCompletedAfterLogin_Notification @"GetUserInfoCompletedAfterLogin_Notification"
#define GetUserInfoCompletedAfterConnect_Notification @"GetUserInfoCompletedAfterConnect_Notification"
#define LoginCompleted_Notification @"LoginCompleted_Notification"
#define LogoutCompleted_Notification @"LogoutCompleted_Notification"
#define AddConnectionCompleted_Notification @"AddConnectionCompleted_Notification"
#define RemoveConnectionCompleted_Notification @"RemoveConnectionCompleted_Notification"
#define ShowLoginUICompleted_Notification @"ShowLoginUICompleted_Notification"
#define SendRequestCompleted_Notification @"SendRequestCompleted_Notification"
#define ShowAddConnectionsUICompleted_Notification @"ShowAddConnectionsUICompleted_Notification"
#define ShowAddConnectionsUILoaded_Notification @"ShowAddConnectionsUILoaded_Notification"
#define ShowLoginUILoaded_Notification @"ShowLoginUILoaded_Notification"
#define ShowAddConnectionsUIFailed_Notification @"ShowAddConnectionsUIFailed_Notification"
#define ShowLoginUIFailed_Notification @"ShowLoginUIFailed_Notification"
#define ShowAddConnectionsUIClosed_Notification @"ShowAddConnectionsUIClosed_Notification"
#define ShowLoginUIClosed_Notification @"ShowLoginUIClosed_Notification"
#define Sdk_Config_Received_Notification @"Sdk_Config_Received_Notification"
#define Twitter_Reverse_Token_Received_Notification @"Twitter_Reverse_Token_Received_Notification"
#define Twitter_Login_Completed_Notification @"Twitter_Login_Completed_Notification"


// @protocol GSWebViewControllerDelegate;

@protocol GSWebViewControllerDelegate
- (void)GSWebViewControllerDidFinish:(UIViewController *)controller;
@end

@protocol GSRequestServerTimestampSkewDelegate
-(long) GetServerTimestampSkew;
-(void) SetServerTimestampSkew:(NSString	*)pServerTime;
@end

@protocol GSAPIDelegate
- (void)	onLoginCompleted:(GSObject *)pRequestParams response:(GSResponse *)pResponse context:(id)pContext;
- (void)	onLogoutCompleted:(GSResponse *)pResponse;
- (void)	onAddConnectionCompleted:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext;
- (void)	onRemoveConnectionCompleted:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext;
-	(void)	onShowLoginUICompleted:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext;
-	(void)	onShowLoginUILoaded:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext;
-	(void)	onShowLoginUIFailed:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext;
-	(void)	onShowLoginUIClosed:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext;
-	(void)	onShowAddConnectionsUICompleted:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext;
-	(void)	onShowAddConnectionsUILoaded:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext;
-	(void)	onShowAddConnectionsUIFailed:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext;
-	(void)	onShowAddConnectionsUIClosed:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext;
-	(void)	onSendRequestCompleted:(NSString	*)pMethod Params:(GSObject		*)pParams	response:(GSResponse *)pResponse  context:(id)pContext;
@end



typedef enum 
{
	GSEventType_LOGIN,
	GSEventType_LOGOUT,
	GSEventType_CONNECT,
	GSEventType_DISCONNECT
} GSEventType;

typedef enum
{
	GSWebAction_NavigateToLogin,
	GSWebAction_NavigateToProviderSelector,
	GSWebAction_NavigateToConnect
} GSWebActionType;


enum GSInternalErrorCode
{
	GSErrorCode_MissingAPIKey = 400002,
	GSErrorCode_NonReEntrantCallPending = 400002,
	GSErrorCode_InvalidAPIMethod = 400002
};

@interface GSAPI_Internal : NSObject <GSWebViewControllerDelegate,GSRequestServerTimestampSkewDelegate>{
	
@private
	
	id <GSAPIDelegate> delegate;
	
	NSMutableDictionary	*m_pSettings;
	NSString	*m_pAPIKey;
	UIViewController	*m_pMainViewController;
	GSSession	*m_pSession;
	NSString	*m_pNotificationMessage;
	BOOL	m_bNoReEntrantCallPending;
	GSObject	*m_pSavedRequestParams;
	GSFacebook	*m_pFacebook;
	BOOL	m_bCanceledByUser;
	GSObject	*m_pSDKConfig;
	GSObject	*m_pTwitterReverseToken;
	

}
@property (nonatomic, assign) id <GSAPIDelegate> delegate;
@property (nonatomic, assign) UIViewController *m_pMainViewController;
@property (nonatomic, retain) NSString *m_pAPIKey;
@property (nonatomic, retain) NSMutableDictionary	*m_pSettings;
@property (nonatomic, retain) GSSession	*m_pSession;
@property (nonatomic, retain) NSString	*m_pNotificationMessage;
@property (nonatomic) BOOL	m_bNoReEntrantCallPending;
@property (nonatomic) BOOL	m_bCanceledByUser;
@property (nonatomic, retain) GSObject	*m_pSavedRequestParams;
@property (nonatomic, retain) GSObject	*m_pSDKConfig;
@property (nonatomic, retain) GSObject	*m_pTwitterReverseToken;
@property (nonatomic, retain) GSFacebook	*m_pFacebook;

- (BOOL)handleOpenURL:(NSURL *)url;
-	(void)	setFacebook:(GSFacebook	*)pFacebook;
- (id)initWithAPIKey:(NSString *)APIKey ViewController:(UIViewController *)MainViewController delegate:(id<GSAPIDelegate>)pDelegate;
- (void) OnNotification:(NSNotification *)pNotification;
- (void) Login:(GSObject *)pParams	context:(id)pContext;
-	(void) Logout;
- (void) AddConnection:(GSObject *)pParams	context:(id)pContext;
- (void) RemoveConnection:(GSObject *)pParams	context:(id)pContext;
-	(void) ShowLoginUI:(GSObject *)pParams	context:(id)pContext;
-	(void) ShowAddConnectionsUI:(GSObject *)pParams	context:(id)pContext;
-	(void) SendRequest:(NSString	*)pMethod Params:(GSObject		*)pParams	UseHTTPS:(BOOL)bUseHTTPS	context:(id)pContext	trace:(GSLogger	*)pTrace;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
-	(GSObject	*)	extractTwitterReverseToken;
-	(void) getTwitterReverseToken;
#endif
-	(void) GetUserInfo:(NSString *)pNotificationName	context:(id)pContext originalRequest:(GSObject *)pRequestParams	trace:(GSLogger	*)pTrace;

-(void) LoadSession;
-(void) SaveSession;
-(void) LoadSettings;
-(void) SaveSettings;
-(void) SetSession:(GSSession *)pSession;
-(NSString	*) GetLastLoginProvider;
-(void) SetLastLoginProvider:(NSString	*)pProvider;

-(long) GetServerTimestampSkew;
-(void) SetServerTimestampSkew:(NSString	*)pServerTime;

-	(void)	startWebViewControll:(GSObject	*)pParams	eventType:(GSEventType )eventType	actionType:(GSWebActionType)	actionType	context:(id)pContext;

-	(void)	SendNotification:(NSString *)pMessage APIMethod:(NSString *)pMethod request:(GSObject		*)pRequestParams response:(GSResponse *)pResponse context:(id)pContext;
-	(void)	SendNotification:(NSString *)pMethod request:(GSObject		*)pRequestParams response:(GSResponse *)pResponse context:(id)pContext;

-	(NSString	*) GetAccessToken;
-	(NSString	*) GetSecretKey;
-(GSSession *) GetSession;

@end
