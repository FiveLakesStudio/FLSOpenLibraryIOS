//
// FLOKeychain.m
//
// MIT License (http://opensource.org/licenses/MIT)
//
// Copyright (c) 2013 Tod Cunningham and Five Lakes Studio, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
// NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  With __bridge          ARC won't interfear with the memory (it won't try to retain or release it)
//  With __bridge_transfer ARC will release/autorelease as needed as ownership will be transfered
//  With __bridge_retain   ARC will retain the object (+1 ref count) and then manage it from there!
//
//  Created by Tod Cunningham on 7/9/10.
//
#import "FLOKeychain.h"
#import <Security/Security.h>
#import "FLOUtil.h"


@implementation FLOKeychain

// If we use the simulator we just save the setting in the local cache (no keychain)
#if TARGET_IPHONE_SIMULATOR
#warning iPhone Keychain access not supported on the simulator
#endif



static NSString *gDefaultKeychainId = nil;




- (id)initWithKeychainID:(NSString *)keychainId
{
    if( keychainId.length == 0 )
    {
        assertTriggerNSLog( @"FLOKeychain id is invalid!" );
        return nil;
    }
    
	self = [self init];
	if( self != nil )
	{
		_objectCache = [[NSMutableDictionary alloc] init];
		_identifier  = keychainId;
	}
	
	return self;	
}




- (void)dealloc
{	
	[_objectCache removeAllObjects];
	_objectCache = nil;
}



+ (void)setDefaultKeychainId:(NSString *)keychainId
{
    if( gDefaultKeychainId.length > 0   &&  [gDefaultKeychainId compare:keychainId] != NSOrderedSame  )
        assertTriggerNSLog( @"FLOKeychain can't change keychain id" );
    else
        gDefaultKeychainId = keychainId;
}



+ (FLOKeychain *)defaultKeychain
{
	static FLOKeychain *gKeychain = nil;
	
    if( gDefaultKeychainId.length == 0 )
    {
        assertTriggerNSLog( @"FLOKeychain missing default keychain id, see setDefaultKeychainId." );
        return nil;
    }
    
	@synchronized( self )
	{
		if( gKeychain == nil )
		   gKeychain = [[FLOKeychain alloc] initWithKeychainID:gDefaultKeychainId];
	}
	
	return gKeychain;
}




- (NSString *)stringForKey:(NSString *)key
{
	NSData   *dataSaved = [self dataForKey:key];
	NSString *theString = nil;
	
	if( dataSaved != nil )
		theString = [[NSString alloc] initWithData:dataSaved encoding:NSUTF8StringEncoding];
	
	return theString;
}




- (void)setString:(NSString *)theString forKey:(NSString *)key
{		
	NSData *dataToSave = [theString dataUsingEncoding:NSUTF8StringEncoding];
	
	[self setData:dataToSave forKey:key];
}




- (bool)boolForKey:(NSString *)key
{
	NSData *boolData = [self dataForKey:key];
	bool    theBool  = NO;
	
	if( boolData  !=  nil  &&  sizeof(theBool) == [boolData length] )
	{
		bool *boolPtr = (bool *)[boolData bytes];
		
		theBool = *boolPtr;
	}
	
	return theBool;
}



- (void)setBool:(bool)theBool forKey:(NSString *)key
{
	NSData *data = [[NSData alloc] initWithBytes:&theBool length:sizeof(theBool)];
	
	[self setData:data forKey:key];
}




- (NSInteger)integerForKey:(NSString *)key
{
	NSData   *data   = [self dataForKey:key];
	NSInteger theInt = 0;
	
	if( data  !=  nil  &&  sizeof(theInt) == [data length] )
	{
		NSInteger *intPtr = (NSInteger *)[data bytes];
		
		theInt = *intPtr;
	}
	
	return theInt;
}



- (void)setInteger:(NSInteger)theInt forKey:(NSString *)key
{
	NSData *data = [[NSData alloc] initWithBytes:&theInt length:sizeof(theInt)];
	
	[self setData:data forKey:key];
}




- (NSDate *)dateForKey:(NSString *)key
{
	NSData   *data         = [self dataForKey:key];
	NSInteger timeInterval = 0;
	
	if( data  !=  nil  &&  sizeof(timeInterval) == [data length] )
	{
		NSInteger *timeIntervalPtr = (NSInteger *)[data bytes];
		
		timeInterval = *timeIntervalPtr;
		
		return [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
	}
	
	return nil;
}



- (void)setDate:(NSDate *)theDate forKey:(NSString *)key
{
	NSInteger timeInterval = [theDate timeIntervalSinceReferenceDate];
	NSData   *data = [[NSData alloc] initWithBytes:&timeInterval length:sizeof(timeInterval)];
	
	[self setData:data forKey:key];
}




- (NSData *)dataForKey:(NSString *)key
{
	if( key == nil )
		return( nil );
	
	NSData *dataSaved = [_objectCache objectForKey:key];
	
	if( dataSaved != nil )
		return dataSaved;

	#if !TARGET_IPHONE_SIMULATOR
		NSMutableDictionary *keychainQuery = [[NSMutableDictionary alloc] init];
		
		[keychainQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];	// Generic password type
		[keychainQuery setObject:_identifier forKey:(__bridge id)kSecAttrGeneric];                      // That has our identifier as a generic attribute
		[keychainQuery setObject:key forKey:(__bridge id)kSecAttrLabel];                                // Use this as our label
		[keychainQuery setObject:key forKey:(__bridge id)kSecAttrAccount];                              // Use this as the account	
		
		[keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];	// Limit results to 1
		[keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];		// Return the encoded data
		
		// Search...
		//      See http://stackoverflow.com/questions/7827730/iphone-fetch-data-dictionary-from-keychain
        //
        CFDictionaryRef cfquery  = (__bridge CFDictionaryRef)keychainQuery;
        CFDataRef       cfresult = NULL;
        OSStatus        error    = SecItemCopyMatching( cfquery, (CFTypeRef *)&cfresult );
        if( error == noErr )
            dataSaved = (__bridge_transfer NSData *)cfresult;
        else
            dataSaved = nil;    // Make sure this is nil if we get an error
		
		//if( error  ==  errSecItemNotFound )
		//	NSLog( @"FLOKeychain dataForKey not found for key %@", key );
		if( error != noErr  &&  error != errSecItemNotFound )
			NSLog( @"FLOKeychain dataForKey failed %ld", error );
		
        cfquery       = nil;
		keychainQuery = nil;
	
		// After reading a key, make sure it is added to our cache
		//
		if( dataSaved != nil )
			[_objectCache setObject:dataSaved forKey:key];
	#endif

	return [dataSaved copy];	
}




- (void)setData:(NSData *)dataToSave forKey:(NSString *)key
{
	if( key == nil  ||  dataToSave == nil )
		return;
    
	OSStatus error = noErr;
	
	#if !TARGET_IPHONE_SIMULATOR
		// If key already exists, then replace it
		if( [self keyExists:key] )
		{
			NSMutableDictionary *keychainQuery = [[NSMutableDictionary alloc] init];
			
			[keychainQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];	// Generic password type
			[keychainQuery setObject:_identifier forKey:(__bridge id)kSecAttrGeneric];                      // That has our identifier as a generic attribute
			[keychainQuery setObject:key forKey:(__bridge id)kSecAttrLabel];                                // Use this as our label		
			[keychainQuery setObject:key forKey:(__bridge id)kSecAttrAccount];                              // Use this as the account	
			
			NSMutableDictionary *attributesToUpdate = [[NSMutableDictionary alloc] init];
			
			[attributesToUpdate setObject:dataToSave forKey:(__bridge id)kSecValueData];
			
			error = SecItemUpdate( (__bridge CFDictionaryRef)keychainQuery, (__bridge CFDictionaryRef)attributesToUpdate );
			
			attributesToUpdate = nil;
			keychainQuery = nil;
		}
		else
		{
			NSMutableDictionary *keychainData     = [[NSMutableDictionary alloc] init];
			NSDictionary        *resultDictionary = nil;
			
			[keychainData setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];	// Generic password type
			[keychainData setObject:_identifier forKey:(__bridge id)kSecAttrGeneric];                       // That has our identifier as a generic attribute
			[keychainData setObject:key forKey:(__bridge id)kSecAttrLabel];                                 // Use this as our label	
			[keychainData setObject:key forKey:(__bridge id)kSecAttrAccount];                               // Use this as the account	
			
			[keychainData setObject:dataToSave forKey:(__bridge id)kSecValueData];
			[keychainData setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];	// Return CFDictionaryRef attributes
			
            CFDictionaryRef       cfresult = NULL;
			error = SecItemAdd( (__bridge CFDictionaryRef)keychainData, (CFTypeRef *)&cfresult );
            resultDictionary = (__bridge_transfer NSDictionary *)cfresult;
			
			//if( error == noErr )	// errSecDuplicateItem  means item already exists
			//	NSLog( @"Added item for key %@ with properties %@", key, resultDictionary );
			
			resultDictionary = nil;
			keychainData = nil;
		}
	#endif
	
	if( error == noErr )
		[_objectCache setObject:dataToSave forKey:key];
	else
		NSLog( @"FLOKeychain setString for key %@ failed %ld", key, error );	
}





- (bool)keyExists:(NSString *)key
{
	bool foundKey  = NO;

	if( key == nil )
		return NO;

	#if TARGET_IPHONE_SIMULATOR
		foundKey = [_objectCache objectForKey:key] == nil ? NO : YES;
	#else
		NSMutableDictionary *keychainQuery = [[NSMutableDictionary alloc] init];
		
		[keychainQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];      // Generic password type
		[keychainQuery setObject:_identifier forKey:(__bridge id)kSecAttrGeneric];                          // That has our identifier as a generic attribute
		[keychainQuery setObject:key forKey:(__bridge id)kSecAttrLabel];                                    // Use this as our label
		[keychainQuery setObject:key forKey:(__bridge id)kSecAttrAccount];                                  // Use this as the account	
		
		[keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];		// Limit results to 1
		[keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];			// Return the encoded data
		
    
        // Search...
        //      See http://stackoverflow.com/questions/7827730/iphone-fetch-data-dictionary-from-keychain
        //
        CFDictionaryRef cfquery   = (__bridge_retained CFDictionaryRef)keychainQuery;
        CFDataRef       cfresult  = NULL;
        OSStatus        error     = SecItemCopyMatching( cfquery, (CFTypeRef *)&cfresult );
        NSData         *dataSaved = (__bridge_transfer NSData *)cfresult;
        CFRelease( cfquery );
        
		if( error == noErr  &&  dataSaved != nil ) 
			foundKey = YES;
		
		dataSaved = nil;
		keychainQuery = nil;
	#endif
	
	return foundKey;
}




- (bool)removeKey:(NSString *)key
{
	OSStatus error = noErr;
	
	if( key == nil )
		return NO;
	
	#if !TARGET_IPHONE_SIMULATOR
		NSMutableDictionary *keychainQuery = [[NSMutableDictionary alloc] init];
		
		[keychainQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];	// Generic password type
		[keychainQuery setObject:_identifier forKey:(__bridge id)kSecAttrGeneric];                      // That has our identifier as a generic attribute
		[keychainQuery setObject:key forKey:(__bridge id)kSecAttrLabel];                                // Use this as our label
		[keychainQuery setObject:key forKey:(__bridge id)kSecAttrAccount];                              // Use this as the account	
		
		error = SecItemDelete( (__bridge CFDictionaryRef)keychainQuery );

		keychainQuery = nil;
	#endif
	
	if( error == noErr )
    {
		[_objectCache removeObjectForKey:key];
        return YES;
    }
	else
    {
		NSLog( @"FLOKeychain removeKey %@ failed %ld", key, error );
        return NO;
    }
}




- (void)emptyCache
{
    // We don't support emptying the cache when running on the Simulator as under the simulator it isn't really a cache,
    // its the actual storage.
    #if TARGET_IPHONE_SIMULATOR
        return;
    #endif

    [_objectCache removeAllObjects];
}




@end
