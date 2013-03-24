//
// FLOStoreManager.h
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
// Based on work by http://blog.mugunthkumar.com/coding/iphone-tutorial-%E2%80%93-in-app-purchases/
//    Mugunth Kumar
//
// Created by Tod Cunningham on 7/8/10.
//
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kFeatureListReady          @"FLOStoreManagerFeatureListReady"
#define kFeaturePurchased		   @"FLOStoreManagerFeaturePurchased"		// Returns object of type NSString containing the featureId purchased
#define kFeaturePurchasedFailed	   @"FLOStoreManagerFeaturePurchasedFailed"	// Returns object of type NSString containing the featureId trying to be purchased
#define kPurchaseRestoredCompleted @"FLOStoreManagerPurchaseRestoredCompleted"


@interface FLOStoreManager : NSObject <SKPaymentTransactionObserver,SKProductsRequestDelegate>
{
	NSMutableSet	    *_featureIdList;
    NSMutableDictionary *_productDict;
    NSDate              *_productListLastUpdatedDate;
    
    NSMutableSet      *_featureIdProcessingPurchaseList;
    
	SKProductsRequest *_fetechProductRequest;
    NSMutableSet	  *_fetchFeatureRequestedIdList;
    
    NSMutableDictionary *_storeItemDict;            // List of FLStoreItem objects
    
    NSMutableDictionary *_featureIdConsumableBlockDict;  // Block callback associated with consumables purchases
    
    SKPaymentTransaction *_lastPaymentTransaction;
}

+ (FLOStoreManager *)defaultManager;
- (void)becomeDefaultManager;

- (NSArray *)featureIdList;
- (NSArray *)requestedFeatureIdList;
- (bool)isFeatureIdRegistered:(NSString *)featureId;
- (NSString *)formattedPriceForFeatureId:(NSString *)featureId;

// Purchase the given featureId
- (void)startAsyncPurchaseOfFeature:(NSString*)featureId;
- (void)restoreCompletedTransactions;
- (bool)isFeatureBeingPurchased:(NSString *)featureId;
- (bool)isAnyFeatureBeingPurchased;

// These can be overridden in order to handle feature activation different.  Default implementation uses keychain. 
- (bool)setPurchased:(NSString *)featureId;
- (bool)isPurchased:(NSString *)featureId;
- (bool)isAnyFeatureIdPurchased;
- (void)revokePurchase:(NSString *)featureId;		// Note this is for testing only (apple doesn't support revokeing of a purchase!)

// Handle success/failed purchase transactions
- (bool)successfulPurchaseTransaction:(SKPaymentTransaction *)originalTransaction;	// Called when transaction was successful, returns YES if successful
- (void)failedPurchaseTransaction:(SKPaymentTransaction *)transaction;				// Called when transaction failed

// Get Transaction Details
- (SKPaymentTransaction *)lastPaymentTransaction;

// Getting product info for given set of feature IDs
- (void)startAsyncFetchOfProductForFeatureList:(NSSet *)featureIdList;
+ (void)dumpProductResponse:(SKProductsResponse *)response;

@end
