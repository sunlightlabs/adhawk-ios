//
//  GSResponse.h
//	Version: 2.15.3


#import <Foundation/Foundation.h>
#import "GSObject.h"
#import "GSLogger.h"

/* local error codes. other error codes are returned from the server */
typedef enum GSErrorCode
{
	GSErrorCode_CanceledByUser = 200001,
	GSErrorCode_MissingArgument = 400002,
	GSErrorCode_HTTPFailure = 500026,
	GSErrorCode_InvalidSession = 403000
	
} GSErrorCode;

@interface GSResponse : NSObject
{
	@private
	NSString		*errorMessage; // error message
	int				errorCode; // error code should be 0 on success
	NSString		*ResponseText; // raw response text	
	GSObject	*data; // response data
	GSLogger	*m_pTrace;
}

@property (nonatomic)			int				errorCode;
@property (nonatomic, retain) 	NSString		*errorMessage;
@property (nonatomic, retain) 	GSObject	*data;
@property (nonatomic, retain) 	NSString		*ResponseText;
@property (nonatomic, retain) 	GSLogger	*m_pTrace;

/* get value by key*/
- (int)		getInt:(NSString *)key;
- (int)		getInt:(NSString *)key defaultValue:(int)value;

- (long)	getLong:(NSString *)key;
- (long)	getLong:(NSString *)key defaultValue:(long)value;

- (bool)	getBool:(NSString *)key;
- (bool)	getBool:(NSString *)key defaultValue:(bool)value;


- (NSString *)	getString:(NSString *)key;
- (NSString *)	getString:(NSString *)key defaultValue:(NSString *)value;

- (GSObject *)	getObject:(NSString *)key;
- (NSArray *)	getArray:(NSString *)key; //array of GSObject
- (NSArray *)	getKeys;

-	(NSString	*)getLog;
@end

@interface GSResponse (Private_Internal)
- (id) initWithResponseData:(GSObject	*)pResponseData trace:(GSLogger	*)pTrace;
- (id) initWithResponseText:(NSString	*)pResponseText	trace:(GSLogger	*)pTrace;
- (id) initWithError:(int)Error	format:(NSString	*)pFormat	method:(NSString		*)pMethod	trace:(GSLogger	*)pTrace;
- (id) initWithError:(int)Error ErrorMessage:(NSString *)pMsg	format:(NSString	*)pFormat	method:(NSString		*)pMethod	trace:(GSLogger	*)pTrace;
-	(NSString	*)	getStringBetween:(NSString	*)pSource start:(NSString	*)pStart	end:(NSString	*)pEnd;
-	(NSString	*)	getErrorResponseText:(int)Error ErrorMessage:(NSString *)pMsg	format:(NSString	*)pFormat	method:(NSString		*)pMethod;
-	(NSString	*)	getErrorMessage:(int)Error;
@end







