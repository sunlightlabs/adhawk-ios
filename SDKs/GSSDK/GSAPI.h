//
//  GSAPI.h
//	Version: 2.15.3


#import <Foundation/Foundation.h>
#import	"GSResponse.h"
#import	"GSSession.h"

/*
 This delegate can be optionally passed to GSAPI (by setting gsapi.eventDelegate)
 if the developer wants to know when login/logout/connect/disconnect occurred.
 NOTE: all protocol messages are optional
 */
@protocol GSEventDelegate <NSObject>
//@optional
-(void)	gsDidLogin:(NSString*)provider user:(GSObject*)user context:(id)context;
-(void)	gsDidLogout;
-(void)	gsDidAddConnection:(NSString*)provider user:(GSObject*)user context:(id)context;
-(void)	gsDidRemoveConnection:(NSString*)provider context:(id)context;
@end

/*
 delegate for showConnectUI
 NOTE: all protocol messages are optional
 */
@protocol GSAddConnectionsUIDelegate	<NSObject>
@optional
// fired when network selection page is shown 
-(void)	gsAddConnectionsUIDidLoad:(id)context; 

// fired when the login UI is closed (for any reason - canceled, error , operation completed OK)
-(void)	gsAddConnectionsUIDidClose:(id)context	canceled:(BOOL)bCanceled; 

// fired when error occurred, either from webView or as result of login process, or get user info that followed it
-(void)	gsAddConnectionsUIDidFail:(int)errorCode errorMessage:(NSString*)errorMessage context:(id)context; 

// fired when add connection operation (and getuserInfo that folllows it) complete
-(void)	gsAddConnectionsUIDidConnect:(NSString*)provider user:(GSObject*)user context:(id)context;


@end

/*
 delegate for showLoginUI
 NOTE: all protocol messages are optional
 */
@protocol GSLoginUIDelegate <NSObject>
@optional
// fired when network selection page is shown 
-(void)	gsLoginUIDidLoad:(id)context;

// fired when the login UI is closed (for any reason - canceled, error , operation completed OK)
-(void)	gsLoginUIDidClose:(id)context	canceled:(BOOL)bCanceled;

// fired when error occurred, either from webView or as result of login process, or get user info that followed it
-(void)	gsLoginUIDidFail:(int)errorCode errorMessage:(NSString*)errorMessage context:(id)context;

// fired when login operation (and getuserInfo that folllows it) complete
-(void)	gsLoginUIDidLogin:(NSString*)provider user:(GSObject*)user context:(id)context;
@end

/*
 delegate for any non-ui operation:
 login, addConnection, removeConnection, sendRequest
 NOTE: all protocol messages are optional
 */
@protocol GSResponseDelegate <NSObject>
- (void) gsDidReceiveResponse:(NSString*)method response:(GSResponse*)response context:(id)context;
@end


@interface GSAPI : NSObject  {
	@private
	id	apiInternal;
	@public
	id<GSEventDelegate>	eventDelegate;
}
@property (nonatomic, retain) 	id	apiInternal;
@property (nonatomic, assign) 	id<GSEventDelegate>	eventDelegate;

// initialize the library with your apiKey and the main view
-(id) initWithAPIKey:(NSString*)apiKey viewController:(UIViewController*)mainViewController; 

// login to a spcific provider
-(void) login:(GSObject*)params delegate:(id<GSResponseDelegate>)delegate context:(id)context;

// logout
-(void) logout;

// add a connection to a provider
-(void) addConnection:(GSObject*)params delegate:(id<GSResponseDelegate>)delegate context:(id)context;

// remove an existing connection
-(void) removeConnection:(GSObject*)params delegate:(id<GSResponseDelegate>)delegate context:(id)context;

// show provider slection UI for login
-(void) showLoginUI:(GSObject*)params delegate:(id<GSLoginUIDelegate>)delegate context:(id)context;

// show provider slection UI for adding a connection
-(void) showAddConnectionsUI:(GSObject *)params delegate:(id<GSAddConnectionsUIDelegate>)delegate context:(id)context;

// send a request (e.g. "getUserInfo", "getfriends", "publishUserAction" etc.)
-(void) sendRequest:(NSString*)method params:(GSObject*)params	useHTTPS:(BOOL)useHTTPS delegate:(id<GSResponseDelegate>)delegate context:(id)context;
-(void) sendRequest:(NSString*)method params:(GSObject*)params delegate:(id<GSResponseDelegate>)delegate context:(id)context;

// get the current session. returns nil if session doesn't exist
-(GSSession *) getSession;
- (void) setSession:(GSSession*)session;
- (BOOL)handleOpenURL:(NSURL *)url;

@end








