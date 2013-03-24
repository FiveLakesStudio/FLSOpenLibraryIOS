//
//  FLOStoryboardViewController.m
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
//  This was inspired from StackOverflow artical by rickster
//      http://stackoverflow.com/questions/8287242/how-to-dismiss-a-storyboard-popover
//
//  Created by Tod Cunningham on 8/31/12.
//
#import "FLOStoryboardViewController.h"



#if (__IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0)
#warning "FLOStoryboardViewController uses features only available in iOS 6.0 and later."
#endif



@interface FLOStoryboardViewController ()
@end




@implementation FLOStoryboardViewController




// Override from base class
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue isKindOfClass:[UIStoryboardPopoverSegue class]] )
    {
        UIStoryboardPopoverSegue *popoverSegue = (id)segue;
        
        if( m_popoverController  ==  nil )
        {
            assert( popoverSegue.identifier.length >  0 );    // The Popover segue should be named for this to work fully
            m_segueIdentifier   = popoverSegue.identifier;
            m_popoverController = popoverSegue.popoverController;
        }
        else
        {
            [m_popoverController dismissPopoverAnimated:YES];
            m_segueIdentifier = nil;
            m_popoverController = nil;
        }
    }
    else
    {
        [super prepareForSegue:segue sender:sender];
    }
}



// Override from base class
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // If this is an unnamed segue go ahead and allow it
    if( identifier.length != 0 )
    {
        if( [identifier compare:m_segueIdentifier]  ==  NSOrderedSame )
        {
            if( m_popoverController == NULL )
            {
                m_segueIdentifier = nil;
                return YES;
            }
            else
            {
                [m_popoverController dismissPopoverAnimated:YES];
                m_segueIdentifier = nil;
                m_popoverController = nil;
                return NO;
            }
        }
    }
    
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}


@end
