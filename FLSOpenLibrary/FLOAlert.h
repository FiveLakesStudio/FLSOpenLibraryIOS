//
//  FLOAlert.h
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
// Based on code from http://www.wannabegeek.com/?p=96
// check out objc_setAssociatedObject and objc_getAssociatedObject for cool stuff!
//
//
//    FLOAlert *alert = [[FLOAlert alloc] initWithTitle:@"Reset Puzzles" 
//                                            message:@"Reset ALL puzzles in this puzzle pack?"
//                                  cancelButtonTitle:@"Cancel" 
//                                  otherButtonTitles:@"Yes", nil];
//    
//    [alert showAlertWithCompletionBlock:^(int buttonIndex)
//                                       {
//                                           NSLog( @"Hello I got it %d", buttonIndex );
//                                          [alert release];
//                                       }];
//
//  Created by Tod Cunningham on 11/6/11.
//  Copyright (c) 2011 Five Lakes Studio. All rights reserved.
//
#import <UIKit/UIKit.h>


typedef void (^FLOAlertBlock)(int buttonIndex);


#define kAlertViewCanceled -1



@interface FLOAlert : UIAlertView <UIAlertViewDelegate>
{
    FLOAlertBlock  m_alertBlock;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (void)showAlertWithCompletionBlock:(FLOAlertBlock)block;

@end
