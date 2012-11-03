//
//  FLAlert.h
//
// Based on code from http://www.wannabegeek.com/?p=96
// check out objc_setAssociatedObject and objc_getAssociatedObject for cool stuff!
//
//
//    FLAlert *alert = [[FLAlert alloc] initWithTitle:@"Reset Puzzles" 
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


typedef void (^FLAlertBlock)(int buttonIndex);


#define kAlertViewCanceled -1



@interface FLAlert : UIAlertView <UIAlertViewDelegate>
{
    FLAlertBlock  m_alertBlock;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (void)showAlertWithCompletionBlock:(FLAlertBlock)block;

@end
