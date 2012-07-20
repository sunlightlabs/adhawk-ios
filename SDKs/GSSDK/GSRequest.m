//
//  GSRequest.m
//	Version: 2.15.3


#import "GSRequest.h"
#import <CommonCrypto/CommonHMAC.h>
#import	"JSON.h"

static NSString *pUnreservedCharsString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.~";
static NSArray *pUnreservedCharsArray = nil;
static	const   char	*Base64Chars	=	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/0=";
static	unsigned char	Base64Inverted[128];



@implementation GSRequest





@synthesize	m_pSessionToken;
@synthesize	m_pSecretKey;
@synthesize	m_pMethod;
@synthesize	m_pRequestParams;
@synthesize	m_bUseHTTPS;
@synthesize	m_pNotificationMessage;
@synthesize	m_pDomain;
@synthesize	m_pPath;
@synthesize	m_pResponseData;
@synthesize	m_pSavedContext;
@synthesize	m_pTrace;
@synthesize	m_pServerTime;
@synthesize	m_pServerTimestampSkewDelegate;
@synthesize	m_bError_403002_Retried;

/*
 - (id)init
 {
 if ((self = [super init])) {
 }
 return self;
 }
 */
-	(id) initWithSessionToken:(NSString *)pSessionToken 
									SecretKey:(NSString *)pSecretKey 
									APIMethod:(NSString *)pMethod 
								 SendParams:(GSObject	*)pParams 
									 UseHTTPS:(BOOL)bUseHTTPS  
				NotificationMessage:(NSString *)pNotificationMessage 
											trace:(GSLogger	*)pTrace
serverTimestampSkewDelegate:(id <GSRequestServerTimestampSkewDelegate>) pServerTimestampSkewDelegate
{
	if ((self = [super init])) {
		self.m_pServerTimestampSkewDelegate	=	pServerTimestampSkewDelegate;
		self.m_pSessionToken = pSessionToken;
		self.m_pSecretKey = pSecretKey;
		self.m_pRequestParams	=	pParams;
		self.m_pMethod = pMethod;
		self.m_bUseHTTPS = bUseHTTPS;
		self.m_pNotificationMessage = pNotificationMessage;
		if(pTrace	!=	nil)
			self.m_pTrace	=	[pTrace	clone];
		else 
			self.m_pTrace	=	[[[GSLogger	alloc]	init]	autorelease];
		
		[self.m_pTrace	addKey:@"apiMethod" value:pMethod];
		[self.m_pTrace	addKey:@"clientParams" value:pParams];
		[self.m_pTrace	addKey:@"useHTTPS" boolValue:bUseHTTPS];
		
		
		if (self.m_pMethod	!=	nil && [self.m_pMethod length]	>	0)
		{
			
			if([self.m_pMethod rangeOfString:@"/"].location == 0)
				self.m_pMethod = [self.m_pMethod substringFromIndex:1];
			
			if([self.m_pMethod rangeOfString:@"."].location == NSNotFound)
			{
				self.m_pDomain = @"socialize.gigya.com";
				self.m_pPath =	[NSString stringWithFormat:@"/socialize.%@",self.m_pMethod];
			} else
			{
				NSArray	*pArray = [self.m_pMethod componentsSeparatedByString:@"."];
				self.m_pDomain =	[NSString stringWithFormat:@"%@.gigya.com",[pArray objectAtIndex:0]];
				self.m_pPath =	[NSString stringWithFormat:@"/%@",self.m_pMethod];
			}
		}
		if (self.m_pRequestParams	==	nil)
			self.m_pRequestParams	=	[[[GSObject alloc] init]	autorelease];
	}
	return self;
}


+(NSArray *) BuildUnreservedCharsArray
{
	NSMutableArray *pArray = [[NSMutableArray alloc] initWithCapacity:[pUnreservedCharsString length]];
	for (int I = 0; I < [pUnreservedCharsString length]; I++ )
	{
		NSString	*pChar = [pUnreservedCharsString substringWithRange:NSMakeRange(I,1)];
		[pArray addObject:pChar];
	}
	NSArray	*pRetVal	=	[pArray sortedArrayUsingSelector:@selector(compare:)];
	[pArray	release];
	return	pRetVal;
}


- (void)dealloc {
	self.m_pSessionToken	=	nil;
	self.m_pSecretKey	=	nil;
	self.m_pMethod	=	nil;
	self.m_pRequestParams	=	nil;
	self.m_pNotificationMessage	=	nil;
	self.m_pDomain	=	nil;
	self.m_pPath	=	nil;
	self.m_pResponseData	=	nil;
	self.m_pSavedContext	=	nil;
	self.m_pTrace	=	nil;
	self.m_pServerTime	=	nil;
	self.m_pServerTimestampSkewDelegate	=	nil;
	[super dealloc];
}

+(NSString	*)URLEncode:(NSString	*)pSource
{
	if(pUnreservedCharsArray	==	nil)
	{
		pUnreservedCharsArray	=	[[GSRequest BuildUnreservedCharsArray]	retain];
	}
	NSString	*pRetVal	=	@"";
	for(int I=0;I<[pSource length];I++)
	{
		NSString	*pChar = [pSource substringWithRange:NSMakeRange(I,1)];
		if([pUnreservedCharsArray indexOfObject:pChar] != NSNotFound)
		{
			pRetVal	=	[pRetVal	stringByAppendingFormat:@"%@",pChar];
		}	else {
			NSData *pData = [pChar	dataUsingEncoding:NSUTF8StringEncoding];
			for(int J=0;J<[pData length];J++)								 
			{
				pRetVal	=	[pRetVal	stringByAppendingFormat:@"%%%02X",((unsigned char *)[pData bytes])[J]];
			}
		}
	}
	return pRetVal;
}
/*
 +(NSString	*)BuildQueryString:(NSDictionary	*)pParams
 {
 NSString	*pRetVal	=	@"";
 
 NSArray *pSortedKeys = [[pParams allKeys] sortedArrayUsingSelector:@selector(compare:)];
 for(NSString *pKey in pSortedKeys)
 {
 if([pParams objectForKey:pKey] != nil)
 {
 if([pRetVal	length]	>	0)
 pRetVal	=	[pRetVal	stringByAppendingFormat:@"&%@=%@",pKey,[GSRequest URLEncode:[[pParams objectForKey:pKey] stringValue] ]];
 else 
 pRetVal	=	[pRetVal	stringByAppendingFormat:@"%@=%@",pKey,[GSRequest URLEncode:[[pParams objectForKey:pKey] stringValue]]];
 
 }
 }
 
 return pRetVal;
 }
 */
-	(void)	SendNotification:(GSResponse *)pResponse
{
	if(self.m_pNotificationMessage	!=	nil)
	{
		NSMutableDictionary	*pDict = [[[NSMutableDictionary alloc] init] autorelease];
		if(self.m_pRequestParams != nil)
			[pDict	setObject:self.m_pRequestParams forKey:GSAPI_PARAM_NAME_REQUEST_PARAMS_DICTIONARY];
		if(pResponse != nil)
			[pDict	setObject:pResponse forKey:GSAPI_PARAM_NAME_GSRESPONSE];
		if(self.m_pMethod	!=	nil)
			[pDict	setObject:self.m_pMethod forKey:GSAPI_PARAM_NAME_SEND_REQUEST_METHOD];
		if(self.m_pSavedContext)
			[pDict	setObject:self.m_pSavedContext forKey:GSAPI_PARAM_NAME_CONEXT];
		
		NSNotification *pNotification = [NSNotification notificationWithName:self.m_pNotificationMessage object:self userInfo:pDict];
		
		[[NSNotificationQueue defaultQueue] enqueueNotification:pNotification postingStyle:NSPostWhenIdle];
	}
}

-	(void)	SendErrorNotification:(GSErrorCode)Error
{
	GSResponse	*pResponse = [[[GSResponse alloc] initWithError:Error format:[self.m_pRequestParams getString:@"format" defaultValue:@"json"] method:self.m_pMethod trace:self.m_pTrace] autorelease];
	[self SendNotification:pResponse];
}





#ifdef	USE_OLD_SEND_REQUEST
-	(void) SendRequest:(id)pContext serverTimestampSkew:(long) skew
{
	self.m_pSavedContext	=	pContext;
	
	if (self.m_pMethod==nil || [self.m_pMethod length]	==	0)
	{
		[self SendErrorNotification:GSErrorCode_InvalidAPIMethod];
		return;
	}
	
	NSString	*pUri = [NSString stringWithFormat:@"%@://%@%@",(self.m_bUseHTTPS ? @"https" : @"http"),self.m_pDomain,self.m_pPath];
	NSString	*pTimeStamp  = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]-skew];
	NSString	*pNonce  = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
	
	if ([self.m_pRequestParams getString:@"format"] == nil)
		[self.m_pRequestParams putStringValue:@"json" forKey:@"format"];
	[self.m_pRequestParams putStringValue:@"false" forKey:@"httpStatusCodes"];
	
	[self.m_pRequestParams	putStringValue:self.m_pSessionToken forKey:@"token"];
	[self.m_pRequestParams	putStringValue:pTimeStamp forKey:@"timestamp"];
	[self.m_pRequestParams	putStringValue:pNonce forKey:@"nonce"];
	
	NSString	*pSignature =	[self	GetOAuth1Signature:[self FromBase64:self.m_pSecretKey] HTTPMethod:@"POST" ResourceURI:pUri IsSecureConnection:NO RequestParams:self.m_pRequestParams];
	
	[self.m_pRequestParams	remove:@"token"];
	[self.m_pRequestParams	remove:@"timestamp"];
	[self.m_pRequestParams	remove:@"nonce"];
	
	NSString	*pAuthHeader = [NSString stringWithFormat:@"OAuth token=\"%@\", nonce=\"%@\", timestamp=\"%@\",signature=\"%@\", algorithm=\"oauth1\" ",self.m_pSessionToken,pNonce,pTimeStamp,pSignature];
	NSString	*pQueryString =	[self.m_pRequestParams	toQueryString];
	[self.m_pTrace	addKey:@"postData" value:pQueryString];
	[self.m_pTrace	addKey:@"URL" value:pUri];
	
	
	NSURL *pUrl = [NSURL URLWithString:pUri];
	NSMutableURLRequest *pReq = [NSMutableURLRequest requestWithURL:pUrl];
	[pReq setHTTPMethod:@"POST"];
	[pReq setValue:pAuthHeader forHTTPHeaderField:@"Authorization"];
	
	NSMutableData *pPostBody = [NSMutableData data];
	[pPostBody appendData:[pQueryString dataUsingEncoding:NSUTF8StringEncoding]];
	[pReq setHTTPBody:pPostBody];
	self.m_pResponseData = [NSMutableData data];
	[[NSURLConnection alloc] initWithRequest:pReq delegate:self];
}
#else


/*
 protected String sendRequest(
 String httpMethod,
 String domain, 
 String path,
 GSObject params,
 String token,
 String secret,
 boolean useHTTPS) throws Exception
 {
 long start = new Date().getTime();
 OutputStreamWriter wr = null;
 BufferedReader rd = null;
 StringBuilder res = new StringBuilder();
 try {
 {
 params.put("apiKey", token);
 
 if (useHTTPS)
 {
 params.put("secret", secret);
 } else
 {
 String timestamp = Long.toString((System.currentTimeMillis()/1000) + timestampOffsetSec);
 String nonce  = Long.toString(System.currentTimeMillis());
 
 
 params.put("timestamp", timestamp);
 params.put("nonce", nonce);
 
 String baseString = SigUtils.calcOAuth1BaseString(httpMethod, resourceURI, params);
 logger.write("baseString", baseString);
 String signature = SigUtils.getOAuth1Signature(baseString, secret);
 params.put("sig", signature);
 }
 }
 
 String data = buildQS(params);
 logger.write("postData",data);
 
 URL url = new URL(resourceURI);
 logger.write("URL",url);
 
 URLConnection conn = url.openConnection();
 
 conn.setDoOutput(true);
 ((HttpURLConnection)conn).setRequestMethod(httpMethod);
 
 wr = new OutputStreamWriter(conn.getOutputStream());
 wr.write(data); 
 wr.flush(); 
 
 rd = new BufferedReader(new InputStreamReader(conn.getInputStream(),"UTF-8"));
 String line; 
 
 while ((line = rd.readLine()) != null) { 
 res.append(line); 
 }
 logger.write("server",conn.getHeaderField("x-server"));
 // calc timestamp offset 
 String dateHeader = conn.getHeaderField("Date");
 if (dateHeader!=null)
 {
 SimpleDateFormat format = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss zzz");
 Date serverDate = format.parse(dateHeader);
 timestampOffsetSec = (serverDate.getTime() - System.currentTimeMillis())/1000;
 }
 wr.close(); 
 rd.close();
 long end = new Date().getTime();
 logger.write("Reqeust Duration",end-start);
 
 }
 catch(Exception ex) {
 logger.write(ex);
 throw ex;
 }
 finally {
 if (wr != null)
 try {
 wr.close();
 } catch (IOException e) {}
 if (rd != null)
 try {
 rd.close();
 } catch (IOException e) {}
 
 }
 return res.toString();
 }
 */



-	(void) SendRequest:(id)pContext
{
	self.m_pSavedContext	=	pContext;
	
	if (self.m_pMethod==nil || [self.m_pMethod length]	==	0)
	{
		[self SendErrorNotification:(GSErrorCode)GSErrorCode_InvalidAPIMethod];
		return;
	}
	long	skew	=	0;
	if(self.m_pServerTimestampSkewDelegate)
		skew	=	[self.m_pServerTimestampSkewDelegate	GetServerTimestampSkew];
	
	NSString	*pUri = [NSString stringWithFormat:@"%@://%@%@",(self.m_bUseHTTPS ? @"https" : @"http"),self.m_pDomain,self.m_pPath];
	NSString	*pTimeStamp  = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]-skew];
	NSString	*pNonce  = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
	
	[self.m_pRequestParams putStringValue:GSAPI_SDK_VERSION_STRING forKey:@"sdk"];
	
	if ([self.m_pRequestParams getString:@"format"] == nil)
		[self.m_pRequestParams putStringValue:@"json" forKey:@"format"];
	[self.m_pRequestParams putStringValue:@"false" forKey:@"httpStatusCodes"];
	[self.m_pRequestParams	putStringValue:self.m_pSessionToken forKey:@"apiKey"];
	
		if(!self.m_bUseHTTPS)
		{
			[self.m_pRequestParams	putStringValue:pTimeStamp forKey:@"timestamp"];
			[self.m_pRequestParams	putStringValue:pNonce forKey:@"nonce"];
			[self.m_pRequestParams	remove:@"sig"];
			if(self.m_pSecretKey)
			{
			NSString	*pSignature =	[self	GetOAuth1Signature:[self FromBase64:self.m_pSecretKey] HTTPMethod:@"POST" ResourceURI:pUri IsSecureConnection:NO RequestParams:self.m_pRequestParams];
			//		NSString	*pSignature =	[NSString stringWithFormat:@"%@gg",  [self	GetOAuth1Signature:[self FromBase64:self.m_pSecretKey] HTTPMethod:@"POST" ResourceURI:pUri IsSecureConnection:NO RequestParams:self.m_pRequestParams]];
			
			
			[self.m_pRequestParams	putStringValue:pSignature forKey:@"sig"];
			}
			
		}	else 	if(self.m_pSecretKey)
		{
			[self.m_pRequestParams	putStringValue:self.m_pSecretKey forKey:@"secret"];
		}
	NSString	*pQueryString =	[self.m_pRequestParams	toQueryString];
	[self.m_pTrace	addKey:@"postData" value:pQueryString];
	[self.m_pTrace	addKey:@"URL" value:pUri];
	
	
	NSURL *pUrl = [NSURL URLWithString:pUri];
	NSMutableURLRequest *pReq = [NSMutableURLRequest requestWithURL:pUrl];
	[pReq setHTTPMethod:@"POST"];
	
	NSMutableData *pPostBody = [NSMutableData data];
	[pPostBody appendData:[pQueryString dataUsingEncoding:NSUTF8StringEncoding]];
	[pReq setHTTPBody:pPostBody];
	self.m_pResponseData = [NSMutableData data];
	[[NSURLConnection alloc] initWithRequest:pReq delegate:self];
}
#endif

- (NSString	*)GetOAuth1Signature:(NSData *)pSecretKey HTTPMethod:(NSString *)pMethod ResourceURI:(NSString *)pUri IsSecureConnection:(BOOL)bSecured RequestParams:(GSObject	*)pRequestParams
{
	[self.m_pTrace	addKey:@"serverParams" value:pRequestParams];
	NSString	*pBasicString = [self CalcOAuth1BaseString:pMethod ResourceURI:pUri IsSecureConnection:bSecured RequestParams:pRequestParams];
	[self.m_pTrace	addKey:@"baseString" value:pBasicString];
	return [self CalcSignature:@"HmacSHA1" Data:pBasicString SecretKey:(NSData *)pSecretKey];
}

//private static String calcOAuth1BaseString(String httpMethod, String url, boolean isSecureConnection, GSObject requestParams) throws MalformedURLException, UnsupportedEncodingException 

- (NSString	*)CalcOAuth1BaseString:(NSString *)pMethod ResourceURI:(NSString *)pUri IsSecureConnection:(BOOL)bSecured RequestParams:(GSObject	*)pRequestParams
{
	
	// Normalize the URL per the OAuth requirements
	NSString	*pNormalizedURL;
	NSURL *pURL = [NSURL URLWithString:pUri];
	
	pNormalizedURL	= [[NSString stringWithFormat:@"%@://%@",	[pURL scheme],[pURL host]] lowercaseString] ;
	
	if(([[pURL scheme] caseInsensitiveCompare:@"http"] == NSOrderedSame	&&	[pURL port] != nil && [[pURL port] intValue] != 80)	||
		 ([[pURL scheme] caseInsensitiveCompare:@"https"] == NSOrderedSame	&&	[pURL port] != nil && [[pURL port] intValue] != 443))
		
	{
		pNormalizedURL	=	[pNormalizedURL stringByAppendingFormat:@":%d",[[pURL port] intValue] ];
	}
	
	pNormalizedURL	=	[pNormalizedURL stringByAppendingString:[pURL path]];
	
	NSString	*pQueryString = [pRequestParams toQueryString];
	
	// Construct the base string from the HTTP method, the URL and the parameters 
	return [NSString stringWithFormat:@"%@&%@&%@",[pMethod uppercaseString],[GSRequest URLEncode:pNormalizedURL],[GSRequest URLEncode:pQueryString]];
}	

//private static String calcSignature(String algo, String text, byte[] key) throws InvalidKeyException  
-	(NSString *)	CalcSignature:(NSString *)pAlgorithm Data:(NSString *)pData SecretKey:(NSData *)pSecretKey
{
	unsigned char Hash[CC_SHA1_DIGEST_LENGTH+1];
	NSData	*pBinaryData = [pData dataUsingEncoding:NSISOLatin1StringEncoding];
	CCHmac(kCCHmacAlgSHA1, pSecretKey.bytes, pSecretKey.length, pBinaryData.bytes, pBinaryData.length, Hash);
	
	NSData *pHash = [NSData dataWithBytes:Hash length:CC_SHA1_DIGEST_LENGTH];
	return [self ToBase64:pHash];
}		



//void	CBase64::ToBase64(byte_t	*pInData,int InLength,byte_t *pOutData,int &OutLength)
- (NSString *)ToBase64:(NSData *)pBase64Data;
{
	unsigned char *pInData = (unsigned char *)[pBase64Data bytes];
	int InLength = [pBase64Data length];
	int OutLength=0;
	unsigned char *pOutData = malloc(InLength*4);
	
	
	int	I=0;
	//	for(I=0;I<	((Length>>2)<<2);I	+=	3)
	for(I=0;I<	InLength-2;I	+=	3)
	{
		uint32_t	I32	=	(pInData[I]	<<	16)	+(pInData[I+1]	<<	8)	+	pInData[I+2];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	18)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	12)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	6)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	)	&	0x3f];
	}
	if(InLength-I	==	1)
	{
		uint32_t	I32	=	(pInData[I]	<<	16);
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	18)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	12)	&	0x3f];
		pOutData[OutLength++]	=	'=';
		pOutData[OutLength++]	=	'=';
	}	else		if(InLength-I	==	2)
	{
		uint32_t	I32	=	(pInData[I]	<<	16)	+(pInData[I+1]	<<	8);
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	18)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	12)	&	0x3f];
		pOutData[OutLength++]	=	Base64Chars[(I32	>>	6)	&	0x3f];
		pOutData[OutLength++]	=	'=';
	}
	pOutData[OutLength]	=	0;
	NSString *pRetVal = [[[NSString alloc] initWithBytes:pOutData length:OutLength encoding:NSUTF8StringEncoding] autorelease];
	free(pOutData);
	return pRetVal;
}
//void	CBase64::FromBase64(byte_t	*InData,int InLength,byte_t	*OutData,int	&OutDataLen)
- (NSData *)FromBase64:(NSString *)pBase64String
{
	unsigned char	*InData = (unsigned char	*)[pBase64String UTF8String];
	int InLength	=	[pBase64String length];
	unsigned char	*OutData	=	malloc(InLength);
	int OutDataLen=0;
	if(Base64Inverted['B']	!=	1)
	{
		for(int	I=0;I	< 64;I++)
		{
			Base64Inverted[Base64Chars[I]]	=	I;
		}
	}
	for(int	I=0;I	<	(int)InLength;I+=4)
	{
		if(InData[I+3]	!=	'=')
		{
			int	I32	=	(Base64Inverted[InData[I]]	<<	18)	+
			(Base64Inverted[InData[I+1]]	<<	12)	+
			(Base64Inverted[InData[I+2]]	<<	6)	+
			Base64Inverted[InData[I+3]];
			OutData[OutDataLen++]	=	(I32	>>	16)	&	0xff;
			OutData[OutDataLen++]	=	(I32	>>	8)	&	0xff;
			OutData[OutDataLen++]	=	(I32	)	&	0xff;
		}	else	if(InData[I+2]	!=	'=')
		{
			int	I32	=	(Base64Inverted[InData[I]]	<<	18)	+
			(Base64Inverted[InData[I+1]]	<<	12)	+
			(Base64Inverted[InData[I+2]]	<<	6);
			OutData[OutDataLen++]	=	(I32	>>	16)	&	0xff;
			OutData[OutDataLen++]	=	(I32	>>	8)	&	0xff;
		}	else
		{
			int	I32	=	(Base64Inverted[InData[I]]	<<	18)	+
			(Base64Inverted[InData[I+1]]	<<	12);
			OutData[OutDataLen++]	=	(I32	>>	16)	&	0xff;
		}
	}
	NSData *pRetVal = [NSData dataWithBytes:OutData length:OutDataLen];
	free(OutData);
	return pRetVal;
}



-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	int keysFound	=	0;
	[self.m_pResponseData setLength: 0];
	if([response isKindOfClass:[NSHTTPURLResponse class]])
	{
		NSHTTPURLResponse	*pResponse	=	(NSHTTPURLResponse	*)response;
		NSArray	*pKeys	=	[[pResponse allHeaderFields]	allKeys];
		for(NSString	*pKey	in pKeys)
		{
			if(keysFound	>=	2)
				break;
			if([pKey caseInsensitiveCompare:@"x-server"]	==	NSOrderedSame)
			{
				[self.m_pTrace	addKey:@"server" value:[[pResponse allHeaderFields] objectForKey:pKey]];
				keysFound++;				
			} else if([pKey caseInsensitiveCompare:@"date"]	==	NSOrderedSame)
			{
				self.m_pServerTime	=	[[pResponse allHeaderFields] objectForKey:pKey];
				keysFound++;
			}
		}
	}
	
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.m_pResponseData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self SendErrorNotification:GSErrorCode_HTTPFailure];
	[connection release];
}




-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	NSString *responseString = [[[NSString alloc] initWithData:self.m_pResponseData encoding:NSUTF8StringEncoding]autorelease];
	
	[connection release];
	GSResponse *pResponse = [[GSResponse alloc] initWithResponseText:responseString trace:self.m_pTrace];
	if(self.m_pServerTime	&&	self.m_pServerTimestampSkewDelegate)
		[self.m_pServerTimestampSkewDelegate	SetServerTimestampSkew:self.m_pServerTime];
	if(pResponse.errorCode		==	403002	&&	!self.m_bError_403002_Retried)
	{
		self.m_bError_403002_Retried	=	YES;
		[self SendRequest:self.m_pSavedContext];
	}	else {
		[self SendNotification:pResponse];
	}
	[pResponse release];
}




@end
