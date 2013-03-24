//
//  FLOStoreManager+Consumable.h
//  PicrossHDUniversal
//
//  Created by Tod Cunningham on 1/24/13.
//
//
#import "FLOStoreManager.h"

typedef void (^FLOStoreManagerConsumablePurchased)(NSString *featureId);


@interface FLOStoreManager (Consumable)

- (void)makeConsumableFeatureId:(NSString *)featureId withPurchasedBlock:(FLOStoreManagerConsumablePurchased)purchasedBlock;
- (bool)isConsumableFeatureId:(NSString *)featureId;

- (bool)setConsumablePurchased:(NSString *)featureId;

@end
