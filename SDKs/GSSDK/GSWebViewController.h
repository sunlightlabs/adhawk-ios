//
//  ProviderSelectorViewController.h
//	Version: 2.15.3


#import <UIKit/UIKit.h>
#import "GSAPI_Internal.h"


@interface GSWebViewController : UIViewController <UIWebViewDelegate,UINavigationControllerDelegate,GSFBSessionDelegate>{
//@interface GSWebViewController : UIViewController <UIWebViewDelegate,GSWebViewControllerDelegate>{

	id <GSWebViewControllerDelegate> delegate;
	UIWebView	*m_pWebView;
	GSEventType m_EventType;
	GSWebActionType	m_ActionType;
	GSAPI_Internal	*m_pGSAPI;
	GSObject	*m_pRequestParams;
	GSResponse	*m_pResponse;
	id	m_pSavedContext;
	NSString	*m_pNotificationMessage;
	BOOL	m_bFirstAppearance;
	GSLogger	*m_pTrace;
	NSArray	*m_pFacebookPermissions;
	GSFacebook	*m_pFacebook;
	BOOL	m_bFacebookLoginCompleted;
	UIActivityIndicatorView *m_pSpinner;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
	BOOL	m_bTwitterLoginCompleted;
	BOOL	m_bLoggedInToTwitter;
	ACAccountStore	*m_pAccountStore;
	GSObject	*m_pTwitterCredentials;
#endif
}
@property (nonatomic, retain) IBOutlet UIWebView	*m_pWebView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*m_pSpinner;
@property (nonatomic) GSEventType	m_EventType;
@property (nonatomic) GSWebActionType	m_ActionType;
@property (nonatomic, assign) id <GSWebViewControllerDelegate> delegate;
@property (nonatomic, retain) GSObject	*m_pRequestParams;
@property (nonatomic, retain) GSAPI_Internal	*m_pGSAPI;
@property (nonatomic, retain) GSResponse	*m_pResponse;
@property (nonatomic, retain) id	m_pSavedContext;
@property (nonatomic, retain) NSString	*m_pNotificationMessage;
@property (nonatomic, retain) GSLogger	*m_pTrace;
@property (nonatomic, retain) NSArray	*m_pFacebookPermissions;
@property (nonatomic, retain) GSFacebook	*m_pFacebook;
@property (nonatomic)	BOOL	m_bFirstAppearance;
@property (nonatomic)	BOOL	m_bFacebookLoginCompleted;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
@property (nonatomic)	BOOL	m_bTwitterLoginCompleted;
@property (nonatomic)	BOOL	m_bLoggedInToTwitter;
@property (nonatomic, retain) ACAccountStore	*m_pAccountStore;
@property (nonatomic, retain) GSObject	*m_pTwitterCredentials;
#endif
-(void) NavigateToProviderSelector;
-(void) NavigateToLogin;
-(void) NavigateToConnect;
-	(void) OnResult:(GSObject *)pResponse;
-	(NSString	*)GetProvider;
-	(NSString	*)GetProviderDisplayName;
-	(NSString	*)GetCID;
-	(NSString	*)getForceAuthentication;
-	(NSString	*)GetLang;
-	(NSString	*)GetExtraPermissions;

-(IBAction)	OnCancel:(id)Sender;
-(IBAction)	OnBack:(id)Sender;
-(BOOL)	facebookLoginActivated:(NSString	*)pProvider;
-(BOOL)	twitterLoginActivated:(NSString	*)pProvider;
- (void) onApplicationBecomeActive:(NSNotification *)pNotification;

@end

