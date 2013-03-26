//
// FLOStoreManager.m
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
#import "FLOStoreManager.h"
#import "FLOKeychain.h"
#import "FLOUtil.h"

#define kStoreKeyPrefix	@"StoreFeatureId_"


// The following can be placed in the PCH to use the STORE simulation when using the iOS Simulator
//
//#if TARGET_IPHONE_SIMULATOR
//   #define ENABLE_STORE_SIMULATION 1
//#endif


#ifndef ENABLE_STORE_SIMULATION
    #define ENABLE_STORE_SIMULATION 0
#endif



// If we use the simulator we just save the setting in the local cache (no keychain)
#if ENABLE_STORE_SIMULATION
#warning iPhone SKStoreManager not supported on the simulator
#endif




@interface FLOStoreManager (PrivateMethods)
@end




@implementation FLOStoreManager


static FLOStoreManager *_defaultStoreManager = nil;

+ (FLOStoreManager *)defaultManager
{
	@synchronized( self )
	{
		if( _defaultStoreManager  ==  nil )
			_defaultStoreManager = [[FLOStoreManager alloc] init];
	}
	
	return _defaultStoreManager;
}




- (id)init
{
	self = [super init];
	if( self != nil )
	{
		_featureIdList                   = [[NSMutableSet alloc] init];
        _featureIdProcessingPurchaseList = [[NSMutableSet alloc] init];
        _productDict                     = [[NSMutableDictionary alloc] init];
		
		#if !ENABLE_STORE_SIMULATION
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
		#endif
	}
	
	return self;
}




- (void)dealloc
{
	#if !ENABLE_STORE_SIMULATION
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];	
	#endif

     _productDict = nil;
	_featureIdList = nil;
    _featureIdProcessingPurchaseList = nil;
	
    _fetchFeatureRequestedIdList = nil;
    
	[_fetechProductRequest cancel];
	_fetechProductRequest = nil;
	
    _productListLastUpdatedDate = nil;
    
    _storeItemDict = nil;
}




// Allows subclasses of this class to become the default manager
- (void)becomeDefaultManager
{
    _defaultStoreManager = self;
}




// Returns YES if the given featureId is registered OR there are no features registered
//
- (bool)isFeatureIdRegistered:(NSString *)featureId
{
    if( featureId == nil )
        return NO;
    
	if( ![_featureIdList containsObject:featureId] )
	{
		//NSLog( @"FLOStoreManager unknown featureId %@", featureId );
		return NO;
	}
	
	return YES;
}




- (bool)isAnyFeatureIdPurchased
{
    NSSet *featureIdList = _fetchFeatureRequestedIdList == nil ? _featureIdList : _fetchFeatureRequestedIdList;
    
    if( featureIdList != nil )
    {
        for( NSString *featureId in featureIdList )
        {
            if( [self isPurchased:featureId] )
                return YES;
        }
    }
    
    return NO;
}




- (bool)isAnyFeatureBeingPurchased
{
    return _featureIdProcessingPurchaseList.count > 0 ? YES : NO;
}




- (bool)isFeatureBeingPurchased:(NSString *)featureId
{
    return [_featureIdProcessingPurchaseList containsObject:featureId] ? YES : NO;
}




- (NSArray *)featureIdList
{
    if( _featureIdList == nil )
        return nil;
    
    return [_featureIdList allObjects];
}




- (NSArray *)requestedFeatureIdList
{
    if( _fetchFeatureRequestedIdList == nil )
        return nil;
    
    return [_fetchFeatureRequestedIdList allObjects];
}




// returns YES if we where successfully able to set the purchase.  We don't check for valid featureId!
- (bool)setPurchased:(NSString *)featureId
{	
    if( featureId == nil )
        return NO;
    
    bool purchasedHandledAsConsumable = NO;
    
    // Check to see if consumable purchases are enabled.  If they are then we try to handle this as a consumable purchase.
    //
    SEL consumablePurchasedSelector = @selector(setConsumablePurchased:);
    if( [self respondsToSelector:consumablePurchasedSelector] )
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:consumablePurchasedSelector]];
        [invocation setSelector:consumablePurchasedSelector];
        [invocation setTarget:self];
        [invocation setArgument:&featureId atIndex:2];     //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        [invocation invoke];
        
        [invocation getReturnValue:&purchasedHandledAsConsumable];
    }

    // If the purchase has been handled then we are done such as with a consumable purcahse.  Otherwise, we
    // go ahead and mark it as purchased.
    //
    if( !purchasedHandledAsConsumable )
    {
        NSString *key = [NSString stringWithFormat:@"%@%@", kStoreKeyPrefix, featureId];
        
        [[FLOKeychain defaultKeychain] setBool:YES forKey:key];
    }
	
	return YES;
}




- (bool)isPurchased:(NSString *)featureId
{
    if( featureId.length == 0 )
        return NO;
    
	NSString *key = [NSString stringWithFormat:@"%@%@", kStoreKeyPrefix, featureId];
	
	return [[FLOKeychain defaultKeychain] boolForKey:key];
}




- (void)revokePurchase:(NSString *)featureId
{	
    if( featureId.length == 0 )
        return;

	NSString *key = [NSString stringWithFormat:@"%@%@", kStoreKeyPrefix, featureId];
	
    if( [[FLOKeychain defaultKeychain] keyExists:key] )
        [[FLOKeychain defaultKeychain] removeKey:key];
}




- (NSString *)formattedPriceForFeatureId:(NSString *)featureId
{
    #if ENABLE_STORE_SIMULATION
        return @"$0.99";
    #endif

    if( ![self isFeatureIdRegistered:featureId] )
        return nil;
    
    SKProduct *product = [_productDict objectForKey:featureId];
    if( product == nil )
        return @"Unknown";
    
    NSDecimalNumber *priceNumber = product.price;
    if( [[NSDecimalNumber zero] compare:priceNumber]  ==  NSOrderedSame )
        return @"free";
    
    static NSNumberFormatter *gNumberFormatter = nil;
    if( gNumberFormatter == nil )
    {
        gNumberFormatter = [[NSNumberFormatter alloc] init];
        [gNumberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [gNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [gNumberFormatter setLocale:product.priceLocale];
    }
        
    NSString *formattedString = [gNumberFormatter stringFromNumber:product.price];
    
    return formattedString;
}





// Given a list of feature id's.  com.todcunningham.picross.thefeatureA
//								  com.todcunningham.picross.thefeatureB
// The feature id is just the last part!
//
// [[FLOStoreManager defaultManager] startFetchOfProductForFeatureList:[NSSet setWithObjects: @"thefeatureA", @"thefeatureB", nil]];
//
//  The callback should take a single argument of type SKProductsResponse
//
//
// Sample notificatoin handler for kFeatureListReady
//
//		- (void)showAppStoreProductList:(NSNotification *)notification
//		{
//			SKProductsResponse *productResponse = [notification object];
//	
//			[FLOStoreManager dumpProductResponse:productResponse];
//		}
//
- (void)startAsyncFetchOfProductForFeatureList:(NSSet *)featureIdList
{	
	if( featureIdList == nil  ||  featureIdList.count == 0 )
		return;

#if ENABLE_STORE_SIMULATION
    for( NSString *featureId in featureIdList )
        [_featureIdList addObject:featureId];	
    return;
#endif
    
    // Can't start a new request if a current request is pending
	if( _fetechProductRequest != nil )
		return;
	
    // We make sure to update the product list at least once a day.
    bool forceUpdate = (_productListLastUpdatedDate == nil || ![_productListLastUpdatedDate isToday]) ? YES : NO;
        
    // If we arn't forcing an update and we have a complete list of feature IDs we can skip the
    // updating of product list request.
    if( !forceUpdate  &&  [featureIdList isSubsetOfSet:_featureIdList] )
    {
        //NSLog( @"FLOStoreManager: Complete featureIdList already loaded." );
        return;
    }
    	
    if( ![featureIdList isEqualToSet:_fetchFeatureRequestedIdList] )
    {
        _fetchFeatureRequestedIdList = [[NSMutableSet alloc] initWithSet:featureIdList];
    }
    
	_fetechProductRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:featureIdList];
	_fetechProductRequest.delegate = self;
	[_fetechProductRequest start];
}





- (void)retryPendingProductRequest
{
    if( _fetechProductRequest )
    {
        [_fetechProductRequest cancel];
        _fetechProductRequest = nil;
        
        if( _fetchFeatureRequestedIdList != nil )
            [FLOUtil dispatchAsyncMainBlock:^{ [self startAsyncFetchOfProductForFeatureList:_fetchFeatureRequestedIdList]; } afterDelayInSeconds:60];
    }
}




// Callback for startAsyncFetchOfProductForFeatureList gets called in context of the "main" thread
//
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{	
    bool productRequestRetry = NO;
        
    // None where successful, something must be wrong
    if( response.products.count == 0 )  
        productRequestRetry = YES;
    
    if( response.invalidProductIdentifiers.count > 0 )
        NSLog( @"FLOStoreManager: productsRequest invalidProductIdentifiers %@", [response invalidProductIdentifiers] );
    
    if( response.products.count > 0 )
    {
        _productListLastUpdatedDate = [[NSDate alloc] init];
        
        for( SKProduct *product in response.products )
        {
            NSString *productId = [product productIdentifier];

            NSLog( @"product found: %@", productId );
            if( productId != nil )
            {
                [_featureIdList addObject:productId];
                [_productDict setObject:product forKey:productId];                    
            }
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:kFeatureListReady object:response];
    }		

    //
    // Release the fetech stuff iff we arn't going to retry the request
    if( productRequestRetry )
        [self retryPendingProductRequest];
    else
    {
        [_fetechProductRequest cancel];
        _fetechProductRequest = nil;
        
        _fetchFeatureRequestedIdList = nil;
    }
}




- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog( @"FLOStoreManager: productsRequest failed %@", error );
    [self retryPendingProductRequest];
}



+ (void)dumpProductResponse:(SKProductsResponse *)response
{
    NSLog( @"FLOStoreManager: dumpProductResponse" );
    
	for( SKProduct *product in response.products )
	{
		NSString  *featureStr = [product localizedTitle];
		float      price      = [[product price] doubleValue];
		NSString  *productId  = [product productIdentifier];
		
		NSLog(@"Feature: %@, Cost: %f, ID: %@", featureStr, price, productId );
	}
	
	for( NSString *invalidProductId in response.invalidProductIdentifiers )
	{
		NSLog(@"productId: %@ is invalid", invalidProductId );
	}	
}



// Caller should register with the notification center to receive kFeaturePurchased and kFeaturePurchasedFailed
//
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchasedFeature:) name:kFeaturePurchased object:nil];			
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchasedFeatureFailed:) name:kFeaturePurchasedFailed object:nil];
//
//		The featureId will be passed as the notification object.
//
//			- (void)purchasedFeature:(NSNotification *)notification
//			{
//				if( notification == nil  ||  ![[notification object] isKindOfClass:[NSString class]] )
//					return;
//				...
//			}
//
- (void)startAsyncPurchaseOfFeature:(NSString*)featureId
{
	#if ENABLE_STORE_SIMULATION
		if( featureId != nil )
		{
            if( ![_featureIdProcessingPurchaseList containsObject:featureId] )
            {
                [_featureIdProcessingPurchaseList addObject:featureId];

                [FLOUtil dispatchAsyncMainBlock:^
                {
                    [_featureIdProcessingPurchaseList removeObject:featureId];
                    
                    if( [self setPurchased:featureId] )
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFeaturePurchased object:featureId];

                    
                } afterDelayInSeconds:4.0];
            }
		}
		return;
	#endif
	
	if( ![self isFeatureIdRegistered:featureId] )
		return;
	
	if( [SKPaymentQueue canMakePayments] )
	{
        [_featureIdProcessingPurchaseList addObject:featureId];
        
        SKProduct *product = [_productDict objectForKey:featureId]; 
        SKPayment *payment = nil;
        
        if( product == nil )
        {
            NSLog( @"FLOStoreManager product shouldn't be nil for featureId %@", featureId );
            //payment = [SKPayment paymentWithProductIdentifier:featureId];
        }
        else
        {
            payment = [SKPayment paymentWithProduct:product];
        }

        if( payment != nil )
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        else
            NSLog( @"FLOStoreManager: payment request is nil!" );
	}
	else
	{
		NSString    *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
		UIAlertView *alert   = [[UIAlertView alloc] initWithTitle:appName message:@"You are not authorized to purchase from AppStore"
													     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
}




// Called when transaction succedded
//
- (bool)successfulPurchaseTransaction:(SKPaymentTransaction *)originalTransaction;
{
	NSString  *featureId	   = originalTransaction.payment.productIdentifier;
	SKPayment *payment		   = [originalTransaction payment];
	NSDate	  *transactionDate = [originalTransaction transactionDate];
	
	NSLog( @"Feature '%@' purchased on %@ with quantity %d", featureId, transactionDate, [payment quantity] );
	
    if( featureId != nil )
    {
        [_featureIdProcessingPurchaseList removeObject:featureId];
        
        if( [self respondsToSelector:@selector(trackPurchaseForFeatureId:)] )
            [self performSelector:@selector(trackPurchaseForFeatureId:) withObject:featureId];
        
        if( [self setPurchased:featureId] )
            [[NSNotificationCenter defaultCenter] postNotificationName:kFeaturePurchased object:featureId];
    }

	return featureId == nil ? NO : YES;
}




// Called when transaction failed
//
- (void)failedPurchaseTransaction:(SKPaymentTransaction *)transaction		
{
	NSLog( @"FLOStoreManager: failedPurchaseTransaction feature=%@ code=%@ transaction=%@", transaction.payment.productIdentifier, transaction.error, transaction.payment );

	if( transaction.error.code != SKErrorPaymentCancelled )		
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Complete Purchase" message:[transaction.error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
    
    NSString *featureId = transaction.payment.productIdentifier;
    if( featureId != nil )
    {
        [_featureIdProcessingPurchaseList removeObject:featureId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFeaturePurchasedFailed object:featureId];
    }
}




- (bool)processPaymentTransaction:(SKPaymentTransaction *)paymentTransaction
{
    if( paymentTransaction == nil  ||  paymentTransaction.transactionState == SKPaymentTransactionStatePurchasing )
        return NO;

    if( paymentTransaction.transactionState == SKPaymentTransactionStateFailed )
    {
        [self failedPurchaseTransaction:paymentTransaction];
    }
    else
    {
        SKPaymentTransaction *originalTransaction = (paymentTransaction.transactionState == SKPaymentTransactionStateRestored) ?  paymentTransaction.originalTransaction : paymentTransaction;
        if( originalTransaction  !=  nil )
        {
            _lastPaymentTransaction = paymentTransaction;
            [self successfulPurchaseTransaction:originalTransaction];
        }
        else
            NSLog( @"FLOStoreManager processPaymentTransaction has nil transaction." );
    }
    
    return YES; // Done processing the transaction, remove transaction from queue
}



// This will get called in the context of the "main" thread!
//		bool mainThreadFlag = [NSThread isMainThread];
//
//	http://stackoverflow.com/questions/1042640/design-tips-for-storekit-in-iphone-os-3-0
//
// Might want to implement restoreCompletedTransactions
//	http://stackoverflow.com/questions/1757467/when-to-use-restorecompletedtransactions-for-in-app-purchases
//
// Consumeable stuff
//  http://developer.anscamobile.com/forum/2011/01/28/app-purchase-already-purchased
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{    
	for( SKPaymentTransaction *foundTransaction in transactions )
	{
        if( [self processPaymentTransaction:foundTransaction] )
        {
            [[SKPaymentQueue defaultQueue] finishTransaction:foundTransaction];
        }
	}	
}




#pragma mark - Transaction Details



// Not this will only return recently purchased payment details.  If the app exists
- (SKPaymentTransaction *)lastPaymentTransaction
{
    return _lastPaymentTransaction;
}




#pragma mark - Restore Completed Transactions




- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


// We don't need to do anything as this is called after the queue has been processed
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	NSLog( @"paymentQueueRestoreCompletedTransactionsFinished" );
    [[NSNotificationCenter defaultCenter] postNotificationName:kPurchaseRestoredCompleted object:nil];
}



- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	NSLog( @"restoreCompletedTransactionsFailedWithError: %@", error );
    [[NSNotificationCenter defaultCenter] postNotificationName:kPurchaseRestoredCompleted object:error];
}







@end


