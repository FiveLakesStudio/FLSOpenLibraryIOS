//
//  FLONotification.m
//  EuchreWithFriends
//
//  Created by Tod Cunningham on 8/20/13.
//  Copyright (c) 2013 Five Lakes Studio. All rights reserved.
//
#import "FLONotification.h"



@implementation FLONotification




- (id)init
{
	self = [super init];
	if (self != nil )
	{
	}
	
	return self;
}




- (void)dealloc
{
    [self removeAllObservers];
}


// It's useful to use something like this to reference self:
//
//     __weak typeof(self) weakSelf = self;
//
- (void)addObserverForName:(NSString *)name usingBlock:(void (^)(NSNotification *note))block
{
    if( m_observerList == nil )
        m_observerList = [[NSMutableArray alloc] init];
    
    id observerId = [[NSNotificationCenter defaultCenter] addObserverForName:name object:nil queue:nil usingBlock:block];
    if( observerId != nil )
        [m_observerList addObject:observerId];
}




- (void)removeAllObservers
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    for( id observerId in m_observerList )
        [notificationCenter removeObserver:observerId];
}




@end
