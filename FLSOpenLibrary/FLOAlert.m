//
//  FLOAlert.m
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
#import "FLOAlert.h"

@implementation FLOAlert




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
        NSLog( @"Error: FLOAlert delegate must be set to self." );
        return;
    }
    
    [super setDelegate:delegate];
}



- (void)showAlertWithCompletionBlock:(FLOAlertBlock)block
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

