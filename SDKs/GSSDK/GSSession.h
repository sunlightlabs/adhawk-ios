//
//  GSSession.h
//	Version: 2.15.3


#import <Foundation/Foundation.h>
#import "GSObject.h"

@interface GSSession : NSObject {

	NSString	*secret;
	NSString	*accessToken;
	NSDate		*expirationTime;
	
}
@property (nonatomic, retain) NSString	*secret;
@property (nonatomic, retain) NSString	*accessToken;
@property (nonatomic, retain) NSDate	*expirationTime;
-(BOOL) IsValid;
@end



@interface GSSession (Private_Internal)
-(id) initWithLoginResponse:(GSObject *)pResponse;
-(id) initWithSessionToken:(NSString *)pToken sessionSecret:(NSString*)pSecret expirationTime:(NSDate*)pExpiration;
-(id) initWithSessionToken:(NSString *)pToken sessionSecret:(NSString*)pSecret;

@end
