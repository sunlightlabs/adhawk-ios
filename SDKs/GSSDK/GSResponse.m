//
//  GSResponse.m
//	Version: 2.15.3


#import "GSResponse.h"


@implementation GSResponse

@synthesize	errorCode;
@synthesize	errorMessage;
@synthesize data;
@synthesize	ResponseText;
@synthesize	m_pTrace;


- (id) initWithResponseData:(GSObject	*)pData	trace:(GSLogger	*)pTrace
{
	if ((self = [super init])) {
		self.errorCode	=	0;
		self.data	=	pData;
		if(pTrace)
			self.m_pTrace	=	[pTrace clone];
		else 
			self.m_pTrace	=	[[[GSLogger alloc]	init]	autorelease];
		[self.m_pTrace addKey:@"response" value:pData];
	}
	return self;
	
}


- (id) initWithResponseText:(NSString	*)pResponseText	trace:(GSLogger	*)pTrace
{
	if ((self = [super init])) 
	{
		self.errorCode	=	0;
		self.ResponseText	=	pResponseText;
		NSRange	Range = [pResponseText rangeOfString:@"{"];
		if(Range.location		==	0){
			
			GSObject	*pDict	=	[GSObject objectWithJSONString:pResponseText];
			NSString	*pErrorCode	=	[pDict	getString:@"errorCode"];
			NSString	*pErrorMessage =	[pDict	getString:@"errorMessage"];
			self.errorCode	=	[pErrorCode	intValue];
			self.errorMessage	=	pErrorMessage;
			self.data	=	pDict;
			
		}	else {
			self.errorCode	=		[[self getStringBetween:pResponseText start:@"<errorCode>" end:@"</errorCode>"]	intValue];
			self.errorMessage	=		[self getStringBetween:pResponseText start:@"<errorMessage>" end:@"</errorMessage>"];
		}
		if(pTrace)
			self.m_pTrace	=	[pTrace clone];
		else 
			self.m_pTrace	=	[[[GSLogger alloc]	init]	autorelease];
		
		[self.m_pTrace addKey:@"response" value:self.ResponseText];
		
	}
	return self;
	
}


- (id) initWithError:(int)Error	format:(NSString	*)pFormat	method:(NSString		*)pMethod	trace:(GSLogger	*)pTrace
{
	if ((self = [super init])) {
		self.errorCode	=	Error;
		self.errorMessage	=	[self getErrorMessage:Error];
		self.ResponseText	=	[self getErrorResponseText:Error ErrorMessage:self.errorMessage format:pFormat method:pMethod];
		if(pTrace)
			self.m_pTrace	=	[pTrace clone];
		else 
			self.m_pTrace	=	[[[GSLogger alloc]	init]	autorelease];
		[self.m_pTrace addKey:@"apiMethod" value:pMethod];
		[self.m_pTrace addKey:@"response" value:self.ResponseText];
		
	}
	return self;
	
}

- (id) initWithError:(int)Error ErrorMessage:(NSString *)pMsg	format:(NSString	*)pFormat	method:(NSString		*)pMethod	trace:(GSLogger	*)pTrace
{
	if ((self = [super init])) {
		self.errorCode	=	Error;
		self.errorMessage	=	pMsg;
		self.ResponseText	=	[self getErrorResponseText:Error ErrorMessage:pMsg format:pFormat method:pMethod];
		if(pTrace)
			self.m_pTrace	=	[pTrace clone];
		else 
			self.m_pTrace	=	[[[GSLogger alloc]	init]	autorelease];
		[self.m_pTrace addKey:@"apiMethod" value:pMethod];
		[self.m_pTrace addKey:@"response" value:self.ResponseText];
	}
	return self;
	
}

-	(NSString	*)	getStringBetween:(NSString	*)pSource start:(NSString	*)pStart	end:(NSString	*)pEnd
{
	NSRange	startRange	=	[pSource rangeOfString:pStart];
	NSRange	endRange	=	[pSource rangeOfString:pEnd];
	
	if(startRange.location	!=	NSNotFound	&&	endRange.location	!=	NSNotFound	&&	endRange.location	>	startRange.location	+	startRange.length)
	{
		NSRange		Range;
		Range.location	=	startRange.location+startRange.length;
		Range.length	=	endRange.location	-	Range.location;
		return	[pSource	substringWithRange:Range];
	}
	return	nil;
	
}

-	(NSString	*)	getErrorResponseText:(int)Error ErrorMessage:(NSString *)pMsg	format:(NSString	*)pFormat	method:(NSString		*)pMethod
{
	if (pMsg==nil || [pMsg	length]	==	0)
		pMsg =	[self getErrorMessage:Error];
	
	if(pFormat	==	nil)
		pFormat	=	@"json";

	if ([pFormat		compare:@"json"]	==	NSOrderedSame)
	{
		return	[NSString		stringWithFormat:@"{errorCode:%d,errorMessage:\"%@\"}",Error,pMsg];
	}
	else
	{
		return [NSString	stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
		"<%@Response xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"urn:com:gigya:api http://socialize-api.gigya.com/schema\" xmlns=\"urn:com:gigya:api\">"
		"<errorCode>%d</errorCode>"
		"<errorMessage>%@</errorMessager>"
						"</%@Response>",pMethod,Error,pMsg,pMethod];
	}
	
}

-	(NSString	*)	getErrorMessage:(int)Error
{
	switch (Error) {
		case	GSErrorCode_MissingArgument	:
			return	@"Required parameter is missing";
			break;
		case	GSErrorCode_HTTPFailure	:
			return	@"No Internet Connection";
			break;
		case	GSErrorCode_InvalidSession	:
			return	@"Invalid or missing session";
			break;
		case	GSErrorCode_CanceledByUser	:
			return	@"Canceled by user";
			break;
	}
	return	@"Unspecified Error";
}


- (void)dealloc {
	self.errorMessage	=	nil;
	self.data	=	nil;
	self.ResponseText	=	nil;
	self.m_pTrace	=	nil;
	[super dealloc];
}

-	(NSString	*)getLog
{
	return [self.m_pTrace	getLog];
}


- (int)		getInt:(NSString *)key
{
	return [self.data getInt:key];
}
- (int)		getInt:(NSString *)key defaultValue:(int)value
{
	return [self.data getInt:key defaultValue:value];
}

- (long)	getLong:(NSString *)key
{
	return [self.data getLong:key];
}
- (long)	getLong:(NSString *)key defaultValue:(long)value
{
	return [self.data getLong:key defaultValue:value];
}

- (bool)	getBool:(NSString *)key
{
	return [self.data getBool:key];
}

- (bool)	getBool:(NSString *)key defaultValue:(bool)value
{
	return [self.data getBool:key defaultValue:value];
}

- (NSString *)	getString:(NSString *)key
{
	return [self.data getString:key ];
}

- (NSString *)	getString:(NSString *)key defaultValue:(NSString *)value
{
	return [self.data getString:key defaultValue:value];
}


- (GSObject *)	getObject:(NSString *)key
{
	return [self.data getObject:key];
}

- (NSArray *)	getArray:(NSString *)key //array of GSObject
{
	return [self.data getArray:key];
}

- (NSArray *)	getKeys
{
	return [self.data getKeys];
}



@end
