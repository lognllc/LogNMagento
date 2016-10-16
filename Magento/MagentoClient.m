//
//  MagentoClient.m
//
//  Created by Rex Sheng on 9/16/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "MagentoClient.h"
#import "SoapRequestOperation.h"
#import "NSObject+Soap.h"
#import "TouchXML.h"

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

@interface MagentoClient ()

@property (nonatomic, strong) NSMutableDictionary *defaultHeaders;

@end


@implementation MagentoClient

+ (NSString *)createEnvelope:(NSString *)method forNamespace:(NSString *)ns forParameters:(NSString *)params
{
    NSMutableString *s = [NSMutableString string];
    [s appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
    [s appendFormat:@"<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns1=\"%@\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:ns2=\"http://xml.apache.org/xml-soap\" xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">", ns];
    [s appendString:@"<SOAP-ENV:Body>\n"];
    [s appendFormat:@"<%@>%@</%@>", method, [params stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"], method];
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

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(MagentoRequestSuccess)success
         failure:(MagentoRequestError)failure {
    
    NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        } else {
            NSError *error1 = nil;
            CXMLDocument *doc = [[CXMLDocument alloc] initWithData:responseObject options:0 error:&error];
            if(doc == nil) {
                if (failure) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure(error1);
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error2 = [[NSError alloc] initWithDomain:@"Magento" code:code userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(message, nil) }];
                        failure(error2);
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(output);
                });
            }
        }
        
    }];
    
    [dataTask resume];
}

@end
