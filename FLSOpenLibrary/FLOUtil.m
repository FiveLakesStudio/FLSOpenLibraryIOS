//
// FLOUtil.m
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
#import "FLOUtil.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <QuartzCore/QuartzCore.h>



/* ============================ */
@implementation FLOUtil




+ (void)dispatchAsyncMainBlock:(dispatch_block_t)block afterDelayInSeconds:(float)seconds
{
    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*seconds), dispatch_get_main_queue(), block);
}



+ (void)dispatchAsyncMainBlock:(dispatch_block_t)block               // This use to be called dispatchMainBlock
{
    dispatch_async( dispatch_get_main_queue(), block );
}


+ (void)dispatchAsyncBlock:(dispatch_block_t)block
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block );
}


+ (void)dispatchAsyncBlock:(dispatch_block_t)block afterDelayInSeconds:(float)seconds
{
    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*seconds), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block );
}


+ (void)dispatchAsyncLowPriorityBlock:(dispatch_block_t)block
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block );
}



// Runs the given block asynchronously but in the order added to this queue.
// http://developer.apple.com/library/ios/#documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html
+ (void)dispatchAsyncSerialQueueBlock:(dispatch_block_t)block
{
    static dispatch_queue_t gSerialQueue = nil;   // dispatch_release
    
    if( gSerialQueue  ==  nil )
        gSerialQueue = dispatch_queue_create("com.fivelakesstudio.FLOUtilDefaultSerialQueue", DISPATCH_QUEUE_SERIAL);

    dispatch_async( gSerialQueue, block );
}




+ (bool)saveSerializableObject:(id<NSObject,NSCoding>)obj toFullFilename:(NSString *)fullFilename
{
    if( obj == nil  ||  fullFilename == nil )
        return NO;
    
    if( ![NSKeyedArchiver archiveRootObject:obj toFile:fullFilename] )
    {
        NSString *className = NSStringFromClass([obj class]);
        NSLog( @"saveSerializableObject %@ failed to save %@.", className, fullFilename );
        return NO;
    }
    
    return YES;
}




+ (id)loadSerializableObjectFromFullFilename:(NSString *)fullFilename
{
    id obj = nil;
    
    if( fullFilename != nil )
    {
        NS_DURING
            obj = [NSKeyedUnarchiver unarchiveObjectWithFile:fullFilename];
        NS_HANDLER
            obj = nil;
        NS_ENDHANDLER
    }

    // If the file exists and we fail to load it then we shown a warning message.
    if( obj == nil  &&  [[NSFileManager defaultManager] fileExistsAtPath:fullFilename] )
        NSLog( @"loadSerializableObjectFromFullFilename failed to load %@.", fullFilename );

    return obj;
}




+ (id)copyTemplate:(id<NSCoding>)template   // Returned object has been retained (be sure to release it)
{
    NSData *templateData = [NSKeyedArchiver archivedDataWithRootObject:template];
    id      obj          = nil;
    
    NS_DURING
	obj = [NSKeyedUnarchiver unarchiveObjectWithData:templateData];
	NS_HANDLER
	obj = nil;
	NS_ENDHANDLER
}




+ (bool)createFolderWithFullpath:(NSString *)folderFullpath
{
    if( folderFullpath == nil )
        return NO;
    
    BOOL isDir      = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:folderFullpath isDirectory:&isDir];
    
    if( fileExists )
    {
        if( !isDir )  // It better be a directory
        {
            NSLog(@"createFolderForFullPath: Given path '%@' not a folder.", folderFullpath );
            return NO;
        }
    }
    else // Try to create it
    {
        NSError * error = nil;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:folderFullpath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if( error != nil )
        {
            NSLog( @"createFolderForFullPath: Error creating directory '%@': %@", folderFullpath, error );
            return NO;
        }
    }
    
    return YES;
}



// http://stackoverflow.com/questions/5443166/how-to-convert-uiview-to-pdf-within-ios
//
+ (void)createPDFfromUIView:(UIView*)aView saveToFullFilename:(NSString*)fullFilename
{
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
    
    [aView.layer renderInContext:pdfContext];
    
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
        
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:fullFilename atomically:YES];
}




+ (NSString *)currentLanguageCode
{
    static NSString *gCurrentLanguageCode = nil;
    
    //
    // iOS will kill our app when the current langauge code changes.  We can cache the currentLanguageCode so
    // we don't have to keep looking it up. 
    if( gCurrentLanguageCode == nil )
    {
        NSUserDefaults *defs      = [NSUserDefaults standardUserDefaults];
        NSArray        *languages = [defs objectForKey:@"AppleLanguages"];
        
        if( languages.count > 0 )
            gCurrentLanguageCode = [languages objectAtIndex:0];     // en, de, fr, ja
        else
            gCurrentLanguageCode = @"en";
    }

    // If we can't figure out the current language then just return english
    return gCurrentLanguageCode;
}




+ (void)localizeLabelsInView:(UIView *)theView
{
    for( id foundView in theView.subviews )
    {
        if( [foundView isKindOfClass:[UILabel class]] )
        {
            UILabel *label = foundView;
            label.text = NSLocalizedString( label.text, nil );
        }
    }
}




+ (void)localizeButtonsInView:(UIView *)theView
{
    for( id foundView in theView.subviews )
    {
        if( [foundView isKindOfClass:[UIButton class]] )
        {
            UIButton *button   = foundView;
            NSString *locTitle = NSLocalizedString( [button titleForState:UIControlStateNormal], nil );
            [button setTitle:locTitle forState:UIControlStateNormal];
        }
    }
}




+ (int)systemVersionMajor
{
	NSString *currSysVerStr = [[UIDevice currentDevice] systemVersion];
	NSArray  *sysVerParts   = [currSysVerStr componentsSeparatedByString:@"."];
		
	if( [sysVerParts count] != 0 )	// Major is first number
		return [[sysVerParts objectAtIndex:0] intValue];
	else
	{
		NSLog( @"Unknown major version" );
		return 0;
	}
}



+ (int)systemVersionMinor
{
	NSString *currSysVerStr = [[UIDevice currentDevice] systemVersion];
	NSArray  *sysVerParts   = [currSysVerStr componentsSeparatedByString:@"."];
		
	if( [sysVerParts count] >= 2 )	// Minor is 2nd number
		return [[sysVerParts objectAtIndex:1] intValue];
	else
	{
		NSLog( @"Unknown minor version" );
		return 0;
	}
}



+ (bool)isSystemVersionAtLeastMajor:(int)requiredMajorVer minor:(int)requiredMinorVer
{
	int sysMajorVer = [FLOUtil systemVersionMajor];
	int sysMinorVer = [FLOUtil systemVersionMinor];
		
	if( sysMajorVer < requiredMajorVer )
		return NO;
	
	if( sysMajorVer > requiredMajorVer )
		return YES;
	
	// If Major versions match, then check minor version
	if( sysMinorVer < requiredMinorVer )
		return NO;
	
	return YES;
}



+ (bool)iPad
{
    // Can use UI_USER_INTERFACE_IDIOM() for iOS less than 3.2
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad )
        return YES;
    else
        return NO;
}



+ (bool)iPhone
{
    // Can use UI_USER_INTERFACE_IDIOM() for iOS less than 3.2
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        return YES;
    else
        return NO;
}




+ (bool)iPhoneTall
{
    if( [self iPhone] )
    {
        if( [UIScreen mainScreen].bounds.size.height == 568 )
            return YES;
    }
    
    return NO;
}




// http://stackoverflow.com/questions/3504173/detect-retina-display
+ (bool)isRetinaDisplay
{
    if( [self isSystemVersionAtLeastMajor:4 minor:0]  &&
        ([UIScreen mainScreen].scale == 2.0) )
        return YES;
    
    return NO;
}



+ (bool)iPhoneSizedScreen
{
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if( screenWidth < 768 )
        return YES;
    
    return NO;
}



+ (CGSize)screenSize
{
    return [UIScreen mainScreen].bounds.size;
}




+ (bool)isPortraitViewController:(UIViewController *)viewController
{   
    switch( viewController.interfaceOrientation )
    {
        case UIInterfaceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        case UIInterfaceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            return YES;
            
        case UIInterfaceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
        case UIInterfaceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
        default:
            return NO;
    }
}




+ (float)screenLandscapeWidth	// Width is greater then height
{
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
	return (screenSize.width > screenSize.height) ? screenSize.width : screenSize.height;
}




+ (float)screenLandscapeHeight	// Width is greater then height
{
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	return (screenSize.width < screenSize.height) ? screenSize.width : screenSize.height;
}




+ (float)screenPortraitWidth	// Height is greater then width
{
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	
	return (screenSize.width < screenSize.height) ? screenSize.width : screenSize.height;
}




+ (float)screenPortraitHeight	// Height is greater then width
{
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	return (screenSize.width > screenSize.height) ? screenSize.width : screenSize.height;
}




+ (void)showStatusActivity:(bool)turnOn
{
	
	if( turnOn )
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	else
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}




// http://www.tuaw.com/2010/02/05/app-store-devsugar-browser-based-previews-and-url-tricks/
//
// NOTE: AppStore isn't available on the simulator so we just end up in a webpage.  On real device it work fine
//
+ (NSURL *)urlForApplication:(NSString *)appId		// appId such as @"375677242"
{
	NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", appId];
	NSURL    *url    = [NSURL    URLWithString:urlStr];
	
	return url;
}




+ (NSURL *)urlForApplicationReview:(NSString *)appId		// appId such as @"375677242"
{
    return [self urlForApplication:appId];
    
    /*
    // !! TC !! Note sure I like this way, so we just goto the application URL
    // http://stackoverflow.com/questions/6664535/how-to-get-ipad-only-customer-reviews-on-itunes
	NSString *urlStr = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId];
	NSURL    *url    = [NSURL    URLWithString:urlStr];
	
	return url;
    */
}




/* Sample on how to open a URL that has lots of redirects
 *		http://www.tuaw.com/2010/02/05/app-store-devsugar-browser-based-previews-and-url-tricks/
 *		http://developer.apple.com/iphone/library/qa/qa2008/qa1629.html
 */
+ (void)openURL:(NSURL *)url
{
	if( url == nil )
		return;
	
	[[UIApplication sharedApplication] openURL:url];
}




+ (NSString *)appName
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}




// http://stackoverflow.com/questions/510216/can-you-make-the-settings-in-settings-bundle-default-even-if-you-dont-open-the-s
+ (void)registerDefaultsFromSettingsBundle
{
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if( !settingsBundle )
    {
        NSLog( @"registerDefaultsFromSettingsBundle: Could not find Settings.bundle" );
        return;
    }
    
    NSDictionary *settings    = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray      *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for( NSDictionary *prefSpecification in preferences )
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if( key )
        {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}




+ (UIDeviceOrientation)deviceOrientationFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:            return UIDeviceOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:  return UIDeviceOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:       return UIDeviceOrientationLandscapeRight;
        case UIInterfaceOrientationLandscapeRight:      return UIDeviceOrientationLandscapeLeft;
    }
}



@end




/* ============================ */
@implementation NSDate (FLODate)


- (bool)isEqualDate:(NSDate *)anotherDate	// Ignores time
{
	static NSDateFormatter *dateFormatter = nil;
	
	if( anotherDate  ==  nil )
		return NO;
	
	if( dateFormatter == nil )
	{
		dateFormatter = [[NSDateFormatter alloc] init];		// Memory leak ok (will never release)
		[dateFormatter setDateFormat:@"yyyyMMdd"];
	}
	
	NSString *thisDateStr    = [dateFormatter stringFromDate:self];
	NSString *anotherDateStr = [dateFormatter stringFromDate:anotherDate];

	return [thisDateStr isEqual:anotherDateStr];
}


- (bool)isToday
{
    NSDate           *today              = [NSDate date];
    NSCalendar       *calendar           = [NSCalendar currentCalendar];
    NSUInteger        calendarFlags      = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *otherDayComponents = [calendar components:calendarFlags fromDate:self];
    NSDateComponents *todayDayComponents = [calendar components:calendarFlags fromDate:today];
    
    if( todayDayComponents.day   == otherDayComponents.day &&
        todayDayComponents.month == otherDayComponents.month &&
        todayDayComponents.year  == otherDayComponents.year )
    {
        return YES;
    }
       
    return NO;
}



// Modified from original example from:
//		http://arstechnica.com/apple/guides/2010/03/how-to-real-world-dates-with-the-iphone-sdk.ars
//
- (NSDate *)dateByAddingDays:(int)days
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + (kDateTicksPerDay * days);
	NSDate        *newDate       = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];

	return newDate;		
}


+ (NSDate *)dateWithDaysFromNow:(int)days
{
	NSDate *now     = [[NSDate alloc] init];
	NSDate *newDate = [now dateByAddingDays:days];

	return newDate;	
}


+ (NSDate *)dateTomorrow
{
	return [NSDate dateWithDaysFromNow:1];
}


+ (NSDate *)dateYesterday
{
	return [NSDate dateWithDaysFromNow:-1];
}



- (NSInteger)daysIntervalSinceDate:(NSDate *)fromDate
{
	NSInteger secsSince = [self timeIntervalSinceDate:fromDate];
	NSInteger daysSince = secsSince / kDateTicksPerDay;

	return daysSince;
}



- (bool)isAtLeastDaysOld:(float)days
{
    NSInteger secsSince = [[NSDate date] timeIntervalSinceDate:self];
	float     daysSince = (float)secsSince / (float)kDateTicksPerDay;

    if( daysSince >= days )
        return YES;
    else
        return NO;
}



/* Sample code on how to get hours from date
 
 NSCalendar *calendar = [NSCalendar currentCalendar];
 unsigned int unitFlags = NSHourCalendarUnit|NSMinuteCalendarUnit;
 NSDateComponents *comp = [calendar components:unitFlags fromDate:date];
 NSInteger hour = [comp hour];
 if( hour == 23 )
 NSLog( @"Message = %@", [messageNode toXML] ); 
 
 */

@end




/* ============================ */
@implementation UIScreen (FLOScreen)

// http://stackoverflow.com/questions/2807339/uikeyboardboundsuserinfokey-is-deprecated-what-to-use-instead
+ (CGRect) convertRect:(CGRect)rect toView:(UIView *)view
{
    UIWindow *window = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : [view window];
	
    return [view convertRect:[window convertRect:rect fromWindow:nil] fromView:nil];
}

@end



