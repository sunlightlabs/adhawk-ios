//
//  GSRequest.h
//	Version: 2.15.3


#import <Foundation/Foundation.h>
#import "GSAPI_Internal.h"
#import	"GSResponse.h"


@interface GSRequest : NSObject {

	NSString *m_pSessionToken;
	NSString *m_pSecretKey;
	NSString *m_pMethod;
	GSObject	*m_pRequestParams;
	BOOL m_bUseHTTPS;
	NSString *m_pNotificationMessage;
	id	m_pSavedContext;
	NSString	*m_pDomain;
	NSString	*m_pPath;
	NSMutableData	*m_pResponseData;
	GSLogger	*m_pTrace;
	NSString	*m_pServerTime;
	id <GSRequestServerTimestampSkewDelegate> m_pServerTimestampSkewDelegate;
	BOOL	m_bError_403002_Retried;
	
}
@property (nonatomic, retain) NSString *m_pSessionToken;
@property (nonatomic, retain) NSString *m_pSecretKey;
@property (nonatomic, retain) NSString *m_pMethod;
@property (nonatomic, retain) GSObject	*m_pRequestParams;
@property (nonatomic) BOOL m_bUseHTTPS;
@property (nonatomic, retain) NSString *m_pNotificationMessage;
@property (nonatomic, retain) NSString	*m_pDomain;
@property (nonatomic, retain) NSString	*m_pPath;
@property (nonatomic, retain) NSMutableData	*m_pResponseData;
@property (nonatomic, retain) id	m_pSavedContext;
@property (nonatomic, retain) GSLogger	*m_pTrace;
@property (nonatomic, retain) NSString	*m_pServerTime;
@property (nonatomic, assign) id <GSRequestServerTimestampSkewDelegate> m_pServerTimestampSkewDelegate;
@property (nonatomic) BOOL	m_bError_403002_Retried;



//+(NSString	*)BuildQueryString:(NSDictionary	*)pParams;
+(NSString	*)URLEncode:(NSString	*)pSource;
+(NSArray *) BuildUnreservedCharsArray;
-	(id) initWithSessionToken:(NSString *)pSessionToken SecretKey:(NSString *)pSecretKey APIMethod:(NSString *)pMethod SendParams:(GSObject	*)pParams UseHTTPS:(BOOL)bUseHTTPS NotificationMessage:(NSString *)pNotificationMessage trace:(GSLogger	*)pTrace serverTimestampSkewDelegate:(id <GSRequestServerTimestampSkewDelegate>) pServerTimestampSkewDelegate;
-	(void)	SendNotification:(GSResponse *)pResponse;
-	(void)	SendErrorNotification:(GSErrorCode)Error;
-	(void) SendRequest:(id)pContext;
- (NSData *)FromBase64:(NSString *)pBase64String;
- (NSString *)ToBase64:(NSData *)pBase64Data;
- (NSString	*)GetOAuth1Signature:(NSData *)pSecretKey HTTPMethod:(NSString *)pMethod ResourceURI:(NSString *)pUri IsSecureConnection:(BOOL)bSecured RequestParams:(GSObject	*)pRequestParams;
- (NSString	*)CalcOAuth1BaseString:(NSString *)pMethod ResourceURI:(NSString *)pUri IsSecureConnection:(BOOL)bSecured RequestParams:(GSObject	*)pRequestParams;
-	(NSString *)	CalcSignature:(NSString *)pAlgorithm Data:(NSString *)pData SecretKey:(NSData *)pSecretKey;


@end
