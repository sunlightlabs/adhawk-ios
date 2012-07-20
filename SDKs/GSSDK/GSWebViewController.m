//
//  ProviderSelectorViewController.m
//	Version: 2.15.3


#import "GSWebViewController.h"
#import	"GSRequest.h"
//#define	GIGYA_FACEBOOK_APP_ID	@"132998436752669"
#define GIGYA_FACEBOOK_BASIC_PERMISSIONS	@""
#define FACEBOOK_PROVIDER_NAME	@"facebook"
#define FACEBOOK_APP_ID	@"facebookAppId"
#define FACEBOOK_EXTRA_PERMISSIONS @"facebookExtraPermissions"

#define TWITTER_PROVIDER_NAME	@"twitter"

@implementation GSWebViewController
@synthesize	m_pWebView;
@synthesize	m_EventType;
@synthesize	m_pRequestParams;
@synthesize delegate;
@synthesize	m_pGSAPI;
@synthesize	m_ActionType;
@synthesize	m_pResponse;
@synthesize	m_pSavedContext;
@synthesize	m_pNotificationMessage;
@synthesize	m_bFirstAppearance;
@synthesize	m_pTrace;
@synthesize	m_pFacebook;
@synthesize	m_pFacebookPermissions;
@synthesize	m_bFacebookLoginCompleted;
@synthesize	m_pSpinner;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
@synthesize m_bLoggedInToTwitter;
@synthesize m_pAccountStore;
@synthesize m_pTwitterCredentials;
@synthesize m_bTwitterLoginCompleted;
#endif
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	
	
	UIBarButtonItem *pCancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(OnCancel:)];
	self.navigationItem.rightBarButtonItem = pCancelButtonItem;
	[pCancelButtonItem release];
	
	UIBarButtonItem *pBackButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(OnBack:)];
	self.navigationItem.backBarButtonItem = pBackButtonItem;
	[pBackButtonItem release];
	self.m_bFirstAppearance	=	YES;
	if(self.m_pTrace	==	nil)
		self.m_pTrace	=	[[[GSLogger	alloc]	init]	autorelease];
	[self.m_pTrace addKey:@"WebViewRequest" value:[NSString stringWithFormat:@"EventType=%d,ActionType=%d,Params=%@",self.m_EventType,self.m_ActionType,[self.m_pRequestParams stringValue]]];
	
	UIActivityIndicatorView	*pSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	pSpinner.center = self.view.center;
	pSpinner.hidesWhenStopped = YES;
	[self.view addSubview:pSpinner];
	self.m_pSpinner	=	pSpinner;
	[pSpinner	release];
	
	
}

-(IBAction)	OnBack:(id)Sender
{
	[self.navigationController popViewControllerAnimated:YES];
}


- (void) viewDidAppear:(BOOL)animated
{
	
	
	if(self.m_bFirstAppearance)
	{
		if(self.m_ActionType	==	GSWebAction_NavigateToLogin)
			[self NavigateToLogin];
		else if(self.m_ActionType	==	GSWebAction_NavigateToProviderSelector)
			[self NavigateToProviderSelector];
		else if(self.m_ActionType	==	GSWebAction_NavigateToConnect)
			[self NavigateToConnect];
	}
	self.m_bFirstAppearance	=	NO;
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	// return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return	YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.m_pWebView	=	nil;
	self.m_pSpinner	=	nil;
}


- (void)dealloc {
	NSNotification *pNotification;
	if(self.m_ActionType == GSWebAction_NavigateToProviderSelector)
	{
		NSMutableDictionary	*pDict = [[[NSMutableDictionary alloc] init] autorelease];
		[pDict	setObject:self.m_pSavedContext forKey:GSAPI_PARAM_NAME_CONEXT];
		
		if(self.m_EventType	==	GSEventType_CONNECT)
		{
			pNotification = [NSNotification notificationWithName:ShowAddConnectionsUIClosed_Notification object:nil userInfo:pDict];
		}	else {
			pNotification = [NSNotification notificationWithName:ShowLoginUIClosed_Notification object:nil userInfo:pDict];
		}
		[[NSNotificationQueue defaultQueue] enqueueNotification:pNotification postingStyle:NSPostWhenIdle];
	}
	
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.m_pWebView	=	nil;
	self.m_pRequestParams	=	nil;
	if(self.m_pFacebook)
	{
		[self.m_pGSAPI setFacebook:nil];
		self.m_pFacebook	=	nil;
		self.m_pFacebookPermissions	=	nil;
	}
	self.m_pGSAPI	=	nil;
	self.m_pResponse	=	nil;
	self.m_pSavedContext	=	nil;
	self.m_pNotificationMessage	=	nil;
	self.m_pTrace	=	nil;
	self.m_pSpinner = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
	self.m_pAccountStore	=	nil;
	self.m_pTwitterCredentials	=	nil;
#endif
	[super dealloc];
}

-	(NSString	*)GetProvider
{
	if(self.m_pRequestParams	==	nil)
	{
		return nil;
	}
	return [self.m_pRequestParams	getString:GSAPI_PARAM_NAME_PROVIDER];
}
-	(NSString	*)GetProviderDisplayName
{
	if(self.m_pRequestParams	==	nil)
	{
		return nil;
	}
	NSString *pDisplayName	=	[self.m_pRequestParams	getString:GSAPI_PARAM_NAME_PROVIDER_DISPLAY_NAME];
	if(pDisplayName	!=	nil)
		return pDisplayName;
	return [self GetProvider];
}

-	(NSString	*)GetCID
{
	if(self.m_pRequestParams	==	nil)
	{
		return nil;
	}
	return [self.m_pRequestParams	getString:GSAPI_PARAM_NAME_CID];
}

-	(NSString	*)getForceAuthentication
{
	if(self.m_pRequestParams	==	nil)
	{
		return nil;
	}
	return [self.m_pRequestParams	getString:GSAPI_PARAM_NAME_FORCE_AUTHENTICATION];
}

-	(NSString	*)GetLang
{
	if(self.m_pRequestParams	==	nil)
	{
		return nil;
	}
	return [self.m_pRequestParams	getString:GSAPI_PARAM_NAME_LANG];
}

-	(NSString	*)GetExtraPermissions
{
	if(self.m_pRequestParams	==	nil)
		return nil;
	
	NSString* provider = [self GetProvider];
	
	if (provider==nil)
		return nil;
	NSString* xpermKey =  [provider stringByAppendingString:@"ExtraPermissions"];
	return [self.m_pRequestParams	getString:xpermKey];
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
-	(void)	onTwitterLoginCompleted:(NSNotification	*)pNotification
{
	if(!self.m_bLoggedInToTwitter)
	{
		[self.delegate GSWebViewControllerDidFinish:self];
	}
	else
	{
		if(self.m_EventType	==	GSEventType_CONNECT)
		{
			[self NavigateToConnect];
		}	else {
			[self NavigateToLogin];
		}
		
	}
}

-	(void)	onTwitterReverseTokenReceived:(NSNotification	*)pNotification
{
	
	GSObject	*pToken = [self.m_pGSAPI extractTwitterReverseToken];
	[self.m_pSpinner stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
	
	if(pToken		==	nil)
	{
		
		
		[self.m_pTrace addKey:@"Error from server"	value:@"did not receive twitter reverse token"] ;
		
		
		GSResponse	*pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_HTTPFailure ErrorMessage:@"did not receive twitter reverse token" format:[self.m_pRequestParams getString:@"format" defaultValue:@"json"] method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login" trace:self.m_pTrace] autorelease];
		
		
		NSMutableDictionary	*pDict = [[[NSMutableDictionary alloc] init] autorelease];
		[pDict	setObject:pResponse forKey:GSAPI_PARAM_NAME_GSRESPONSE];
		[pDict	setObject:self.m_pSavedContext forKey:GSAPI_PARAM_NAME_CONEXT];
		
		NSNotification *pNotification;
		if(self.m_EventType	==	GSEventType_CONNECT)
		{
			pNotification = [NSNotification notificationWithName:ShowAddConnectionsUIFailed_Notification object:nil userInfo:pDict];
		}	else {
			pNotification = [NSNotification notificationWithName:ShowLoginUIFailed_Notification object:nil userInfo:pDict];
		}
		
		[[NSNotificationQueue defaultQueue] enqueueNotification:pNotification postingStyle:NSPostWhenIdle];
		self.m_pResponse	=	nil;
		[self.delegate GSWebViewControllerDidFinish:self];
	}	else
	{
		
		
		NSDictionary *requestParams = [[[NSMutableDictionary alloc] init] autorelease];
		[requestParams setValue:[pToken getString:@"oauth_consumer_key"] forKey:@"x_reverse_auth_target"];
		[requestParams setValue:[pToken getString:@"OAuth"] forKey:@"x_reverse_auth_parameters"];            
		
		NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
		TWRequest *pTWRequest = [[TWRequest alloc] initWithURL:requestURL parameters:requestParams requestMethod:TWRequestMethodPOST];
		
		
		
		//  Next, create an instance of the account store  
		self.m_pAccountStore = [[[ACAccountStore alloc] init]	autorelease];
		
		//  Obtain the Twitter account type from the store
		ACAccountType *pAccountType = [self.m_pAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
		
		
		
		[self.m_pAccountStore requestAccessToAccountsWithType:pAccountType
																		withCompletionHandler:^(BOOL granted, NSError *error) {
																			if (!granted) {
#ifdef _DEBUG
																				NSLog(@"twitter access not granted:\n%@", error);
#endif
																				[self.m_pTrace addKey:@"Error from Account Store"	value:[error localizedDescription]] ;
																				
																				self.m_bTwitterLoginCompleted	=	true;
																				self.m_bLoggedInToTwitter	=	false;
																				self.m_pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_CanceledByUser format:@"json" method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login"trace:self.m_pTrace]	autorelease];
																				NSNotification *pNotification = [NSNotification notificationWithName:Twitter_Login_Completed_Notification object:nil userInfo:nil];
																				//[[NSNotificationQueue defaultQueue] enqueueNotification:pNotification postingStyle:NSPostWhenIdle];
																				[self performSelectorOnMainThread:@selector(onTwitterLoginCompleted:) withObject:pNotification waitUntilDone:NO];

																			} else {
																				// obtain all the local account instances
																				NSArray *pAccounts = [self.m_pAccountStore accountsWithAccountType:pAccountType];
																				
																				// for simplicity, we will choose the first account returned - in your app,
																				// you should ensure that the user chooses the correct Twitter account
																				// to use with your application.  DO NOT FORGET THIS STEP.
																				[pTWRequest setAccount:[pAccounts objectAtIndex:0]];
																				
																				// execute the request
																				[pTWRequest performRequestWithHandler:
																				 ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
																					 if(error != nil)
																					 {
#ifdef _DEBUG
																						 NSLog(@"twitter request failed:\n%@", error);
#endif
																						 
																						 [self.m_pTrace addKey:@"Error from TWRequest"	value:[error localizedDescription]] ;
																						 
																						 self.m_bTwitterLoginCompleted	=	true;
																						 self.m_bLoggedInToTwitter	=	false;
																						 self.m_pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_CanceledByUser format:@"json" method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login"trace:self.m_pTrace]	autorelease];
																					 }	else{
																						 NSString *responseStr = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]	autorelease];
																						 // see below for an example response
#ifdef _DEBUG
																						 NSLog(@"The user's info for your server:\n%@", responseStr);
#endif
																						 self.m_pTwitterCredentials	=	[[[GSObject alloc]	init]autorelease];
																						 [self.m_pTwitterCredentials	parseQueryString:responseStr];
																						 if([[self.m_pTwitterCredentials getString:@"oauth_token" defaultValue:@""] length]	>	0	&&	[[self.m_pTwitterCredentials getString:@"oauth_token_secret" defaultValue:@""] length]	>	0)
																						 {
																							 self.m_bLoggedInToTwitter	=	YES;
																							 self.m_bTwitterLoginCompleted	=	YES;
 																						 }
																					 }
																					 NSNotification *pNotification = [NSNotification notificationWithName:Twitter_Login_Completed_Notification object:nil userInfo:nil];
																				//	 [[NSNotificationQueue defaultQueue] enqueueNotification:pNotification postingStyle:NSPostWhenIdle];
																					 [self performSelectorOnMainThread:@selector(onTwitterLoginCompleted:) withObject:pNotification waitUntilDone:NO];

																					 
																				 }];
																			} 
																		}];
		
		
		
	}
}

-(BOOL)	twitterLoginActivated:(NSString	*)pProvider
{
	if([pProvider	compare:TWITTER_PROVIDER_NAME] != NSOrderedSame)
		return	NO;
	if(![TWTweetComposeViewController canSendTweet])
		return NO;
	if(self.m_bLoggedInToTwitter)
		return NO;
	
	self.m_pSpinner.center = self.view.center;
	[self.m_pSpinner startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTwitterReverseTokenReceived:) name:Twitter_Reverse_Token_Received_Notification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTwitterLoginCompleted:) name:Twitter_Login_Completed_Notification object:nil];
	self.m_pGSAPI.m_pTwitterReverseToken	=	nil;
	[NSThread detachNewThreadSelector:@selector(getTwitterReverseToken) toTarget:self.m_pGSAPI withObject:nil];
	//	[self.m_pGSAPI	getTwitterReverseToken];
	//	[self onTwitterReverseTokenReceived:nil];
	return YES;
}
#else
-(BOOL)	twitterLoginActivated:(NSString	*)pProvider
{
	return	NO;
}
#endif

-(BOOL)	facebookLoginActivated:(NSString	*)pProvider
{
	if(self.m_pFacebook	!=	nil	&&	self.m_pFacebook.accessToken	!=	nil)
		return	NO;
	/*
	 if(![[UIApplication sharedApplication].delegate respondsToSelector:@selector(setFacebook:)])
	 return	NO;
	 */
	if([pProvider	compare:FACEBOOK_PROVIDER_NAME] != NSOrderedSame)
		return	NO;
	if([[self.m_pRequestParams getString:FACEBOOK_APP_ID defaultValue:@""] compare:@""]	==	NSOrderedSame)
		return	NO;
	
	self.m_pFacebookPermissions		=	[GIGYA_FACEBOOK_BASIC_PERMISSIONS componentsSeparatedByString:@","];
	if([[self.m_pRequestParams getString:FACEBOOK_EXTRA_PERMISSIONS defaultValue:@""] compare:@""]	!= NSOrderedSame)
	{
		self.m_pFacebookPermissions =	[self.m_pFacebookPermissions arrayByAddingObjectsFromArray:[[self.m_pRequestParams getString:FACEBOOK_EXTRA_PERMISSIONS] componentsSeparatedByString:@","]];
	}
	GSFacebook	*pFacebook	=	[[GSFacebook	alloc]	init];
	self.m_pFacebook	=	pFacebook;
	[pFacebook	release];
	[self.m_pGSAPI setFacebook:self.m_pFacebook];
	BOOL	bWithSafari = ([[self.m_pRequestParams getString:@"facebookSSOFallback" defaultValue:@"webview"]	compare:@"safari"]	==	NSOrderedSame);
	NSString *pLocalAppId = [self.m_pRequestParams getString:@"facebookLocalAppId" defaultValue:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	return [self.m_pFacebook	authorize:[self.m_pRequestParams getString:FACEBOOK_APP_ID] permissions:self.m_pFacebookPermissions delegate:self	safariAuth:bWithSafari localAppID:pLocalAppId];
}

-(void) NavigateToLogin
{
	if(self.m_ActionType != GSWebAction_NavigateToLogin)
	{
		GSWebViewController *pController = [[GSWebViewController alloc] initWithNibName:@"GSWebViewController" bundle:nil];
		pController.delegate = self.delegate;
		pController.m_pTrace	=	[self.m_pTrace	clone];
		pController.m_pRequestParams	=	self.m_pRequestParams;
		pController.m_EventType	=	GSEventType_LOGIN;
		pController.m_ActionType	=	GSWebAction_NavigateToLogin;
		pController.m_pGSAPI	=	self.m_pGSAPI;
		pController.m_pNotificationMessage	=	self.m_pNotificationMessage;
		pController.m_pSavedContext	=	self.m_pSavedContext;
		[self.navigationController pushViewController:pController animated:YES];
		[pController release];	
		return;
	}
	self.m_EventType	=	GSEventType_LOGIN;
	
	NSString	*pProvider = [self GetProvider];
	if(pProvider	==	nil)
	{
		self.m_pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_MissingArgument format:[self.m_pRequestParams getString:@"format" defaultValue:@"json"] method:@"login" trace:self.m_pTrace]	autorelease];
		[self.delegate GSWebViewControllerDidFinish:self];
		return;
	}
	if(![self facebookLoginActivated:pProvider] && ![self twitterLoginActivated:pProvider])
	{
		self.title	=	[self GetProviderDisplayName];
		NSString	*pLoginURL	=	GSAPI_LOGIN_URL_HTTPS;
		GSObject *pServerParams= [[[GSObject alloc]init]autorelease];
		[pServerParams putStringValue:@"token" forKey:@"response_type"];
		[pServerParams putStringValue:self.m_pGSAPI.m_pAPIKey forKey:@"client_id"];
		[pServerParams putStringValue:GSAPI_RESULT_URL forKey:@"redirect_uri"];
		[pServerParams putStringValue:pProvider forKey:@"x_provider"];
		[pServerParams putStringValue:@"oauth1" forKey:@"x_secret_type"];
		if([self getForceAuthentication]	!=	nil)
			[pServerParams putStringValue:[self getForceAuthentication] forKey:@"x_force_authentication"];
		if([self GetCID]	!=	nil)
			[pServerParams putStringValue:[self GetCID] forKey:@"x_cid"];
		if([self GetLang]	!=	nil)
			[pServerParams putStringValue:[self GetLang] forKey:@"x_lang"];
		if([self GetExtraPermissions]	!=	nil)
			[pServerParams putStringValue:[self GetExtraPermissions] forKey:@"x_extraPermissions"];
		if([pProvider compare:FACEBOOK_PROVIDER_NAME]	==	NSOrderedSame)
		{
			if(self.m_pFacebook	!=	nil	&&	self.m_pFacebook.accessToken	!=	nil)
			{
				//				pLoginURL	=	GSAPI_LOGIN_URL_HTTPS;
				[pServerParams putStringValue:self.m_pFacebook.accessToken forKey:@"x_providerToken"];
				if(self.m_pFacebook.expirationDate != [NSDate distantFuture])
					[pServerParams putLongValue:(long)[self.m_pFacebook.expirationDate timeIntervalSince1970] forKey:@"x_providerTokenExpiration"];
			}
		}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
		else if([pProvider compare:TWITTER_PROVIDER_NAME]	==	NSOrderedSame)
		{
			if(self.m_bLoggedInToTwitter)
			{
				[pServerParams putStringValue:[self.m_pTwitterCredentials getString:@"oauth_token" defaultValue:@""] forKey:@"x_providerToken"];
				[pServerParams putStringValue:[self.m_pTwitterCredentials getString:@"oauth_token_secret" defaultValue:@""] forKey:@"x_providerTokenSecret"];
			}
		}
#endif		
		NSURL *pURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",pLoginURL,[pServerParams toQueryString]]];	
		[self.m_pWebView loadRequest:[NSURLRequest requestWithURL:pURL]];
	}
	
}

-(void) NavigateToConnect
{
	if(self.m_ActionType != GSWebAction_NavigateToConnect)
	{
		
		GSWebViewController *pController = [[GSWebViewController alloc] initWithNibName:@"GSWebViewController" bundle:nil];
		pController.delegate = self.delegate;
		pController.m_pTrace	=	[self.m_pTrace	clone];
		pController.m_pRequestParams	=	self.m_pRequestParams;
		pController.m_EventType	=	GSEventType_CONNECT;
		pController.m_ActionType	=	GSWebAction_NavigateToConnect;
		pController.m_pGSAPI	=	self.m_pGSAPI;
		pController.m_pNotificationMessage	=	self.m_pNotificationMessage;
		pController.m_pSavedContext	=	self.m_pSavedContext;
		[self.navigationController pushViewController:pController animated:YES];
		[pController release];	
		return;
	}
	
	self.m_EventType	=	GSEventType_CONNECT;
	
	NSString	*pProvider = [self GetProvider];
	if(pProvider	==	nil)
	{
		self.m_pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_MissingArgument format:[self.m_pRequestParams getString:@"format" defaultValue:@"json"] method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login"	trace:self.m_pTrace]	autorelease];
		[self.delegate GSWebViewControllerDidFinish:self];
		return;
	}
	if(![self facebookLoginActivated:pProvider]	&&	![self twitterLoginActivated:pProvider])
	{
		NSString	*pAccessToken = [self.m_pGSAPI GetAccessToken];
		if(pAccessToken	==	nil)
		{
			self.m_pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_InvalidSession format:[self.m_pRequestParams getString:@"format" defaultValue:@"json"] method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login"	trace:self.m_pTrace]	autorelease];
			[self.delegate GSWebViewControllerDidFinish:self];
			return;
		}
		self.title	=	[self GetProviderDisplayName];
		
		GSObject *pServerParams= [[[GSObject alloc]init]autorelease];
		NSString	*pConnectURL	=	GSAPI_CONNECT_URL_HTTPS;
		[pServerParams putStringValue:pAccessToken forKey:@"oauth_token"];
		[pServerParams putStringValue:@"token" forKey:@"response_type"];
		[pServerParams putStringValue:self.m_pGSAPI.m_pAPIKey forKey:@"client_id"];
		[pServerParams putStringValue:GSAPI_RESULT_URL forKey:@"redirect_uri"];
		[pServerParams putStringValue:pProvider forKey:@"x_provider"];
		[pServerParams putStringValue:@"oauth1" forKey:@"x_secret_type"];
		if(self.m_pRequestParams	!=	nil	&&	[self.m_pRequestParams	contains:@"getPerms"])
			[pServerParams	putIntValue:[self.m_pRequestParams	getInt:@"getPerms"] forKey:@"getPerms"];
		if([self getForceAuthentication]	!=	nil)
			[pServerParams putStringValue:[self getForceAuthentication] forKey:@"x_force_authentication"];
		if([self GetCID]	!=	nil)
			[pServerParams putStringValue:[self GetCID] forKey:@"x_cid"];
		if([self GetLang]	!=	nil)
			[pServerParams putStringValue:[self GetLang] forKey:@"x_lang"];
		if([self GetExtraPermissions]	!=	nil)
			[pServerParams putStringValue:[self GetExtraPermissions] forKey:@"x_extraPermissions"];
		if([pProvider compare:FACEBOOK_PROVIDER_NAME]	==	NSOrderedSame)
		{
			if(self.m_pFacebook	!=	nil	&&	self.m_pFacebook.accessToken	!=	nil)
			{
				//				pConnectURL	=	GSAPI_CONNECT_URL_HTTPS;
				[pServerParams putStringValue:self.m_pFacebook.accessToken forKey:@"x_providerToken"];
				if(self.m_pFacebook.expirationDate != [NSDate distantFuture])
					[pServerParams putLongValue:(long)[self.m_pFacebook.expirationDate timeIntervalSince1970] forKey:@"x_providerTokenExpiration"];
			}
		}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
		else if([pProvider compare:TWITTER_PROVIDER_NAME]	==	NSOrderedSame)
		{
			if(self.m_bLoggedInToTwitter)
			{
				[pServerParams putStringValue:[self.m_pTwitterCredentials getString:@"oauth_token" defaultValue:@""] forKey:@"x_providerToken"];
				[pServerParams putStringValue:[self.m_pTwitterCredentials getString:@"oauth_token_secret" defaultValue:@""] forKey:@"x_providerTokenSecret"];
			}
		}
#endif		
		NSURL *pURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",pConnectURL,[pServerParams toQueryString]]];	
		[self.m_pWebView loadRequest:[NSURLRequest requestWithURL:pURL]];
		
	}
}

-(void) NavigateToProviderSelector
{
	if(self.m_pRequestParams	==	nil)
	{
		self.m_pRequestParams	=	[[[GSObject alloc] init]	autorelease];
	}
	
	if(self.m_EventType	==	GSEventType_CONNECT)
	{
		NSString	*pAccessToken = [self.m_pGSAPI GetAccessToken];
		if(pAccessToken	==	nil)
		{
			self.m_pResponse	=	[[[GSResponse alloc] initWithError:GSErrorCode_InvalidSession format:[self.m_pRequestParams getString:@"format" defaultValue:@"json"] method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login"	trace:self.m_pTrace]	autorelease];
			[self.delegate GSWebViewControllerDidFinish:self];
			return;
		} else {
			[self.m_pRequestParams	putStringValue:pAccessToken forKey:@"oauth_token"];
		}
	}
	
	[self.m_pRequestParams	putStringValue:GSAPI_NET_SELECT_URL forKey:@"redirect_uri"];
	if([self.m_pGSAPI GetLastLoginProvider] != nil)
		[self.m_pRequestParams	putStringValue:[self.m_pGSAPI GetLastLoginProvider] forKey:@"lastLoginProvider"];
	
	NSURL *pURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",GSAPI_UI_URL,[self.m_pRequestParams toQueryString]]];	
	[self.m_pWebView loadRequest:[NSURLRequest requestWithURL:pURL]];
	NSString	*pTitle = [self.m_pRequestParams getString:GSAPI_PARAM_NAME_CAPTION_TEXT];
	if(pTitle	==	nil)
	{
		if(self.m_EventType	==	GSEventType_CONNECT)
			self.title	=	@"Add a connection";
		else
			self.title	=	@"Login";
	}	else {
		self.title	=	pTitle;
	}
	
}




- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType 
{

    
#ifdef	_DEBUG
	NSLog(@"Should Start WebView Request URL = %@\nhost=%@\npath=%@",[[request URL] absoluteString],[[request URL] host],[[request URL] path]);
#endif
	
	NSString	*pURL = [[request	URL] absoluteString];
	
	
	if([pURL	rangeOfString:GSAPI_NET_SELECT_URL].location == 0)
	{
		GSObject	*pQSParams	=	[GSObject objectWithURL:[[request URL]absoluteString] ];
		if([pQSParams getString:GSAPI_PARAM_NAME_PROVIDER] != nil)
		{
			[self.m_pRequestParams putStringValue:[pQSParams getString:GSAPI_PARAM_NAME_PROVIDER] forKey:GSAPI_PARAM_NAME_PROVIDER];
			if([pQSParams getString:GSAPI_PARAM_NAME_PROVIDER_DISPLAY_NAME] != nil)
			{
				[self.m_pRequestParams putStringValue:[pQSParams getString:GSAPI_PARAM_NAME_PROVIDER_DISPLAY_NAME] forKey:GSAPI_PARAM_NAME_PROVIDER_DISPLAY_NAME];
			}
			if(self.m_EventType	==	GSEventType_LOGIN)
			{
				[self NavigateToLogin];
			} else 	if(self.m_EventType	==	GSEventType_CONNECT)
			{
				[self NavigateToConnect];
			}
		}	else 
		{
			self.m_pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_MissingArgument format:[self.m_pRequestParams getString:@"format" defaultValue:@"json"] method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login" trace:self.m_pTrace]	autorelease];
			[self.delegate GSWebViewControllerDidFinish:self];
		}
		return NO;
	} else if([pURL	rangeOfString:GSAPI_RESULT_URL].location == 0)
	{
		[self.m_pTrace	addKey:@"Navigating to" value:pURL];
		
		GSObject	*pQSParams	=	[GSObject objectWithURL:[[request URL]absoluteString] ];
		[self OnResult:pQSParams];
		return NO;
	} else if([pURL	rangeOfString:GSAPI_TITLE_URL].location == 0)
	{
		GSObject	*pQSParams	=	[GSObject objectWithURL:[[request URL]absoluteString] ];
		if([pQSParams getString:@"title"] != nil)
			self.title	=	[pQSParams getString:@"title"];
		return NO;
	}	
	return YES;
}


-(void) OnResult:(GSObject *)pResponse
{
#ifdef _DEBUG
	NSLog(@"On Result -> Response = %@\n",pResponse);
#endif
	[self.m_pTrace addKey:@"WebViewRequest.onResult" value:pResponse];
	
	if([pResponse getString:GSAPI_PARAM_NAME_ERROR_DESCRIPTION] !=nil)
	{
		NSArray	*pArray = [[pResponse getString:GSAPI_PARAM_NAME_ERROR_DESCRIPTION] componentsSeparatedByString:@"-"];
		self.m_pResponse = [[[GSResponse	alloc] initWithError:[[[pArray objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue] ErrorMessage:[[pArray objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] format:[self.m_pRequestParams getString:@"format" defaultValue:@"json"] method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login" trace:self.m_pTrace]	autorelease];
	}	else {
		self.m_pResponse = [[[GSResponse	alloc] initWithResponseData:pResponse	trace:self.m_pTrace]	autorelease];
	}
	[self.delegate GSWebViewControllerDidFinish:self];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	self.m_pSpinner.center = self.view.center;
	[self.m_pSpinner startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	
	[self.m_pSpinner stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
	
	
#ifdef	_DEBUG
	NSLog(@"WebView Request Finished URL = %@\nhost=%@\npath=%@",[[webView.request URL] absoluteString],[[webView.request URL] host],[[webView.request URL] path]);
#endif
	
	NSString	*pURL = [[webView.request	URL] absoluteString];
	
	
	if([pURL	rangeOfString:GSAPI_UI_URL].location == 0)
	{
		NSMutableDictionary	*pDict = [[[NSMutableDictionary alloc] init] autorelease];
		[pDict	setObject:self.m_pSavedContext forKey:GSAPI_PARAM_NAME_CONEXT];
		
		NSNotification *pNotification;
		if(self.m_EventType	==	GSEventType_CONNECT)
		{
			pNotification = [NSNotification notificationWithName:ShowAddConnectionsUILoaded_Notification object:nil userInfo:pDict];
		}	else {
			pNotification = [NSNotification notificationWithName:ShowLoginUILoaded_Notification object:nil userInfo:pDict];
		}
		[[NSNotificationQueue defaultQueue] enqueueNotification:pNotification postingStyle:NSPostWhenIdle];
	}
	
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	
	if([error code] == NSURLErrorCancelled)
		return;
	
#ifdef	_DEBUG
	NSLog(@"WebView failed loading. errorMessage=%@",[error localizedDescription]);
#endif
	
	[self.m_pSpinner stopAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
	
	[self.m_pTrace addKey:@"Error from web UI"	value:[error localizedDescription]] ;
	
	
	GSResponse	*pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_HTTPFailure ErrorMessage:[error localizedDescription] format:[self.m_pRequestParams getString:@"format" defaultValue:@"json"] method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login" trace:self.m_pTrace] autorelease];
	
	
	NSMutableDictionary	*pDict = [[[NSMutableDictionary alloc] init] autorelease];
	[pDict	setObject:pResponse forKey:GSAPI_PARAM_NAME_GSRESPONSE];
	[pDict	setObject:self.m_pSavedContext forKey:GSAPI_PARAM_NAME_CONEXT];
	
	NSNotification *pNotification;
	if(self.m_EventType	==	GSEventType_CONNECT)
	{
		pNotification = [NSNotification notificationWithName:ShowAddConnectionsUIFailed_Notification object:nil userInfo:pDict];
	}	else {
		pNotification = [NSNotification notificationWithName:ShowLoginUIFailed_Notification object:nil userInfo:pDict];
	}
	
	[[NSNotificationQueue defaultQueue] enqueueNotification:pNotification postingStyle:NSPostWhenIdle];
	self.m_pResponse	=	nil;
	[self.delegate GSWebViewControllerDidFinish:self];
}

-(IBAction)	OnCancel:(id)Sender
{
	self.m_pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_CanceledByUser format:@"json" method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login" trace:self.m_pTrace]	autorelease];
	[self.delegate GSWebViewControllerDidFinish:self];
}
- (void)fbDidLogin
{
	self.m_bFacebookLoginCompleted	=	true;
#ifdef		_DEBUG
	NSLog(@"facebook sdk login completed.\naccessToken=%@\nexpirationDate=%@\n",self.m_pFacebook.accessToken,self.m_pFacebook.expirationDate);
#endif
	if(self.m_EventType	==	GSEventType_CONNECT)
	{
		[self NavigateToConnect];
	}	else {
		[self NavigateToLogin];
	}
	
	
}
- (void)fbDidNotLogin:(BOOL)cancelled
{
	self.m_bFacebookLoginCompleted	=	true;
	self.m_pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_CanceledByUser format:@"json" method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login"trace:self.m_pTrace]	autorelease];
	[self.delegate GSWebViewControllerDidFinish:self];
}

- (void)fbDidLogout
{
	
}

- (void) onApplicationBecomeActive:(NSNotification *)pNotification
{
#ifdef		_DEBUG
	NSLog(@"onApplicationBecomeActive - Notification");
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
	if(!self.m_bFacebookLoginCompleted	&&	!self.m_bTwitterLoginCompleted)
#else
		if(!self.m_bFacebookLoginCompleted)
#endif
	{
		self.m_pResponse	=	[[[GSResponse	alloc] initWithError:GSErrorCode_CanceledByUser format:@"json" method:self.m_EventType	==	GSEventType_CONNECT ? @"connect" : @"login"trace:self.m_pTrace]	autorelease];
		[self.delegate GSWebViewControllerDidFinish:self];
	}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
	self.m_bTwitterLoginCompleted	=	NO;
#endif
	self.m_bFacebookLoginCompleted	=	NO;
}



@end
