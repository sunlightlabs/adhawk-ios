//
//  GSAPI.m
//	Version: 2.15.3


#import "GSAPI_Internal.h"
#import	"GSWebViewController.h"
#import	"GSResponse.h"
#import	"GSRequest.h"




@implementation GSAPI_Internal

@synthesize	m_pAPIKey;
@synthesize	m_pMainViewController;
@synthesize	m_pSettings;
@synthesize	m_pSession;
@synthesize	m_pNotificationMessage;
@synthesize	m_bNoReEntrantCallPending;
@synthesize	delegate;
@synthesize	m_pSavedRequestParams;
@synthesize	m_pFacebook;
@synthesize	m_bCanceledByUser;
@synthesize	m_pSDKConfig;
@synthesize m_pTwitterReverseToken;

-	(void) getSDKConfig
{
	
	@synchronized(self)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#ifdef	_DEBUG
		NSLog(@"get SDK Config");
#endif
		[NSThread	setThreadPriority:0.01];
		
		NSURL *pURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://socialize.gigya.com/socialize.getSDKConfig?format=json&apikey=%@",self.m_pAPIKey]		]; 
		NSString *pJSON = [NSString stringWithContentsOfURL:pURL encoding:NSUTF8StringEncoding error:nil];
		if([pJSON length] > 0)
		{
#ifdef _DEBUG
			NSLog(@"SDKConfig=\n%@",pJSON);
#endif
			self.m_pSDKConfig	=	[GSObject objectWithJSONString:pJSON];
		}	else {
			self.m_pSDKConfig	=	[[[GSObject alloc]init] autorelease];
		}
		
		
		[pool release];  
	}
	
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000

-	(void)	notifyTwitterListener
{
	// this will run on the main thread
	[[NSNotificationQueue	defaultQueue] enqueueNotification:[NSNotification notificationWithName:Twitter_Reverse_Token_Received_Notification object:nil] postingStyle:NSPostWhenIdle];
	
}
-	(void) getTwitterReverseToken
{
	
	@synchronized(self)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[NSThread	setThreadPriority:0.01];
		

			NSURL *pURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://socialize.gigya.com/socialize.getTwitterReverseAuthToken?format=json&apikey=%@",self.m_pAPIKey]		]; 
#ifdef	_DEBUG
			NSLog(@"getTwitterReverseToken - url=%@\n",pURL);
#endif
			NSString *pJSON = [NSString stringWithContentsOfURL:pURL encoding:NSUTF8StringEncoding error:nil];
			if([pJSON length] > 0)
			{
#ifdef _DEBUG
				NSLog(@"Twitter Reverse Token=\n%@",pJSON);
#endif
				self.m_pTwitterReverseToken	=	[GSObject objectWithJSONString:pJSON];
			}	else {
				self.m_pTwitterReverseToken	=	[[[GSObject alloc]init] autorelease];
			}

		[self performSelectorOnMainThread:@selector(notifyTwitterListener) withObject:nil waitUntilDone:YES];
		
		
		[pool release];  
	}
	
}

-	(GSObject	*)	extractTwitterReverseToken
{
	if(self.m_pTwitterReverseToken	==	nil)
		return nil;
	if([[self.m_pTwitterReverseToken	getString:@"data" defaultValue:@""]	length]	==	0)
		return nil;
	GSObject	*pDict = [[[GSObject	alloc]	init]	autorelease];
	NSString *pReverseToken = [self.m_pTwitterReverseToken getString:@"data" defaultValue:@""];
	NSString *pToken	=	[pReverseToken stringByReplacingOccurrencesOfString:@"OAuth " withString:@""];
	pToken	=	[pToken stringByReplacingOccurrencesOfString:@" " withString:@""];
	pToken	=	[pToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	pToken	=	[pToken stringByReplacingOccurrencesOfString:@"," withString:@"&"];
	[pDict parseQueryString:pToken];
	if([[pDict getString:@"oauth_token" defaultValue:@""] length]	==	0)
		return nil;
	if([[pDict getString:@"oauth_consumer_key" defaultValue:@""] length]	==	0)
		return nil;
	[pDict putStringValue:pReverseToken forKey:@"OAuth"];
	return pDict;
}
#endif

-	(void) sendErrorReport:(NSArray	*)pParams
{
	
	@synchronized(self)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#ifdef	_DEBUG
		NSLog(@"send Error Report");
#endif
		[NSThread	setThreadPriority:0.01];
		
		NSString	*pMethod	=	[pParams objectAtIndex:0];
		GSResponse	*pResponse	=	[pParams	objectAtIndex:1];
		NSString	*pErrorNumber = [NSString	stringWithFormat:@"%d",pResponse.errorCode];
		
		BOOL	bSendReport = NO;
		if(self.m_pSDKConfig	&&	[self.m_pSDKConfig	contains:@"errorReportRules"])
		{
			NSArray		*pErrors = [self.m_pSDKConfig getArray:@"errorReportRules"];
			for(GSObject *pEntry in pErrors)
			{
				if([[pEntry getString:@"method" defaultValue:@"!!!"] caseInsensitiveCompare:pMethod] == NSOrderedSame ||
					 [[pEntry getString:@"method" defaultValue:@"!!!"] caseInsensitiveCompare:@"*"] == NSOrderedSame)
				{
					if([[pEntry getString:@"error" defaultValue:@"!!!"] caseInsensitiveCompare:pErrorNumber] == NSOrderedSame ||
						 [[pEntry getString:@"error" defaultValue:@"!!!"] caseInsensitiveCompare:@"*"] == NSOrderedSame)	
					{
						bSendReport	=	YES;
						break;
					}
				}
			}
		}
		
		if(bSendReport)
		{
			GSObject	*pDictToSend = [[[GSObject alloc]init]autorelease];
			[pDictToSend putIntValue:pResponse.errorCode forKey:@"info"];
			[pDictToSend putStringValue:[pResponse getLog] forKey:@"log"];
			[pDictToSend putStringValue:self.m_pAPIKey forKey:@"apiKey"];
			
			[pDictToSend putStringValue:@"json" forKey:@"format"];
			[pDictToSend putStringValue:GSAPI_SDK_VERSION_STRING forKey:@"sdk"];
			
			
			NSString	*pQueryString =	[pDictToSend	toQueryString];
			
			
			NSURL *pUrl = [NSURL URLWithString:@"http://socialize.gigya.com/socialize.reportSDKError"];
			NSMutableURLRequest *pReq = [NSMutableURLRequest requestWithURL:pUrl];
			[pReq setHTTPMethod:@"POST"];
			
			NSMutableData *pPostBody = [NSMutableData data];
			[pPostBody appendData:[pQueryString dataUsingEncoding:NSUTF8StringEncoding]];
			[pReq setHTTPBody:pPostBody];
			
			
			NSURLResponse *theResponse = NULL;
			NSError *theError = NULL;
			NSData *theResponseData = [NSURLConnection sendSynchronousRequest:pReq returningResponse:&theResponse error:&theError];
#ifdef _DEBUG
			NSString *theResponseString = [[[NSString alloc] initWithData:theResponseData encoding:NSUTF8StringEncoding] autorelease];
			NSLog(@"response String=%@",theResponseString);
#endif
			
		}
		
		[pool release];  
	}
	
}

- (void)setUcidCookie {
    NSDictionary *ucidCookieProps = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"FALSE", NSHTTPCookieDiscard,
                                     @".gigya.com", NSHTTPCookieDomain,
                                     @"ucid", NSHTTPCookieName,
                                     @"/", NSHTTPCookiePath,
                                     [self.m_pSettings objectForKey:@"ucid"], NSHTTPCookieValue, nil];
    NSHTTPCookie *ucidCookie = [NSHTTPCookie cookieWithProperties:ucidCookieProps];  
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:ucidCookie];
}

- (id)initWithAPIKey:(NSString *)APIKey ViewController:(UIViewController *)MainViewController delegate:(id)pDelegate {
	if ((self = [super init])) {		
		self.m_pAPIKey = APIKey;
		self.delegate	=	pDelegate;
		self.m_pMainViewController = MainViewController;
		[self LoadSettings];
		[self LoadSession];
        [self setUcidCookie];
        
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:GetUserInfoCompletedAfterLogin_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:GetUserInfoCompletedAfterConnect_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:LoginCompleted_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:LogoutCompleted_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:AddConnectionCompleted_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:RemoveConnectionCompleted_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:ShowLoginUICompleted_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:SendRequestCompleted_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:ShowAddConnectionsUICompleted_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:ShowAddConnectionsUILoaded_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:ShowLoginUILoaded_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:ShowAddConnectionsUIFailed_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:ShowLoginUIFailed_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:ShowAddConnectionsUIClosed_Notification object: nil ];
		[[ NSNotificationCenter defaultCenter] addObserver:self selector: @selector(OnNotification:) name:ShowLoginUIClosed_Notification object: nil ];
		
		
		[NSThread detachNewThreadSelector:@selector(getSDKConfig) toTarget:self withObject:nil];
//		[NSThread detachNewThreadSelector:@selector(getTwitterReverseToken) toTarget:self withObject:nil];
		
		
	}
	return self;
}

- (BOOL)handleOpenURL:(NSURL *)url
{
	if(self.m_pFacebook)
		return	[self.m_pFacebook	handleOpenURL:url];
	return NO;	
}
-	(void)	setFacebook:(GSFacebook	*)pFacebook
{
#ifdef _DEBUG
	NSLog(@"set Facebook to: %@",pFacebook);
#endif 
	self.m_pFacebook	=	pFacebook;
}


- (void) OnNotification:(NSNotification *)pNotification
{
	self.m_bNoReEntrantCallPending	=	NO;
	self.m_pNotificationMessage	=	nil;
	
	GSObject *pRequest = [pNotification.userInfo objectForKey:GSAPI_PARAM_NAME_REQUEST_PARAMS_DICTIONARY];
	GSResponse *pResponse = [pNotification.userInfo objectForKey:GSAPI_PARAM_NAME_GSRESPONSE];
	NSString	*pMethod = [pNotification.userInfo objectForKey:GSAPI_PARAM_NAME_SEND_REQUEST_METHOD];
	id	pContext = [pNotification.userInfo objectForKey:GSAPI_PARAM_NAME_CONEXT];
	
	if(pResponse.errorCode == GSErrorCode_CanceledByUser)
	{
#ifdef	_DEBUG
		NSLog(@"\n\nCanceled by user\n\n");
#endif
	}
	
	
#ifdef	_DEBUG
	NSLog(@"\r\nNotification=%@\r\n",pNotification.name);
	if(pResponse!=nil)
		NSLog(@"\r\n########## BEGIN Response Log ##########\r\n%@\r\n##########  END  Response  Log ##########",[pResponse getLog]);
	
#endif
	
	if([pNotification.name compare:LoginCompleted_Notification] == NSOrderedSame)
	{
		if(pResponse.errorCode != 0)
			[self.delegate onLoginCompleted:pRequest  response:pResponse context:pContext];
		else
			[self GetUserInfo:GetUserInfoCompletedAfterLogin_Notification context:pContext originalRequest:pRequest	trace:pResponse.m_pTrace];
	}
	else		if([pNotification.name compare:ShowLoginUICompleted_Notification] == NSOrderedSame)
	{
		if(pResponse.errorCode != 0)
			[self.delegate onShowLoginUICompleted:pRequest  response:pResponse context:pContext];
		else
			[self GetUserInfo:GetUserInfoCompletedAfterLogin_Notification context:pContext originalRequest:pRequest	trace:pResponse.m_pTrace];
	}
	
	else	if([pNotification.name compare: GetUserInfoCompletedAfterLogin_Notification] == NSOrderedSame)
	{
		
		NSArray	*pParams	=	[NSArray arrayWithObjects:pMethod,pResponse,nil];
		[NSThread detachNewThreadSelector:@selector(sendErrorReport:) toTarget:self withObject:pParams];
		[self.delegate onLoginCompleted:self.m_pSavedRequestParams  response:pResponse context:pContext];
	}
	else	if([pNotification.name compare: GetUserInfoCompletedAfterConnect_Notification] == NSOrderedSame)
	{
		NSArray	*pParams	=	[NSArray arrayWithObjects:pMethod,pResponse,nil];
		[NSThread detachNewThreadSelector:@selector(sendErrorReport:) toTarget:self withObject:pParams];
		[self.delegate onAddConnectionCompleted:self.m_pSavedRequestParams  response:pResponse context:pContext];
	}
	else	if([pNotification.name compare:LogoutCompleted_Notification] == NSOrderedSame)
	{
		NSArray	*pParams	=	[NSArray arrayWithObjects:pMethod,pResponse,nil];
		[NSThread detachNewThreadSelector:@selector(sendErrorReport:) toTarget:self withObject:pParams];
        NSHTTPCookieStorage *pStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for(NSHTTPCookie *pCookie in [pStorage cookies])
        {
            [pStorage deleteCookie:pCookie];
        }
		self.m_pSession	=	nil;
		[self SaveSession];
        [self setUcidCookie];
		[self.delegate onLogoutCompleted:pResponse];
	}
	else		if([pNotification.name compare:AddConnectionCompleted_Notification] == NSOrderedSame)
	{
		if(pResponse.errorCode != 0)
			[self.delegate onAddConnectionCompleted:pRequest  response:pResponse  context:pContext];
		else
			[self GetUserInfo:GetUserInfoCompletedAfterConnect_Notification  context:pContext originalRequest:pRequest	trace:pResponse.m_pTrace];
		
	}
	else		if([pNotification.name compare:RemoveConnectionCompleted_Notification] == NSOrderedSame)
	{
		NSArray	*pParams	=	[NSArray arrayWithObjects:pMethod,pResponse,nil];
		[NSThread detachNewThreadSelector:@selector(sendErrorReport:) toTarget:self withObject:pParams];
		[self.delegate onRemoveConnectionCompleted:pRequest  response:pResponse context:pContext];
	}
	else		if([pNotification.name compare:SendRequestCompleted_Notification] == NSOrderedSame)
	{
		NSArray	*pParams	=	[NSArray arrayWithObjects:pMethod,pResponse,nil];
		[NSThread detachNewThreadSelector:@selector(sendErrorReport:) toTarget:self withObject:pParams];
		[self.delegate onSendRequestCompleted:pMethod Params:pRequest  response:pResponse context:pContext];
	}	else		if([pNotification.name compare:ShowAddConnectionsUICompleted_Notification] == NSOrderedSame)
	{
		if(pResponse.errorCode != 0)
			[self.delegate onShowAddConnectionsUICompleted:pRequest  response:pResponse context:pContext];
		else
			[self GetUserInfo:GetUserInfoCompletedAfterConnect_Notification  context:pContext originalRequest:pRequest	trace:pResponse.m_pTrace];
		
	}	else	if([pNotification.name compare:ShowAddConnectionsUILoaded_Notification] == NSOrderedSame)
		[self.delegate onShowAddConnectionsUILoaded:pRequest  response:pResponse context:pContext];
	else	if([pNotification.name compare:ShowAddConnectionsUIFailed_Notification] == NSOrderedSame)
		[self.delegate onShowAddConnectionsUIFailed:pRequest  response:pResponse context:pContext];
	else	if([pNotification.name compare:ShowAddConnectionsUIClosed_Notification] == NSOrderedSame)
		[self.delegate onShowAddConnectionsUIClosed:pRequest  response:pResponse context:pContext];
	else	if([pNotification.name compare:ShowLoginUILoaded_Notification] == NSOrderedSame)
		[self.delegate onShowLoginUILoaded:pRequest  response:pResponse context:pContext];
	else	if([pNotification.name compare:ShowLoginUIFailed_Notification] == NSOrderedSame)
		[self.delegate onShowLoginUIFailed:pRequest  response:pResponse context:pContext];
	else	if([pNotification.name compare:ShowLoginUIClosed_Notification] == NSOrderedSame)
		[self.delegate onShowLoginUIClosed:pRequest  response:pResponse context:pContext];
}

-	(void) GetUserInfo:(NSString *)pNotificationName  context:(id)pContext originalRequest:(GSObject *)pRequestParams	trace:(GSLogger	*)pTrace
{
	if(pRequestParams	!=	nil)
		self.m_pSavedRequestParams	=	pRequestParams;
	self.m_pNotificationMessage	=	pNotificationName;
	[self SendRequest:@"socialize.getUserInfo" Params:nil UseHTTPS:YES context:pContext	trace:pTrace];
}



-(void) LoadSettings
{
	NSString	*pSettingsFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"GSAPI_Settings"];
	self.m_pSettings	= [NSMutableDictionary	dictionaryWithContentsOfFile:pSettingsFile];
	if(self.m_pSettings	==	nil)
	{
		self.m_pSettings	=	[[[NSMutableDictionary	alloc]init]	autorelease];
		[self.m_pSettings	setObject:@"Initialized" forKey:@"SettingsStatus"];
		[self SaveSettings];
	}
    
    if ([self.m_pSettings objectForKey:@"ucid"] == nil)
    {
        //create a UCID
        CFUUIDRef ucid = CFUUIDCreate(NULL); 
        CFStringRef sUuid = CFUUIDCreateString(NULL, ucid);
        CFRelease(ucid);
        [self.m_pSettings setObject:[(NSString *)sUuid autorelease] forKey:@"ucid"];
        [self SaveSettings];
    }
    
}
-(void) SaveSettings
{
	NSString	*pSettingsFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"GSAPI_Settings"];
	[self.m_pSettings writeToFile:pSettingsFile atomically:YES];
	
}
-(NSString	*) GetLastLoginProvider
{
	return [self.m_pSettings	objectForKey:@"LastLoginProvider"];
}
-(void) SetLastLoginProvider:(NSString	*)pProvider
{
	[self.m_pSettings	setObject:pProvider forKey:@"LastLoginProvider"];
	[self SaveSettings];
}

-(void) LoadSession
{
	self.m_pSession	=	[[[GSSession	alloc]	init]	autorelease];
	
	self.m_pSession.secret	=	[self.m_pSettings	objectForKey:@"session.Secret"];
	self.m_pSession.accessToken	=	[self.m_pSettings	objectForKey:@"session.Token"];
	self.m_pSession.expirationTime	=	[self.m_pSettings	objectForKey:@"session.ExpirationTime"];
}
-(void) SetSession:(GSSession *)pSession
{
	self.m_pSession	=	pSession;
	[self SaveSession];
}

-(void) SaveSession
{
	if(self.m_pSession	!=	nil)
	{
		[self.m_pSettings	setObject:self.m_pSession.secret forKey:@"session.Secret"];
		[self.m_pSettings	setObject:self.m_pSession.accessToken forKey:@"session.Token"];
		[self.m_pSettings	setObject:self.m_pSession.expirationTime forKey:@"session.ExpirationTime"];
	}	else {
		[self.m_pSettings	removeObjectForKey:@"session.Secret"];
		[self.m_pSettings	removeObjectForKey:@"session.Token"];
		[self.m_pSettings	removeObjectForKey:@"session.ExpirationTime"];
	}
	[self SaveSettings];
	
}

-	(NSString	*) GetAccessToken
{
	if(self.m_pSession	==	nil)
		return nil;
	if([self.m_pSession IsValid]	==	YES)
		return self.m_pSession.accessToken;
	return nil;
}

-	(NSString	*) GetSecretKey
{
	if(self.m_pSession	==	nil)
		return nil;
	if([self.m_pSession IsValid]	==	YES)
		return self.m_pSession.secret;
	return nil;
}

-(long) GetServerTimestampSkew
{
	NSNumber	*pSkew = [self.m_pSettings	objectForKey:@"Server.timestampSkew"];
	if(pSkew	==	nil)
		return	0;
	return	[pSkew	longValue];
}
static NSDateFormatter *gDateFormatter	=	nil;
-(void) SetServerTimestampSkew:(NSString	*)pServerTime
{
	if(gDateFormatter	==	nil)
	{
		gDateFormatter = [[NSDateFormatter alloc] init];
		[gDateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
		[gDateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]	autorelease]];
	}
	
	
	NSDate *pDate = [gDateFormatter dateFromString:pServerTime];  
	if(pDate	!=	nil)
	{
		NSDate	*pNow	=	[NSDate	date];
		long skew = [pNow	timeIntervalSince1970]	-	[pDate	timeIntervalSince1970];
		[self.m_pSettings	setObject:[NSNumber	numberWithLong:skew] forKey:@"Server.timestampSkew"];
		[self SaveSettings];
		//		NSLog(@"Server Time = %@, Date = %@ , now= %@ %f %f %ld",pServerTime,[gDateFormatter stringFromDate:pDate],[gDateFormatter stringFromDate:pNow],[pDate timeIntervalSince1970],[pNow timeIntervalSince1970],skew);
	}
	
	
	
	
}




- (void)dealloc {
	self.m_pFacebook	=	nil;
	self.m_pAPIKey	=	nil;
	self.m_pMainViewController	=	nil;
	self.m_pSettings	=	nil;
	self.m_pSession	=	nil;
	self.m_pNotificationMessage	=	nil;
	self.m_pSavedRequestParams=nil;
	self.delegate	=	nil;
	self.m_pSDKConfig	=	nil;
	self.m_pTwitterReverseToken	=	nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)GSWebViewControllerDidFinish:(UIViewController *)controller {
	GSWebViewController *pWebViewController = (GSWebViewController *)controller;
	
	[self.m_pMainViewController dismissModalViewControllerAnimated:YES];
	if(pWebViewController.m_pResponse == nil)
		return;
	
	if(pWebViewController.m_pResponse.errorCode	==	0)
	{
		if(pWebViewController.m_EventType == GSEventType_LOGIN)
		{
			self.m_pSession = [[[GSSession alloc] initWithLoginResponse:pWebViewController.m_pResponse.data]	autorelease];
			[self SaveSession];
			[self SetLastLoginProvider:[pWebViewController GetProvider]];
		}
	}	else if(pWebViewController.m_pResponse.errorCode	==	GSErrorCode_CanceledByUser)
	{
		self.m_bCanceledByUser	=	YES;
	}
	[self SendNotification:pWebViewController.m_pNotificationMessage	APIMethod:nil request:pWebViewController.m_pRequestParams response:pWebViewController.m_pResponse context:pWebViewController.m_pSavedContext];
}

- (void) Login:(GSObject *)pParams	context:(id)pContext
{
	self.m_bCanceledByUser	=	NO;
	if(self.m_bNoReEntrantCallPending)
	{
		[self SendNotification:LoginCompleted_Notification	APIMethod:@"login" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_NonReEntrantCallPending format:[pParams getString:@"format" defaultValue:@"json"] method:@"login" trace:nil] autorelease] context:pContext];
		return;
	}
	self.m_pNotificationMessage	=	LoginCompleted_Notification;
	
	if([pParams getString:GSAPI_PARAM_NAME_PROVIDER]	==	nil	|| [[[pParams getString:GSAPI_PARAM_NAME_PROVIDER] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
	{
		[self SendNotification:@"login" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_MissingArgument format:[pParams getString:@"format" defaultValue:@"json"] method:@"login" trace:nil] autorelease] context:pContext];
		return;
	}
	
	if(self.m_pAPIKey	==	nil)
	{
		[self SendNotification:@"login" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_MissingAPIKey format:[pParams getString:@"format" defaultValue:@"json"] method:@"login" trace:nil] autorelease] context:pContext];
		return;
	}
	
	
	
	
	self.m_bNoReEntrantCallPending	=	YES;
	[self startWebViewControll:pParams eventType:GSEventType_LOGIN actionType:GSWebAction_NavigateToLogin context:pContext];
	/*
	 GSWebViewController *pController = [[GSWebViewController alloc] initWithNibName:@"GSWebViewController" bundle:nil];
	 pController.delegate = self;
	 pController.m_pRequestParams	=	pParams;
	 pController.m_EventType	=	GSEventType_LOGIN;
	 pController.m_ActionType	=	GSWebAction_NavigateToLogin;
	 pController.m_pGSAPI	=	self;
	 pController.m_pSavedContext	=	pContext;
	 pController.m_pNotificationMessage	=	self.m_pNotificationMessage;
	 UINavigationController *navigationController = [[UINavigationController alloc]
	 initWithRootViewController:pController];
	 navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	 [self.m_pMainViewController presentModalViewController:navigationController animated:YES];
	 
	 [pController release];	
	 [navigationController release];
	 */
}

-(void) Logout
{
	self.m_bCanceledByUser	=	NO;
	if(self.m_bNoReEntrantCallPending)
	{
		[self SendNotification:LogoutCompleted_Notification APIMethod:@"socialize.logout" request:nil response:[[[GSResponse alloc] initWithError:GSErrorCode_NonReEntrantCallPending format:@"json" method:@"socialize.logout" trace:nil] autorelease] context:nil];
		return;
	}	
	
	if([self GetAccessToken]	==	nil)
	{
		[self SendNotification:LogoutCompleted_Notification APIMethod:@"socialize.logout" request:nil response:[[[GSResponse alloc] initWithError:GSErrorCode_InvalidSession format:@"json" method:@"socialize.logout" trace:nil] autorelease] context:nil];
		return;
	}
	self.m_pNotificationMessage	=	LogoutCompleted_Notification;
	
	[self SendRequest:@"socialize.logout" Params:nil UseHTTPS:NO context:nil	trace:nil];
}



- (void) AddConnection:(GSObject *)pParams	context:(id)pContext
{
	self.m_bCanceledByUser	=	NO;
	if(self.m_bNoReEntrantCallPending)
	{
		[self SendNotification:AddConnectionCompleted_Notification APIMethod:@"connect" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_NonReEntrantCallPending format:[pParams getString:@"format" defaultValue:@"json"] method:@"connect" trace:nil] autorelease] context:pContext];
		return;
	}
	
	
	
	if([pParams getString:GSAPI_PARAM_NAME_PROVIDER]	==	nil	|| [[[pParams getString:GSAPI_PARAM_NAME_PROVIDER] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
	{
		[self SendNotification:AddConnectionCompleted_Notification APIMethod:@"connect" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_MissingArgument format:[pParams getString:@"format" defaultValue:@"json"] method:@"connect" trace:nil] autorelease] context:pContext];
		return;
	}
	
	if([self GetAccessToken]	==	nil)
	{
		[self SendNotification:AddConnectionCompleted_Notification APIMethod:@"connect" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_InvalidSession format:[pParams getString:@"format" defaultValue:@"json"] method:@"connect" trace:nil] autorelease] context:pContext];
		return;
	}
	self.m_pNotificationMessage	=	AddConnectionCompleted_Notification;
	
	self.m_bNoReEntrantCallPending	=	YES;
	[self startWebViewControll:pParams eventType:GSEventType_CONNECT actionType:GSWebAction_NavigateToConnect context:pContext];
	/*
	 GSWebViewController *pController = [[GSWebViewController alloc] initWithNibName:@"GSWebViewController" bundle:nil];
	 pController.delegate = self;
	 pController.m_pRequestParams	=	pParams;
	 pController.m_EventType	=	GSEventType_CONNECT;
	 pController.m_ActionType	=	GSWebAction_NavigateToConnect;
	 pController.m_pGSAPI	=	self;
	 pController.m_pSavedContext	=	pContext;
	 pController.m_pNotificationMessage	=	self.m_pNotificationMessage;
	 UINavigationController *navigationController = [[UINavigationController alloc]
	 initWithRootViewController:pController];
	 navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	 [self.m_pMainViewController presentModalViewController:navigationController animated:YES];
	 
	 [pController release];	
	 [navigationController release];
	 */
}



-(void) ShowLoginUI:(GSObject *)pParams	context:(id)pContext
{
	self.m_bCanceledByUser	=	NO;
	if(self.m_bNoReEntrantCallPending)
	{
		[self SendNotification:ShowLoginUICompleted_Notification APIMethod:@"login" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_NonReEntrantCallPending format:[pParams getString:@"format" defaultValue:@"json"] method:@"login" trace:nil] autorelease] context:pContext];
		return;
	}
	self.m_bNoReEntrantCallPending	=	YES;
	self.m_pNotificationMessage	=	ShowLoginUICompleted_Notification;
	
	[self startWebViewControll:pParams eventType:GSEventType_LOGIN actionType:GSWebAction_NavigateToProviderSelector context:pContext];
	/*
	 GSWebViewController *pController = [[GSWebViewController alloc] initWithNibName:@"GSWebViewController" bundle:nil];
	 pController.delegate = self;
	 pController.m_pRequestParams	=	pParams;
	 pController.m_EventType	=	GSEventType_LOGIN;
	 pController.m_ActionType	=	GSWebAction_NavigateToProviderSelector;
	 pController.m_pGSAPI	=	self;
	 pController.m_pSavedContext	=	pContext;
	 pController.m_pNotificationMessage	=	self.m_pNotificationMessage;
	 UINavigationController *navigationController = [[UINavigationController alloc]
	 initWithRootViewController:pController];
	 navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	 [self.m_pMainViewController presentModalViewController:navigationController animated:YES];
	 
	 [pController release];	
	 [navigationController release];
	 */
}

- (void) RemoveConnection:(GSObject *)pParams	context:(id)pContext
{
	if(self.m_bNoReEntrantCallPending)
	{
		[self SendNotification:RemoveConnectionCompleted_Notification APIMethod:@"socialize.removeConnection" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_NonReEntrantCallPending format:[pParams getString:@"format" defaultValue:@"json"] method:@"socialize.removeConnection" trace:nil] autorelease] context:pContext];
		return;
	}
	
	
	if([pParams getString:GSAPI_PARAM_NAME_PROVIDER]	==	nil	|| [[[pParams getString:GSAPI_PARAM_NAME_PROVIDER] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
	{
		[self SendNotification:RemoveConnectionCompleted_Notification APIMethod:@"socialize.removeConnection" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_MissingArgument format:[pParams getString:@"format" defaultValue:@"json"] method:@"socialize.removeConnection" trace:nil] autorelease] context:pContext];
		return;
	}
	
	if([self GetAccessToken]	==	nil)
	{
		[self SendNotification:RemoveConnectionCompleted_Notification APIMethod:@"socialize.removeConnection" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_InvalidSession format:[pParams getString:@"format" defaultValue:@"json"] method:@"socialize.removeConnection" trace:nil] autorelease] context:pContext];
		return;
	}
	self.m_pNotificationMessage	=	RemoveConnectionCompleted_Notification;
	self.m_bNoReEntrantCallPending	=	YES;
	
	[self SendRequest:@"socialize.removeConnection" Params:pParams UseHTTPS:NO context:pContext	trace:nil];
	
}

-	(void) ShowAddConnectionsUI:(GSObject *)pParams context:(id)pContext
{
	self.m_bCanceledByUser	=	NO;
	if(self.m_bNoReEntrantCallPending)
	{
		[self SendNotification:ShowAddConnectionsUICompleted_Notification APIMethod:@"connect" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_NonReEntrantCallPending format:[pParams getString:@"format" defaultValue:@"json"] method:@"connect" trace:nil] autorelease] context:pContext];
		return;
	}
	if([self GetAccessToken]	==	nil)
	{
		[self SendNotification:ShowAddConnectionsUICompleted_Notification APIMethod:@"connect" request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_InvalidSession format:[pParams getString:@"format" defaultValue:@"json"] method:@"connect" trace:nil] autorelease] context:pContext];
		return;
	}
	
	self.m_bNoReEntrantCallPending	=	YES;
	self.m_pNotificationMessage	=	ShowAddConnectionsUICompleted_Notification;
	
	[self startWebViewControll:pParams eventType:GSEventType_CONNECT actionType:GSWebAction_NavigateToProviderSelector context:pContext];
	/*
	 GSWebViewController *pController = [[GSWebViewController alloc] initWithNibName:@"GSWebViewController" bundle:nil];
	 pController.delegate = self;
	 pController.m_pRequestParams	=	pParams;
	 pController.m_EventType	=	GSEventType_CONNECT;
	 pController.m_ActionType	=	GSWebAction_NavigateToProviderSelector;
	 pController.m_pGSAPI	=	self;
	 pController.m_pSavedContext	=	pContext;
	 pController.m_pNotificationMessage	=	self.m_pNotificationMessage;
	 UINavigationController *navigationController = [[UINavigationController alloc]
	 initWithRootViewController:pController];
	 navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	 [self.m_pMainViewController presentModalViewController:navigationController animated:YES];
	 
	 [pController release];	
	 [navigationController release];
	 */
	
}

-	(void) SendRequest:(NSString	*)pMethod Params:(GSObject		*)pParams	UseHTTPS:(BOOL)bUseHTTPS context:(id)pContext	trace:(GSLogger	*)pTrace
{
	GSRequest *pRequest = nil;
	
	if(self.m_pNotificationMessage	==	nil)
		self.m_pNotificationMessage	=	SendRequestCompleted_Notification;
	
	if(pMethod	==	nil	||	[pMethod	length]	==	0)
	{
		[self SendNotification:pMethod request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_MissingArgument format:[pParams getString:@"format" defaultValue:@"json"] method:pMethod trace:pTrace] autorelease] context:pContext];
		return;
	}
	/*
	if([self GetSecretKey]	==	nil)
	{
		[self SendNotification:pMethod request:pParams response:[[[GSResponse alloc] initWithError:GSErrorCode_InvalidSession format:[pParams getString:@"format" defaultValue:@"json"] method:pMethod trace:pTrace] autorelease]  context:pContext];
		return;
	}
	*/

	if([self GetSecretKey]	==	nil)
	{
		pRequest = [[GSRequest alloc] initWithSessionToken:self.m_pAPIKey SecretKey:nil APIMethod:pMethod SendParams:pParams UseHTTPS:bUseHTTPS NotificationMessage:self.m_pNotificationMessage trace:pTrace serverTimestampSkewDelegate:self];
	}	else {
		pRequest = [[GSRequest alloc] initWithSessionToken:[self GetAccessToken] SecretKey:[self GetSecretKey] APIMethod:pMethod SendParams:pParams UseHTTPS:bUseHTTPS NotificationMessage:self.m_pNotificationMessage trace:pTrace serverTimestampSkewDelegate:self];
	}

	
	
	[pRequest SendRequest:pContext];
	[pRequest	release];
	self.m_pNotificationMessage	=	nil;
}


-	(void)	SendNotification:(NSString *)pMessage APIMethod:(NSString *)pMethod request:(GSObject		*)pRequestParams response:(GSResponse *)pResponse context:(id)pContext
{
	if(pMessage	!=	nil)
	{
		NSMutableDictionary	*pDict = [[[NSMutableDictionary alloc] init] autorelease];
		if(pRequestParams != nil)
			[pDict	setObject:pRequestParams forKey:GSAPI_PARAM_NAME_REQUEST_PARAMS_DICTIONARY];
		if(pResponse != nil)
			[pDict	setObject:pResponse forKey:GSAPI_PARAM_NAME_GSRESPONSE];
		if(pContext)
			[pDict	setObject:pContext forKey:GSAPI_PARAM_NAME_CONEXT];
		if(pMethod	!=	nil)
			[pDict	setObject:pMethod forKey:GSAPI_PARAM_NAME_SEND_REQUEST_METHOD];
		
		NSNotification *pNotification = [NSNotification notificationWithName:pMessage object:self userInfo:pDict];
		
		[[NSNotificationQueue defaultQueue] enqueueNotification:pNotification postingStyle:NSPostWhenIdle];
	}
}
-	(void)	SendNotification:(NSString *)pMethod request:(GSObject		*)pRequestParams response:(GSResponse *)pResponse context:(id)pContext
{
	[self SendNotification:self.m_pNotificationMessage APIMethod:pMethod request:pRequestParams response:pResponse context:pContext];
}




-(GSSession *) GetSession
{
	if(self.m_pSession	&&	[self.m_pSession	IsValid])
		return self.m_pSession;
	return nil;
	
}


-	(void)	showWebViewOnMainThread:(id)pController
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self.m_pMainViewController presentModalViewController:pController animated:YES];
	[pool	release];
	
}
-	(void)	startWebViewControll:(GSObject	*)pParams	eventType:(GSEventType )eventType	actionType:(GSWebActionType)	actionType	context:(id)pContext
{
	GSWebViewController *pController = [[GSWebViewController alloc] initWithNibName:@"GSWebViewController" bundle:nil];
	pController.delegate = self;
	pController.m_pRequestParams	=	pParams;
	pController.m_EventType	=	eventType;
	pController.m_ActionType	=	actionType;
	pController.m_pGSAPI	=	self;
	pController.m_pSavedContext	=	pContext;
	pController.m_pNotificationMessage	=	self.m_pNotificationMessage;
	UINavigationController *navigationController = [[UINavigationController alloc]
																									initWithRootViewController:pController];
	navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	[self.m_pMainViewController becomeFirstResponder];
	[self.m_pMainViewController resignFirstResponder];
	//	[self.m_pMainViewController presentModalViewController:navigationController animated:YES];
	[self performSelectorOnMainThread:@selector(showWebViewOnMainThread:) withObject:navigationController waitUntilDone:NO];
	
	[pController release];	
	[navigationController release];
}

@end
