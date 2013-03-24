//
//  FLOStoreManager+Consumable.m
//  PicrossHDUniversal
//
//  Created by Tod Cunningham on 1/24/13.
//
//
#import "FLOStoreManager+Consumable.h"
#import "FLOUtil.h"



@implementation FLOStoreManager (Consumable)



- (void)makeConsumableFeatureId:(NSString *)featureId withPurchasedBlock:(FLOStoreManagerConsumablePurchased)purchasedBlock
{
    if( featureId.length == 0 )
        return;
    
    if( _featureIdConsumableBlockDict == nil )
        _featureIdConsumableBlockDict = [[NSMutableDictionary alloc] init];
    
    // Make sure the feature is registered as we still need to get info about it before we can do a purchase
    //
    if( ![self isFeatureIdRegistered:featureId]  &&  ![_fetchFeatureRequestedIdList containsObject:featureId] )
    {
        assertTriggerNSLog( @"makeConsumableFeatureId: featureId %@ hasn't been registered.", featureId );
        return;
    }

    // Make sure we have a block to notify when the consumable is purchased.  We have to have this so someone will be
    // sure to handle the purchase.  Otherwise, we might miss the consumable purchase and thus not five the user credit.
    // 
    if( purchasedBlock == nil )
    {
        assertTriggerNSLog( @"makeConsumableFeatureId: A purchased block is required for consumable purchase %@.", featureId );
        return;
    }
    
    
    // Save the value associated with the block
    //
    [_featureIdConsumableBlockDict setObject:[purchasedBlock copy] forKey:featureId];
}




- (bool)isConsumableFeatureId:(NSString *)featureId
{
    if( featureId.length == 0 )
        return NO;
    
	if( ![_featureIdConsumableBlockDict.allKeys containsObject:featureId] )
		return NO;
	
	return YES;
}




- (bool)setConsumablePurchased:(NSString *)featureId
{
    if( ![self isConsumableFeatureId:featureId] )
        return NO;
    
    FLOStoreManagerConsumablePurchased purchasedBlock = [_featureIdConsumableBlockDict objectForKey:featureId];
    if( purchasedBlock != nil )
        purchasedBlock( featureId );
    
    return YES;
}




@end
