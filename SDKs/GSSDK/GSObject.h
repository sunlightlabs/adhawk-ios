//
//  GSObject.h
//	Version: 2.15.3


#import <Foundation/Foundation.h>


@interface GSObject : NSObject {

	NSMutableDictionary *m_pDict;
	
}

@property (nonatomic, retain) NSMutableDictionary *m_pDict;

/* PUBLIC */
/* build GSObject from JSON string*/
+ (id)		objectWithJSONString:(NSString *)pJSONString;

/* put a key,value pair in the dictionary. supported types: GSObject, NSArray of GSObject, NSSring, int, long and bool */
- (void)	putGSObjectValue:(GSObject	*)pValue	forKey:(NSString *)pKey ;
- (void)	putNSArrayValue:(NSArray	*)pValue	forKey:(NSString *)pKey; //array of GSObject
- (void)	putStringValue:(NSString	*)pValue	forKey:(NSString *)pKey;
- (void)	putIntValue:(int)Value	forKey:(NSString *)pKey;
- (void)	putLongValue:(long)Value	forKey:(NSString *)pKey;
- (void)	putBoolValue:(bool)Value	forKey:(NSString *)pKey;
- (void)	putDoubleValue:(double)Value	forKey:(NSString *)pKey;

/* get value by key*/
- (int)		getInt:(NSString *)key;
- (int)		getInt:(NSString *)key defaultValue:(int)value;

- (long)	getLong:(NSString *)key;
- (long)	getLong:(NSString *)key defaultValue:(long)value;

- (bool)	getBool:(NSString *)key;
- (bool)	getBool:(NSString *)key defaultValue:(bool)value;

- (double)	getDouble:(NSString *)key;
- (double)	getDouble:(NSString *)key defaultValue:(double)value;


- (NSString *)	getString:(NSString *)key;
- (NSString *)	getString:(NSString *)key defaultValue:(NSString *)value;

- (GSObject *)	getObject:(NSString *)key;
- (NSArray *)	getArray:(NSString *)key; //array of GSObject
-	(id)	clone;
- (void) remove:(NSString		*)key;
- (bool) contains:(NSString		*)key;
- (void) clear;
- (NSArray *)	getKeys;
- (NSString *)	stringValue; // returns json representation of the dictionary
- (int) count;

/* PRIVATE (USED INTERNALLY) */

/* build GSObject from url (containing a query string) */
+ (id)		objectWithURL:(NSString *)pURL;
/* get dictionary values as query string */
- (NSString	*)toQueryString;
/* convert GSObject to NSDictionary*/
- (NSDictionary *) toNSDictionary;
-	(void) parseQueryString:(NSString	*)pQueryString;

@end

@interface NSString (NSString_GSObject)
-	(id) stringValue;
@end


