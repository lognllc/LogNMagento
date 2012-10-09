//
//  NSObject+Soap.m
//
//  Created by Rex Sheng on 9/17/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import "NSObject+Soap.h"
#import "TouchXML.h"

NSString * const XSI_TYPE = @"xsi:type";
NSString * const XSD_Int = @"xsd:int";
NSString * const XSD_Boolean = @"xsd:boolean";
NSString * const XSD_String = @"xsd:string";
NSString * const XSD_Array = @"SOAP-ENC:Array";
NSString * const XSD_Dictionary = @"ns2:Map";

@implementation NSObject (Soap)

- (NSString *)serialize
{
	return [self serialize:nil];
}

- (NSString *)serialize:(NSString **)xsi
{
	NSString *serialize = nil;
	if ([self isKindOfClass:[NSNumber class]]) {
		if (xsi) { *xsi = XSD_Int; }
	} else if ([self isKindOfClass:[NSString class]]) {
		if (xsi) { *xsi = XSD_String; }
	} else if ([self isKindOfClass:[NSArray class]]) {
		if (xsi) { *xsi = XSD_Array; }
		serialize = [self serialize_array];
	} else if ([self isKindOfClass:[NSDictionary class]]) {
		if (xsi) { *xsi = XSD_Dictionary; }
		serialize = [self serialize_dictionary];
	}
	if (!serialize) {
		serialize = [self description];
	}
	return serialize;
}

- (NSString *)serializeWithNodeName:(NSString *)name
{
	NSString *xsi = XSD_String;
	NSString *serialize = [self serialize:&xsi];
	return [NSString stringWithFormat:@"<%@ xsi:type=\"%@\">%@</%@>", name, xsi, serialize, name];
}

- (NSString *)serialize_array
{
	NSMutableString *s = [NSMutableString string];
	for (id obj in (NSArray *)self) {
		NSString *xsi = nil;
		NSString *serialize = [obj serialize:&xsi];
		if (xsi) {
			[s appendFormat:@"<item xsi:type=\"%@\">%@</item>", xsi, serialize];
		} else {
			[s appendFormat:@"<item>%@</item>", serialize];
		}
	}
	return s;
}

- (NSString *)serialize_dictionary
{
	NSMutableString *s = [NSMutableString string];
	[(NSDictionary *)self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		NSString *xsi = nil;
		NSString *text = [obj serialize:&xsi];
		if (xsi) {
			[s appendFormat:@"<item><key xsi:type=\"xsd:string\">%@</key><value xsi:type=\"%@\">%@</value></item>", key, xsi, text];
		} else {
			[s appendFormat:@"<item><key xsi:type=\"xsd:string\">%@</key><value>%@</value></item>", key, text];
		}
	}];
	return s;
}

+ (id)deserialize:(CXMLElement *)root
{
	NSString *type = [[root attributeForName:XSI_TYPE] stringValue];
	if ([type isEqualToString:XSD_Array] || [type isEqualToString:@"ns1:FixedArray"]) {
		return [self deserialize_array:root];
	} else if ([type isEqualToString:XSD_Dictionary]) {
		return [self deserialize_dictionary:root];
	} else if ([type isEqualToString:XSD_Int]) {
		return [NSNumber numberWithInt:[root.stringValue intValue]];
	} else if ([type isEqualToString:XSD_Boolean]) {
		return [NSNumber numberWithBool:[root.stringValue boolValue]];
	} else return root.stringValue;
}

+ (NSArray *)deserialize_array:(CXMLElement *)root
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:root.childCount];
	for (CXMLElement *element in [root children]) {
		[array addObject:[self deserialize:element]];
	}
	return array;
}

- (BOOL)isFault:(NSError **)error
{
	if ([self isKindOfClass:[NSDictionary class]]) {
		NSDictionary *obj = (NSDictionary *)self;
		if ([obj objectForKey:@"isFault"]) {
			if (error) {
				int code = [[obj objectForKey:@"faultCode"] intValue];
				NSString *message = [obj objectForKey:@"faultMessage"];
				*error = [[NSError alloc] initWithDomain:@"Magento" code:code userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(message, nil) }];
			}
			return YES;
		}
	}
	return NO;
}

+ (NSDictionary *)deserialize_dictionary:(CXMLElement *)root
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:root.childCount];
	for (CXMLElement *element in [root children]) {
		if (element.childCount != 2) continue;
		CXMLElement *keyNode = (CXMLElement *)[element childAtIndex:0];
		CXMLElement *valueNode = (CXMLElement *)[element childAtIndex:1];
		
		if ([keyNode.name isEqualToString:@"key"] && [valueNode.name isEqualToString:@"value"]) {
			[dictionary setValue:[self deserialize:valueNode] forKey:keyNode.stringValue];
		}
	}
	return dictionary;
}

@end
