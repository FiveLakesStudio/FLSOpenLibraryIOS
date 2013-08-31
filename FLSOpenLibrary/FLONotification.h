//
//  FLONotification.h
//  EuchreWithFriends
//
//  Created by Tod Cunningham on 8/20/13.
//  Copyright (c) 2013 Five Lakes Studio. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface FLONotification : NSObject
{
    NSMutableArray *m_observerList;
}


- (void)addObserverForName:(NSString *)name usingBlock:(void (^)(NSNotification *note))block;
- (void)removeAllObservers;

@end
