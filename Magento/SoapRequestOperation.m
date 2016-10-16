//
//  SoapRequestOperation.m
//
//  Created by Rex Sheng on 9/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "SoapRequestOperation.h"
#import "TouchXML.h"
#import "NSObject+Soap.h"

@interface CXMLNode (Magento)

@end

@implementation CXMLNode (Magento)

- (CXMLNode *)nodeWithName:(NSString *)name
{
    for(CXMLNode *child in [self children]) {
        if([child respondsToSelector:@selector(name)] && [[child name] isEqual:name]) {
            return child;
        }
    }
    CXMLNode *found = nil;
    for(CXMLNode *child in [self children]) {
        CXMLNode* el = [child nodeWithName:name];
        if(el != nil) {
            found = el;
            break;
        }
    }
    return found;
}

@end

@implementation SoapRequestOperation

@end
