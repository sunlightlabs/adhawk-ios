//
//  GSAPI.m
//	Version: 2.15.3


#import "GSAPI.h"
#import	"GSAPI_Internal.h"
#import "GSContext.h"


@interface GSAPI (Private) <GSAPIDelegate>
@end

@implementation GSAPI(Private)

- (void)	onLoginCompleted:(GSObject *)pRequestParams response:(GSResponse *)pResponse context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(pResponse	!=	nil)
	{
		if(pResponse.errorCode	==	0)
		{
			if(self.eventDelegate	!=	nil	&&	[self.eventDelegate respondsToSelector:@selector(gsDidLogin:user:context:)])
			{
				[self.eventDelegate gsDidLogin:[self.apiInternal GetLastLoginProvider] user:pResponse.data context:context.context];
			}
			if(context != nil && context.loginUIDelegate != nil &&	[context.loginUIDelegate respondsToSelector:@selector(gsLoginUIDidLogin:user:context:)])
			{
				[context.loginUIDelegate	gsLoginUIDidLogin:[self.apiInternal GetLastLoginProvider] user:pResponse.data context:context.context];
			}
		}	else {
			if(context != nil && context.loginUIDelegate != nil &&	[context.loginUIDelegate respondsToSelector:@selector(gsLoginUIDidFail:errorMessage:context:)])
			{
				[context.loginUIDelegate	gsLoginUIDidFail:pResponse.errorCode errorMessage:pResponse.errorMessage context:context.context];
			}
		}
		if(context != nil && context.responseDelegate != nil &&	[context.responseDelegate respondsToSelector:@selector(gsDidReceiveResponse:response:context:)])
		{
			[context.responseDelegate	gsDidReceiveResponse:@"login" response:pResponse context:pContext];
		}
	}
}
- (void)	onLogoutCompleted:(GSResponse *)pResponse
{
	if(self.eventDelegate	!=	nil	&&	[self.eventDelegate respondsToSelector:@selector(gsDidLogout)])
	{
		[self.eventDelegate gsDidLogout];
	}
}
- (void)	onAddConnectionCompleted:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(pResponse	!=	nil)
	{
		if(pResponse.errorCode	==	0)
		{
			if(self.eventDelegate	!=	nil	&&	[self.eventDelegate respondsToSelector:@selector(gsDidAddConnection:user:context:)])
			{
				[self.eventDelegate gsDidAddConnection:[pParams getString:GSAPI_PARAM_NAME_PROVIDER] user:pResponse.data context:context.context];
			}
			if(context != nil && context.addConnectionsUIDelegate != nil &&	[context.addConnectionsUIDelegate respondsToSelector:@selector(gsAddConnectionsUIDidConnect:user:context:)])
			{
				[context.addConnectionsUIDelegate	gsAddConnectionsUIDidConnect:[pParams getString:GSAPI_PARAM_NAME_PROVIDER] user:pResponse.data context:context.context];
			}
		}	else {
			if(context != nil && context.addConnectionsUIDelegate != nil &&	[context.addConnectionsUIDelegate respondsToSelector:@selector(gsAddConnectionsUIDidFail:errorMessage:context:)])
			{
				[context.addConnectionsUIDelegate	gsAddConnectionsUIDidFail:pResponse.errorCode errorMessage:pResponse.errorMessage context:context.context];
			}
		}
		if(context != nil && context.responseDelegate != nil &&	[context.responseDelegate respondsToSelector:@selector(gsDidReceiveResponse:response:context:)])
		{
			[context.responseDelegate	gsDidReceiveResponse:@"connect" response:pResponse context:pContext];
		}
	}
	
}
- (void)	onRemoveConnectionCompleted:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(pResponse	!=	nil)
	{
		if(pResponse.errorCode	==	0)
		{
			if(self.eventDelegate	!=	nil	&&	[self.eventDelegate respondsToSelector:@selector(gsDidRemoveConnection:context:)])
			{
				[self.eventDelegate gsDidRemoveConnection:[pParams getString:GSAPI_PARAM_NAME_PROVIDER] context:context.context];
			}
		}
		if(context != nil && context.responseDelegate != nil &&	[context.responseDelegate respondsToSelector:@selector(gsDidReceiveResponse:response:context:)])
		{
			[context.responseDelegate	gsDidReceiveResponse:@"removeConnection" response:pResponse context:pContext];
		}
	}
}

-	(void)	onShowLoginUICompleted:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext
{
	if(pResponse != nil && pResponse.errorCode == 200001) // we ignore login cancelled by user
		return;
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(pResponse	!=	nil)
	{
		if(pResponse.errorCode	!=	0)
		{
			if(context != nil && context.loginUIDelegate != nil &&	[context.loginUIDelegate respondsToSelector:@selector(gsLoginUIDidFail:errorMessage:context:)])
			{
				[context.loginUIDelegate	gsLoginUIDidFail:pResponse.errorCode errorMessage:pResponse.errorMessage context:context.context];
			}
		}
	}
}


-	(void)	onShowLoginUILoaded:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(context != nil && context.loginUIDelegate != nil &&	[context.loginUIDelegate respondsToSelector:@selector(gsLoginUIDidLoad:)])
	{
		[context.loginUIDelegate	gsLoginUIDidLoad:context.context];
	}
	
}
-	(void)	onShowLoginUIFailed:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(pResponse	!=	nil)
	{
		if(pResponse.errorCode	!=	0)
		{
			if(context != nil && context.loginUIDelegate != nil &&	[context.loginUIDelegate respondsToSelector:@selector(gsLoginUIDidFail:errorMessage:context:)])
			{
				[context.loginUIDelegate	gsLoginUIDidFail:pResponse.errorCode errorMessage:pResponse.errorMessage context:context.context];
			}	else 			if(context != nil && context.responseDelegate != nil &&	[context.responseDelegate respondsToSelector:@selector(gsDidReceiveResponse:response:context:)])
			{
				[context.responseDelegate	gsDidReceiveResponse:@"" response:pResponse context:context];
			}
		}
	}
}

-	(void)	onShowLoginUIClosed:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(context != nil && context.loginUIDelegate != nil &&	[context.loginUIDelegate respondsToSelector:@selector(gsLoginUIDidClose:canceled:)])
	{
		[context.loginUIDelegate	gsLoginUIDidClose:context.context	canceled:((GSAPI_Internal	*)self.apiInternal).m_bCanceledByUser];
	}
	
}
-	(void)	onShowAddConnectionsUICompleted:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(pResponse	!=	nil)
	{
		if(pResponse.errorCode	!=	0)
		{
			if(context != nil && context.addConnectionsUIDelegate != nil &&	[context.addConnectionsUIDelegate respondsToSelector:@selector(gsAddConnectionsUIDidFail:errorMessage:context:)])
			{
				[context.addConnectionsUIDelegate	gsAddConnectionsUIDidFail:pResponse.errorCode errorMessage:pResponse.errorMessage context:context.context];
			}
		}
	}
}
-	(void)	onShowAddConnectionsUILoaded:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(context != nil && context.addConnectionsUIDelegate != nil &&	[context.addConnectionsUIDelegate respondsToSelector:@selector(gsAddConnectionsUIDidLoad:)])
	{
		[context.addConnectionsUIDelegate	gsAddConnectionsUIDidLoad:context.context];
	}
}
-	(void)	onShowAddConnectionsUIFailed:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(pResponse	!=	nil)
	{
		if(pResponse.errorCode	!=	0)
		{
			if(context != nil && context.addConnectionsUIDelegate != nil &&	[context.addConnectionsUIDelegate respondsToSelector:@selector(gsAddConnectionsUIDidFail:errorMessage:context:)])
			{
				[context.addConnectionsUIDelegate	gsAddConnectionsUIDidFail:pResponse.errorCode errorMessage:pResponse.errorMessage context:context.context];
			}	else 			if(context != nil && context.responseDelegate != nil &&	[context.responseDelegate respondsToSelector:@selector(gsDidReceiveResponse:response:context:)])
			{
				[context.responseDelegate	gsDidReceiveResponse:@"" response:pResponse context:context];
			}
		}
	}
}
-	(void)	onShowAddConnectionsUIClosed:(GSObject *)pParams response:(GSResponse *)pResponse context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(context != nil && context.addConnectionsUIDelegate != nil &&	[context.addConnectionsUIDelegate respondsToSelector:@selector(gsAddConnectionsUIDidClose:canceled:)])
	{
		[context.addConnectionsUIDelegate	gsAddConnectionsUIDidClose:context.context	canceled:((GSAPI_Internal	*)self.apiInternal).m_bCanceledByUser];
	}
}
-	(void)	onSendRequestCompleted:(NSString	*)pMethod Params:(GSObject		*)pParams	response:(GSResponse *)pResponse  context:(id)pContext
{
	GSContext	*context = (GSContext *)pContext;
	if(context == nil)
		context	=	[[[GSContext	alloc]init]autorelease];
	if(context != nil && context.responseDelegate != nil &&	[context.responseDelegate respondsToSelector:@selector(gsDidReceiveResponse:response:context:)])
	{
		[context.responseDelegate	gsDidReceiveResponse:pMethod response:pResponse context:context.context];
	}
	
}



@end

@implementation GSAPI

@synthesize	apiInternal;
@synthesize	eventDelegate;

// initialize the library with your apiKey and the main view
-(id) initWithAPIKey:(NSString*)apiKey viewController:(UIViewController*)mainViewController
{
	if ((self = [super init])) {
		GSAPI_Internal *pApiInternal	=	[[GSAPI_Internal alloc] initWithAPIKey:apiKey ViewController:mainViewController delegate:self];
		self.apiInternal	=	pApiInternal;
		[pApiInternal	release];
	}
	return self;
}

// login to a spcific provider
-(void) login:(GSObject*)params delegate:(id<GSResponseDelegate>)delegate context:(id)context
{
	if(params	==	nil)
		params	= [[[GSObject	alloc]init]autorelease];
	else 
		params	= [params	clone];
	[(GSAPI_Internal	*)self.apiInternal Login:params context:[GSContext contextWithGSResponseDelegate:delegate context:context]];
}

// logout
-(void) logout
{
	[(GSAPI_Internal	*)self.apiInternal Logout];
}

// add a connection to a provider
-(void) addConnection:(GSObject*)params delegate:(id<GSResponseDelegate>)delegate context:(id)context
{
	if(params	==	nil)
		params	= [[[GSObject	alloc]init]autorelease];
	else 
		params	= 	[params	clone];
	[(GSAPI_Internal	*)self.apiInternal AddConnection:params context:[GSContext contextWithGSResponseDelegate:delegate context:context]];
}

// remove an existing connection
-(void) removeConnection:(GSObject*)params delegate:(id<GSResponseDelegate>)delegate context:(id)context;
{
	if(params	==	nil)
		params	=	[[[GSObject	alloc]init]autorelease];
	else 
		params	=	[params	clone];
	[(GSAPI_Internal	*)self.apiInternal RemoveConnection:params context:[GSContext contextWithGSResponseDelegate:delegate context:context]];
}
// show provider slection UI for login
-(void) showLoginUI:(GSObject*)params delegate:(id<GSLoginUIDelegate>)delegate context:(id)context
{
	if(params	==	nil)
		params	=	[[[GSObject	alloc]init]autorelease];
	else 
		params	=	[params	clone];
	[(GSAPI_Internal	*)self.apiInternal ShowLoginUI:params context:[GSContext contextWithGSLoginUIDelegate:delegate context:context]];
}

// show provider slection UI for adding a connection
-(void) showAddConnectionsUI:(GSObject *)params delegate:(id<GSAddConnectionsUIDelegate>)delegate context:(id)context
{
	if(params	==	nil)
		params	=	[[[GSObject	alloc]init]autorelease];
	else 
		params	=	[params	clone];
	[(GSAPI_Internal	*)self.apiInternal ShowAddConnectionsUI:params context:[GSContext contextWithGSAddConnectionsUIDelegate:delegate context:context]];
}

// send a request (e.g. "getUserInfo", "getfriends", "publishUserAction" etc.)
-(void) sendRequest:(NSString*)method params:(GSObject*)params	useHTTPS:(BOOL)useHTTPS delegate:(id<GSResponseDelegate>)delegate context:(id)context
{
	if(params	==	nil)
		params	=	[[[GSObject	alloc]init]autorelease];
	else 
		params	=	[params	clone];
	[(GSAPI_Internal	*)self.apiInternal	SendRequest:method Params:params UseHTTPS:useHTTPS	context:[GSContext contextWithGSResponseDelegate:delegate context:context ]	trace:nil];
	
}
-(void) sendRequest:(NSString*)method params:(GSObject*)params delegate:(id<GSResponseDelegate>)delegate context:(id)context
{
	if(params	==	nil)
		params	=	[[[GSObject	alloc]init]autorelease];
	else 
		params	=	[params	clone];
	[(GSAPI_Internal	*)self.apiInternal	SendRequest:method Params:params UseHTTPS:NO	context:[GSContext contextWithGSResponseDelegate:delegate context:context]	trace:nil];
}

// get the current session. returns nil if session doesn't exist
-(GSSession *) getSession
{
	return [(GSAPI_Internal	*)self.apiInternal	GetSession];
}
-(void) setSession:(GSSession *)session
{
    [(GSAPI_Internal	*)self.apiInternal SetSession:session];
}


- (void)dealloc {
//	NSLog(@"dealloc - api internal retain count = %d" ,[self.apiInternal retainCount]);
	self.apiInternal	=	nil;
	[super dealloc];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
	GSAPI_Internal	*pInternal = (GSAPI_Internal	*)self.apiInternal;
	return	[pInternal	handleOpenURL:url];
}

@end
