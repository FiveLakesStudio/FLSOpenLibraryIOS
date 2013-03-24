//
// FLOUtil.h
//
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
// Created by Tod Cunningham on 3/18/10.
//
#import <UIKit/UIKit.h>




// This is a handle little helper that logs a message and throws an assert.  If the code is in release node
// AKA optimized we exclude the assert.
//
#ifdef __OPTIMIZE__
    #define assertTriggerNSLog(...) NSLog(__VA_ARGS__)
#else
    #define assertTriggerNSLog(...) do { NSLog(__VA_ARGS__); assert(false); } while(0)
#endif



@interface FLOUtil : NSObject
{

}

//example: void (^animationCompleted)(void) = ^(void) { };
//         [FLOUtil dispatchBlock:animationCompleted afterDelayInSeconds:0.5];
//   or 
//example: [FLOUtil dispatchBlock:^{[self dropInPiecesForColumn:xPos fromHeight:gapCount];} afterDelayInSeconds:0.5];    
+ (void)dispatchAsyncMainBlock:(dispatch_block_t)block afterDelayInSeconds:(float)seconds;
+ (void)dispatchAsyncMainBlock:(dispatch_block_t)block;
+ (void)dispatchAsyncBlock:(dispatch_block_t)block;
+ (void)dispatchAsyncBlock:(dispatch_block_t)block afterDelayInSeconds:(float)seconds;
+ (void)dispatchAsyncLowPriorityBlock:(dispatch_block_t)block;
+ (void)dispatchAsyncSerialQueueBlock:(dispatch_block_t)block;

+ (NSString *)currentLanguageCode;
+ (void)localizeLabelsInView:(UIView *)theView;
+ (void)localizeButtonsInView:(UIView *)theView;

+ (int)systemVersionMajor;
+ (int)systemVersionMinor;
+ (bool)isSystemVersionAtLeastMajor:(int)requiredMajorVer minor:(int)requiredMinorVer;

+ (bool)iPad;
+ (bool)iPhone;
+ (bool)iPhoneTall;
+ (bool)iPhoneSizedScreen;
+ (bool)isRetinaDisplay;

+ (CGSize)screenSize;

+ (bool)isPortraitViewController:(UIViewController *)viewController;

+ (float)screenLandscapeWidth;		// Width is greater then height
+ (float)screenLandscapeHeight;		//
+ (float)screenPortraitWidth;		// Height is greater then width
+ (float)screenPortraitHeight;		// 

+ (void)showStatusActivity:(bool)turnOn;

+ (NSURL *)urlForApplication:(NSString *)appId;				// appId such as @"375677242"
+ (NSURL *)urlForApplicationReview:(NSString *)appId;		// appId such as @"375677242"
+ (void)openURL:(NSURL *)url;

+ (NSString *)appName;

+ (void)registerDefaultsFromSettingsBundle;

+ (UIDeviceOrientation)deviceOrientationFromInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end





#define kDateTicksPerMinute	(60)
#define kDateTicksPerHour	(60 * kDateTicksPerMinute)
#define kDateTicksPerDay	(24 * kDateTicksPerHour)		// or 86400 seconds!
#define kDateTicksPerWeek	(7  * kDateTicksPerDay)
#define kDateTicksPerYear	(31556926)

@interface NSDate (FLODate)
- (bool)isEqualDate:(NSDate *)anotherDate;	// Ignores time
- (bool)isToday;

- (NSDate *)dateByAddingDays:(int)days;
+ (NSDate *)dateWithDaysFromNow:(int)days;
+ (NSDate *)dateTomorrow;
+ (NSDate *)dateYesterday;

- (NSInteger)daysIntervalSinceDate:(NSDate *)fromDate;	// Number of days bettween the dates
- (bool)isAtLeastDaysOld:(float)days;
@end




@interface UIScreen (FLOScreen)
// Conversion to help with screen orientation mapping
+ (CGRect) convertRect:(CGRect)rect toView:(UIView *)view;
@end











