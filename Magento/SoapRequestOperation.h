//
//  SoapRequestOperation.h
//  Hauler Deals
//
//  Created by Rex Sheng on 9/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@interface SoapRequestOperation : AFHTTPRequestOperation

@property (nonatomic, strong) id deserializeTo;

@end