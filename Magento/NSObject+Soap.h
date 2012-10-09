//
//  NSObject+Soap.h
//
//  Created by Rex Sheng on 9/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CXMLElement;

@interface NSObject (Soap)

- (NSString *)serialize;
- (NSString *)serialize:(NSString **)xsi;
- (NSString *)serializeWithNodeName:(NSString *)name;
+ (id)deserialize:(CXMLElement *)root;
- (BOOL)isFault:(NSError **)error;

@end
