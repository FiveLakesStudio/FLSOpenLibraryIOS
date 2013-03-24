//
//  FLOStoryboardViewController.h
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
//  This is a helper class to help us with storyboard ViewController
//
//  This was inspired from StackOverflow artical by rickster
//      http://stackoverflow.com/questions/8287242/how-to-dismiss-a-storyboard-popover
//
//  Created by Tod Cunningham on 8/31/12.
//
#import <UIKit/UIKit.h>


@interface FLOStoryboardViewController : UIViewController
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
