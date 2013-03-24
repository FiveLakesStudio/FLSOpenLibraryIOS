//
// FLOKeychain.h
//
// Requires: Security.framework
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
//  Created by Tod Cunningham on 7/9/10.
//
#import <UIKit/UIKit.h>


@interface FLOKeychain : NSObject
{
	NSString            *_identifier;
	NSMutableDictionary *_objectCache;
}

+ (void)setDefaultKeychainId:(NSString *)keychainId;   // Use your own unique ID such as @"MyAppName"
+ (FLOKeychain *)defaultKeychain;

- (id)initWithKeychainID:(NSString *)keychainId;

- (NSString *)stringForKey:(NSString *)key;
- (void)setString:(NSString *)theString forKey:(NSString *)key;

- (bool)boolForKey:(NSString *)key;
- (void)setBool:(bool)theBool forKey:(NSString *)key;

- (NSInteger)integerForKey:(NSString *)key;
- (void)setInteger:(NSInteger)theInt forKey:(NSString *)key;

- (NSDate *)dateForKey:(NSString *)key;
- (void)setDate:(NSDate *)theDate forKey:(NSString *)key;

// These are the core routines
- (NSData *)dataForKey:(NSString *)key;
- (void)setData:(NSData *)dataToSave forKey:(NSString *)key;

- (bool)keyExists:(NSString *)key;
- (bool)removeKey:(NSString *)key;

- (void)emptyCache;     // Used for testing

@end
