//
//  FLStoryboardViewController.m
//
//  This was inspired from StackOverflow artical by rickster
//      http://stackoverflow.com/questions/8287242/how-to-dismiss-a-storyboard-popover
//
//  Created by Tod Cunningham on 8/31/12.
//  Copyright (c) 2012 Five Lakes Studio. All rights reserved.
//
#import "FLStoryboardViewController.h"



#if (__IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0)
#warning "FLStoryboardViewController uses features only available in iOS 6.0 and later."
#endif



@interface FLStoryboardViewController ()
@end




@implementation FLStoryboardViewController




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
