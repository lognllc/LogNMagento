//
//  HDHaulerDealsService.h
//  Hauler Deals
//
//  Created by Rex Sheng on 9/5/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Soap.h"

#ifndef MAGENTO_BASE_URL
#warning "You need define your MAGENTO_BASE_URL in your .pch"
#define MAGENTO_BASE_URL @""
#endif
#ifndef MAGENTO_USERNAME
#warning "You need define your MAGENTO_USERNAME in your .pch"
#define MAGENTO_USERNAME @""
#endif
#ifndef MAGENTO_API_KEY
#warning "You need define your MAGENTO_API_KEY in your .pch"
#define MAGENTO_API_KEY @""
#endif

@class MagentoClient;
@class AFHTTPRequestOperation;

@interface Magento : NSObject
{
	@protected
	MagentoClient *client;
	@protected
	NSString *sessionID;
}
@property (nonatomic, strong) id customerID;
@property (nonatomic, strong) id customerName;
@property (nonatomic, strong) id storeID;
@property (nonatomic, readonly) id cartID;
@property (nonatomic) NSTimeInterval cacheInterval;

+ (Magento *)service;
- (void)createCart:(void(^)(NSNumber *cart))block;

- (id)cachedResponseForCall:(NSArray *)call;
- (void)cacheResponse:(id)value forCall:(NSArray *)call;
- (void)clearCache;

- (void)inSession:(dispatch_block_t)block;
- (void)renewSession;

+ (void)call:(NSArray *)args success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)multiCall:(NSArray *)args success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)getImage:(NSMutableDictionary *)item completion:(void (^)(NSString *imageURL, BOOL immediate))completion;
+ (void)getImageAndPrice:(NSMutableDictionary *)item completion:(void (^)(BOOL immediate))completion;

@end
