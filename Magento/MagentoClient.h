//
//  MagentoClient.h
//
//  Created by Rex Sheng on 9/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void (^MagentoRequestSuccess) (id responseObject);
typedef void (^MagentoRequestError) (NSError *error);

@interface MagentoClient : AFHTTPSessionManager

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(MagentoRequestSuccess)success
         failure:(MagentoRequestError)failure;

@end
