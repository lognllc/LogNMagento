//
//  MagentoClient.m
//
//  Created by Rex Sheng on 9/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "MagentoClient.h"
#import "SoapRequestOperation.h"
#import "NSObject+Soap.h"

@interface MagentoClient ()

@property (nonatomic, strong) NSMutableDictionary *defaultHeaders;

@end


@implementation MagentoClient

+ (NSString *)createEnvelope:(NSString *)method forNamespace:(NSString *)ns forParameters:(NSString *)params
{
	NSMutableString *s = [NSMutableString string];
	[s appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
	[s appendFormat:@"<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"%@\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:ns2=\"http://xml.apache.org/xml-soap\" xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">", ns];
	[s appendString:@"<SOAP-ENV:Body>"];
	[s appendFormat:@"<%@>%@</%@>", method,[params stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"], method];
	[s appendString:@"</SOAP-ENV:Body>"];
	[s appendString:@"</SOAP-ENV:Envelope>"];
	return s;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
									  path:(NSString *)path
								parameters:(NSDictionary *)parameters
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.baseURL];
	[request setHTTPMethod:method];
	[request setAllHTTPHeaderFields:self.defaultHeaders];
	if (parameters) {
		NSMutableString *params = [NSMutableString string];
		
		[parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[params appendString:[obj serializeWithNodeName:key]];
		}];
		NSString *envelope = [MagentoClient createEnvelope:path forNamespace:@"urn:Magento" forParameters:params];
		[request setHTTPBody:[envelope dataUsingEncoding:NSUTF8StringEncoding]];
	}
	return request;
}

- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
	SoapRequestOperation *operation = [[SoapRequestOperation alloc] initWithRequest:request];
	[operation setCompletionBlockWithSuccess:success failure:failure];
	[self enqueueHTTPRequestOperation:operation];
}

@end
