//
//  GSSession.m
//	Version: 2.15.3


#import "GSSession.h"

#define GSAPI_PARAM_NAME_ACCESS_TOKEN			@"access_token"
#define GSAPI_PARAM_NAME_ACCESS_TOKEN_SECRET	@"x_access_token_secret"
#define GSAPI_PARAM_NAME_EXPIRES_IN				@"expires_in"

@implementation GSSession
@synthesize secret;
@synthesize accessToken;
@synthesize expirationTime;

-(id)initWithSessionToken:(NSString *)pToken sessionSecret:(NSString *)pSecret expirationTime:(NSDate *) pExpiration
{
    if ((self = [super init])) {
        self.accessToken = pToken;
        self.secret = pSecret;
        self.expirationTime = pExpiration;
    }
    return self;
}
-(id)initWithSessionToken:(NSString *)pToken sessionSecret:(NSString *)pSecret
{
    return [self initWithSessionToken:pToken sessionSecret:pSecret expirationTime:[NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0 * 24.0 * 30.0]];
}
-(id) initWithLoginResponse:(GSObject *)pResponse
{
	if ((self = [super init])) {
		self.accessToken	=	[pResponse getString:GSAPI_PARAM_NAME_ACCESS_TOKEN];
		self.secret	=	[pResponse getString:GSAPI_PARAM_NAME_ACCESS_TOKEN_SECRET];
		self.expirationTime	=	[NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0 * 24.0 * 30.0]; // one month by default
		if([pResponse getString:GSAPI_PARAM_NAME_EXPIRES_IN] != nil )
		{
			NSString	*pSecs = [pResponse getString:GSAPI_PARAM_NAME_EXPIRES_IN];
			int Secs = [pSecs intValue];
			if(Secs > 0)
			{   	
				self.expirationTime	=	[NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval)Secs];
			}
		}
		
	}
	return self;
	
}


- (void)dealloc {
	self.secret	=	nil;
	self.accessToken	=	nil;
	self.expirationTime	=	nil;
	[super dealloc];
}


-(BOOL) IsValid
{
	if(self.accessToken	==	nil)
		return NO;
	if(self.expirationTime	==	nil)
		return	NO;
	
	if([self.expirationTime timeIntervalSinceNow] <= 0)
		return NO;
	return YES;
}

@end
