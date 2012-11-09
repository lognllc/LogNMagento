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

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
							  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
	self.completionBlock = ^ {
		if (self.isCancelled) {
			return;
		}
		
		if (self.error) {
			if (failure) {
				dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
					failure(self, self.error);
				});
			}
		} else {
			__autoreleasing NSError *error = nil;
			CXMLDocument *doc = [[CXMLDocument alloc] initWithData:self.responseData options:0 error:&error];
			if(doc == nil) {
				if (failure) {
					dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
						failure(self, self.error);
					});
				}
				return;
			}
			CXMLNode *body = [[doc rootElement] nodeWithName:@"SOAP-ENV:Body"];
			CXMLNode *root = [body childAtIndex:0];
			
			if([root.name isEqualToString:@"SOAP-ENV:Fault"]) {
				if (failure) {
					int code = [[root childAtIndex:0].stringValue intValue];
					NSString *message = [root childAtIndex:1].stringValue;
					dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
						NSError *error = [[NSError alloc] initWithDomain:@"Magento" code:code userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(message, nil) }];
						failure(self, error);
					});
				}
				return;
			}
			root = [root childAtIndex:0];
			id output = [NSObject deserialize:(CXMLElement *)root];
			NSString *type = [[(CXMLElement *)root attributeForName:@"xsi:type"] stringValue];
			if ([type isEqualToString:@"SOAP-ENC:Array"]) {
				output = [NSObject deserialize:(CXMLElement *)root];
			} else if ([type isEqualToString:@"ns2:Map"]) {
				output = [NSDictionary deserialize:(CXMLElement *)root];
			} else if ([type isEqualToString:@"xsd:string"]) {
				output = root.stringValue;
			} else if ([type isEqualToString:@"xsd:int"]) {
				output = @([root.stringValue intValue]);
			} else if ([type isEqualToString:@"xsd:boolean"]) {
				output = @([root.stringValue boolValue]);
			}
			if (success) {
				dispatch_async(self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
					success(self, output);
				});
			}
		}
	};
#pragma clang diagnostic pop
}

@end
