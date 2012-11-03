//
//  FLAlert.m
//
//  Created by Tod Cunningham on 11/6/11.
//  Copyright (c) 2011 Five Lakes Studio. All rights reserved.
//
#import "FLAlert.h"

@implementation FLAlert




- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
	self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
	if( self != nil )
	{
        // Add any additional button titles to the alert
        //
        if( otherButtonTitles != nil ) 
        {
            id      buttonTitleObject;
            va_list argumentList;

            [self addButtonWithTitle:otherButtonTitles];
            
            va_start( argumentList, otherButtonTitles );        // Start scanning for arguments after otherButtonTitles.
            {
                do
                {
                    buttonTitleObject = va_arg(argumentList, id);
                    if( buttonTitleObject != nil  &&  [buttonTitleObject isKindOfClass:[NSString class]] )
                         [self addButtonWithTitle:buttonTitleObject];
                } while( buttonTitleObject != nil );                
            }
            va_end( argumentList );
        }

        m_alertBlock = nil;
	}
	
	return( self );
}




- (void)dealloc
{	    
    m_alertBlock = nil;    
}




- (void)setDelegate:(id)delegate
{
    if( delegate != nil  &&  delegate != self )
    {
        NSLog( @"Error: FLAlert delegate must be set to self." );
        return;
    }
    
    [super setDelegate:delegate];
}



- (void)showAlertWithCompletionBlock:(FLAlertBlock)block
{    
    // Don't show an alert if we are already wating for one.
    if( m_alertBlock != nil )
        return;
        
    m_alertBlock = [block copy];
    [self show];
}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( m_alertBlock != nil )
    {                
        m_alertBlock( buttonIndex );
        m_alertBlock = nil;        
    }
}




- (void)alertViewCancel:(UIAlertView *)alertView
{
    if( m_alertBlock != nil )
    {        
        m_alertBlock( kAlertViewCanceled );
        m_alertBlock = nil;        
    }    
}





@end

