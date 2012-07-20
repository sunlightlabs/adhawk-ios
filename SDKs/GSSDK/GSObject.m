//
//  GSObject.m
//	Version: 2.15.3


#import "GSObject.h"
#import	"JSON.h"
#import	"GSRequest.h"

/*
 
 */

@interface GSObject (Private_Internal)

- (NSArray *) toArrayOfNSDictionary:(NSArray *)pGSObjectArray;
- (id) objectForKey:(NSString		*)pKey;
-	(void) parseURL:(NSString	*)pURLString;
- (void)	putNSDictionaryValue:(NSDictionary	*)pValue	forKey:(NSString *)pKey;

@end


@implementation GSObject	(Private_Internal)
- (NSArray *) toArrayOfNSDictionary:(NSArray *)pGSObjectArray
{
	NSMutableArray	*pArray		=	[NSMutableArray	arrayWithCapacity:[pGSObjectArray count]];
	for(int I=0;I< [pGSObjectArray count];I++)
	{
		id pEntry = [pGSObjectArray objectAtIndex:I];
		if([pEntry isKindOfClass:[GSObject class]])
		{
			[pArray addObject:[pEntry toNSDictionary]];
		} else if([pEntry isKindOfClass:[NSArray class]])
		{
			[pArray addObject:[self toArrayOfNSDictionary:pEntry]];
		}	else {
			[pArray addObject:pEntry];
		}
	}
	return pArray;		 
}
- (id) objectForKey:(NSString		*)pKey
{
	return [m_pDict objectForKey:pKey];
}
-	(void) parseURL:(NSString	*)pURLString
{
	NSURL *pURL = [NSURL URLWithString:pURLString];
	if(pURL == nil)
		@throw [NSException exceptionWithName:@"parseURL" reason:@"Invalid Value" userInfo:nil];
	
	[self parseQueryString:[pURL fragment]];
	[self parseQueryString:[pURL query]];
	
}

- (void)	putNSDictionaryValue:(NSDictionary	*)pDict	forKey:(NSString *)pDictKey 
{
	GSObject	*pGSDict;
	if(pDictKey	==	nil)
		pGSDict	=	self;
	else {
		pGSDict	=	[[[GSObject	alloc]init]autorelease];
		[self	putGSObjectValue:pGSDict forKey:pDictKey ];
	}
	
	
	for(NSString	*pKey	in [pDict allKeys])
	{
		id pValue = [pDict objectForKey:pKey];
		if([pValue isKindOfClass:[NSDictionary class]])
		{
			[pGSDict putNSDictionaryValue:(NSDictionary	*)pValue	forKey:pKey ];
		}	else if([pValue isKindOfClass:[GSObject class]])
		{
			[pGSDict putGSObjectValue:(GSObject	*)pValue	forKey:pKey ];
		}	else if([pValue isKindOfClass:[NSArray class]])
		{
			[pGSDict putNSArrayValue:(NSArray	*)pValue	forKey:pKey ];
		}	else {
			[pGSDict.m_pDict	setObject:pValue forKey:pKey];
		}
	}
}


@end

@implementation GSObject
@synthesize m_pDict;

- (id)init
{
	if ((self = [super init])) {
		self.m_pDict	=	[NSMutableDictionary	dictionary];
	}
	return self;
}


+	(id) objectWithJSONString:(NSString *)pJSONString
{
	NSDictionary	*pDict = [pJSONString JSONValue];
	if(pDict	==	nil)
		return nil;
	GSObject	*pNewDict	=	[[[GSObject	alloc]	init]	autorelease];
	[pNewDict	putNSDictionaryValue:pDict forKey:nil ];
	return pNewDict;
}

-	(id)	clone{
	NSString	*pJSON = [self stringValue];
	return [GSObject objectWithJSONString:pJSON];
}


- (void)	putGSObjectValue:(GSObject	*)pValue	forKey:(NSString *)pKey 
{
	[self.m_pDict	setObject:pValue forKey:pKey];
}

- (void)	putNSArrayValue:(NSArray	*)pNSArray	forKey:(NSString *)pKey 
{
	NSMutableArray	*pArray	=	[NSMutableArray	arrayWithCapacity:[pNSArray count]];
	[self.m_pDict setObject:pArray forKey:pKey];
	for(int I=0;I<[pNSArray count];I++)
	{
		id pValue = [pNSArray	objectAtIndex:I];
		if([pValue isKindOfClass:[NSDictionary class]])
		{
			GSObject	*pDict	=	[[[GSObject	alloc]init]autorelease];
			[pArray addObject:pDict];
			[pDict putNSDictionaryValue:pValue	forKey:nil ];
		}	else //if([pValue isKindOfClass:[GSObject class]])
		{
			[pArray addObject:/*(GSObject	*)*/pValue];
		}/* else
		{
			NSException	*pException = [NSException exceptionWithName:@"NSArray Exception" reason:@"Invalid Element Value" userInfo:nil];
			@throw pException;
		}*/
	}
}



- (void)	putStringValue:(NSString	*)pValue	forKey:(NSString *)pKey
{
	[self.m_pDict	setObject:pValue forKey:pKey];
}



- (void)	putIntValue:(int)Value	forKey:(NSString *)pKey
{
	[self.m_pDict	setObject:[NSNumber numberWithInt:Value] forKey:pKey];
}
- (void)	putLongValue:(long)Value	forKey:(NSString *)pKey
{
	[self.m_pDict	setObject:[NSNumber numberWithLong:Value] forKey:pKey];
}
- (void)	putBoolValue:(bool)Value	forKey:(NSString *)pKey
{
	[self.m_pDict	setObject:[NSNumber numberWithBool:Value] forKey:pKey];
}

- (int)	getInt:(NSString *)pKey
{
	id pRetVal =[self.m_pDict objectForKey:pKey];
	if(pRetVal == nil)
	{
		@throw [NSException exceptionWithName:@"getInt" reason:@"No Value" userInfo:nil];
	}
	else {
		if([pRetVal isKindOfClass:[NSNumber class]])
		{
			return [pRetVal intValue];
		}
		if([pRetVal isKindOfClass:[NSString class]])
		{
			
			return [[pRetVal stringValue] intValue];
		}
	}
	@throw [NSException exceptionWithName:@"getInt" reason:@"Invalid Value" userInfo:nil];
}

- (int)	getInt:(NSString *)pKey defaultValue:(int)Value
{
	@try {
		return [self getInt:pKey];
	}
	@catch (NSException * e) {
		return Value;
	}
}

- (long)	getLong:(NSString *)pKey
{
	id pRetVal =[self.m_pDict objectForKey:pKey];
	if(pRetVal == nil)
	{
		@throw [NSException exceptionWithName:@"getLong" reason:@"No Value" userInfo:nil];
	}
	else {
		if([pRetVal isKindOfClass:[NSNumber class]])
		{
			return [pRetVal intValue];
		}
		if([pRetVal isKindOfClass:[NSString class]])
		{
			return [[pRetVal stringValue] longLongValue];
		}
	}
	@throw [NSException exceptionWithName:@"getLong" reason:@"Invalid Value" userInfo:nil];
}
- (long)	getLong:(NSString *)pKey defaultValue:(long)Value
{
	@try {
		return [self getLong:pKey];
	}
	@catch (NSException * e) {
		return Value;
	}
}

- (bool)	getBool:(NSString *)pKey
{
	id pRetVal =[self.m_pDict objectForKey:pKey];
	if(pRetVal == nil)
	{
		@throw [NSException exceptionWithName:@"getBool" reason:@"No Value" userInfo:nil];
	}
	else {
		if([pRetVal isKindOfClass:[NSNumber class]])
			return [pRetVal boolValue];
		if([pRetVal isKindOfClass:[NSString class]])
			return [[pRetVal stringValue] caseInsensitiveCompare:@"true"] == NSOrderedSame;
	}
	@throw [NSException exceptionWithName:@"getBool" reason:@"Invalid Value" userInfo:nil];
}
- (bool)	getBool:(NSString *)pKey defaultValue:(bool)Value
{
	@try {
		return [self getBool:pKey];
	}
	@catch (NSException * e) {
		return Value;
	}
}

- (void)	putDoubleValue:(double)Value	forKey:(NSString *)pKey
{
	[self.m_pDict	setObject:[NSNumber numberWithDouble:Value] forKey:pKey];
}


- (double)	getDouble:(NSString *)pKey
{
	id pRetVal =[self.m_pDict objectForKey:pKey];
	if(pRetVal == nil)
	{
		@throw [NSException exceptionWithName:@"getDouble" reason:@"No Value" userInfo:nil];
	}
	else {
		if([pRetVal isKindOfClass:[NSNumber class]])
		{
			return [pRetVal doubleValue];
		}
		if([pRetVal isKindOfClass:[NSString class]])
		{
			
			return [[pRetVal stringValue] doubleValue];
		}
	}
	@throw [NSException exceptionWithName:@"getDouble" reason:@"Invalid Value" userInfo:nil];
	
}
- (double)	getDouble:(NSString *)pKey defaultValue:(double)value
{
	@try {
		return [self getDouble:pKey];
	}
	@catch (NSException * e) {
		return value;
	}
	
}



- (NSString	*)	getString:(NSString *)pKey
{
	id pRetVal =[self.m_pDict objectForKey:pKey];
	if(pRetVal == nil)
	{
		return nil;
	}	else {
		return [pRetVal stringValue];
	}
}
- (NSString	*)	getString:(NSString *)pKey defaultValue:(NSString	*)pValue
{
	NSString	*pRetVal	=	[self getString:pKey];
	if(pRetVal)
		return	pRetVal;
	return pValue;
}

- (GSObject	*)	getObject:(NSString *)pKey
{
	id pRetVal =[self.m_pDict objectForKey:pKey];
	if(pRetVal == nil)
	{
		@throw [NSException exceptionWithName:@"getObject" reason:@"No Value" userInfo:nil];
	}
	else {
		if([pRetVal isKindOfClass:[GSObject class]])
			return pRetVal;
	}
	@throw [NSException exceptionWithName:@"getObject" reason:@"Invalid Value" userInfo:nil];
}
- (NSArray	*)	getArray:(NSString *)pKey
{
	id pRetVal =[self.m_pDict objectForKey:pKey];
	if(pRetVal == nil)
	{
		@throw [NSException exceptionWithName:@"getArray" reason:@"No Value" userInfo:nil];
	}
	else {
		if([pRetVal isKindOfClass:[NSArray class]])
			return pRetVal;
	}
	@throw [NSException exceptionWithName:@"getArray" reason:@"Invalid Value" userInfo:nil];
}

+ (id) objectWithURL:(NSString *)pURLString
{
	GSObject	*pDict	=	[[[GSObject alloc]init]autorelease];
	@try {
		[pDict parseURL:pURLString];
		return pDict;
	}
	@catch (NSException * e) {
		return nil;
	}
}

- (void) remove:(NSString		*)pKey
{
	[self.m_pDict removeObjectForKey:pKey];
}
- (bool) contains:(NSString		*)pKey
{
	return [m_pDict objectForKey:pKey] != nil;
}


-	(void) clear
{
	self.m_pDict	=	[NSMutableDictionary dictionary];
}
-	(NSArray *)	getKeys
{
	return [[self.m_pDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
}
- (NSString *)	stringValue
{
	NSDictionary *pDict = [self toNSDictionary];
	return [pDict JSONRepresentation];
}

- (NSDictionary *) toNSDictionary
{
	NSMutableDictionary	*pDict = [NSMutableDictionary dictionaryWithCapacity:[self.m_pDict count]];
	for(NSString *pKey in [self.m_pDict allKeys])
	{
		id pValue = [self.m_pDict objectForKey:pKey];
		if(pValue != nil)
		{
			if([pValue isKindOfClass:[GSObject class]])
			{
				[pDict setObject:[pValue toNSDictionary] forKey:pKey];
			} else if ([pValue isKindOfClass:[NSArray class]]) {
				[pDict setObject:[self toArrayOfNSDictionary:pValue] forKey:pKey];
			}	else {
				[pDict setObject:pValue forKey:pKey];
			}
		}
	}
	return pDict;
}

- (int) count
{
	return [self.m_pDict count];
}

- (void)dealloc {
	self.m_pDict	=	nil;
	[super dealloc];
}


-(NSString	*)toQueryString
{
	NSString	*pRetVal	=	@"";
	
	NSArray *pSortedKeys = [[self.m_pDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
	for(NSString *pKey in pSortedKeys)
	{
		if([self.m_pDict objectForKey:pKey] != nil)
		{
			if([pRetVal	length]	>	0)
				pRetVal	=	[pRetVal	stringByAppendingFormat:@"&%@=%@",pKey,[GSRequest URLEncode:[[self.m_pDict objectForKey:pKey] stringValue] ]];
			else 
				pRetVal	=	[pRetVal	stringByAppendingFormat:@"%@=%@",pKey,[GSRequest URLEncode:[[self.m_pDict objectForKey:pKey] stringValue]]];
			
		}
	}
	
	return pRetVal;
}

-	(void) parseQueryString:(NSString	*)pQueryString
{
	NSArray	*pParams = [pQueryString componentsSeparatedByString:@"&"];
	for(NSString	*pParam in pParams)
	{
		NSArray	*pPair	=	[pParam	componentsSeparatedByString:@"="];
		if([pPair	count]	==	1)
		{
			[self.m_pDict	setObject:@"" forKey:[pPair	objectAtIndex:0]];
		}	else
		{
			NSString	*pValue = [[pPair	objectAtIndex:1] stringByReplacingOccurrencesOfString:@"+" withString:@" "]; 
			[self.m_pDict	setObject:[pValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[pPair	objectAtIndex:0]];
		}	
	}	
}


@end

@implementation NSString (NSString_GSObject)
-	(id) stringValue
{
	return self;
}

@end
