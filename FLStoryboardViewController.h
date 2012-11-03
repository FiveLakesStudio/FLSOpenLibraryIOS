//
//  FLStoryboardViewController.h
//
//  This is a helper class to help us with storyboard ViewController
//
//  This was inspired from StackOverflow artical by rickster
//      http://stackoverflow.com/questions/8287242/how-to-dismiss-a-storyboard-popover
//
//  Created by Tod Cunningham on 8/31/12.
//  Copyright (c) 2012 Five Lakes Studio. All rights reserved.
//
#import <UIKit/UIKit.h>


@interface FLStoryboardViewController : UIViewController
{
    // Remeber the segueIdentifer so we can see if we need to stop the segue from
    // displaying the popover
    __strong NSString            *m_segueIdentifier;
    
    // This is weak reference so that when the popover is no longer being displayed it
    // will automaticlly get set to nil.
    __weak   UIPopoverController *m_popoverController;
}

// Help with the display and dismiss of popovers For iOS 6 or later.   The
// popover segue should be named so we can close (without redisplaying) it
// when it is already displayed.
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender;

@end
