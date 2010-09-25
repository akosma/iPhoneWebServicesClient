//
//  USAdditions.m
//  WSDLParser
//
//  Created by John Ogle on 9/5/08.
//  Copyright 2008 LightSPEED Technologies. All rights reserved.
//  Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
//  Modifications copyright (c) 2009 Micropraxis Ltd.
//  Modified by Henri Asseily on 2009-09-04 for SOAP 1.2 faults
//
//
//  NSData (MBBase64) category taken from "MiloBird" at http://www.cocoadev.com/index.pl?BaseSixtyFour
//

#import "USAdditions.h"
#import "NSDate+ISO8601Parsing.h"
#import "NSDate+ISO8601Unparsing.h"

@implementation NSArray (USAdditions)

+ (NSArray *)deserializeNode:(xmlNodePtr)cur
{
    NSMutableArray *array = [NSMutableArray array];
    for (xmlNodePtr node = cur->children; node != NULL; node = node->next) 
    {
        if(cur->type == XML_ELEMENT_NODE) 
        {
            if(xmlStrEqual(node->name, (const xmlChar *) "item")) 
            {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                for (xmlNodePtr itemnode = node->children; itemnode != NULL; itemnode = itemnode->next) 
                {
                    if(node->type == XML_ELEMENT_NODE) 
                    {
                        [dict setObject:[NSString deserializeNode:itemnode] 
                                 forKey:[NSString stringWithCString:(const char *)itemnode->name 
                                                           encoding:NSUTF8StringEncoding]];
                    }
                }
                [array addObject:dict];
            }
        }
    }
    
    return array;
}

@end


@implementation NSString (USAdditions)

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName
{
	return xmlNewDocNode(doc, NULL, (const xmlChar*)[elName UTF8String], (const xmlChar*)[self UTF8String]);
}

+ (NSString *)deserializeNode:(xmlNodePtr)cur
{
	xmlChar *elementText = xmlNodeListGetString(cur->doc, cur->children, 1);
	NSString *elementString = nil;
	
	if(elementText != NULL) {
		elementString = [NSString stringWithCString:(char*)elementText encoding:NSUTF8StringEncoding];
		xmlFree(elementText);
	}
	
	return elementString;
}

@end

@implementation NSNumber (USAdditions)

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName
{
	return xmlNewDocNode(doc, NULL, (const xmlChar*)[elName UTF8String], (const xmlChar*)[[self stringValue] UTF8String]);
}

+ (NSNumber *)deserializeNode:(xmlNodePtr)cur
{
	NSString *stringValue = [NSString deserializeNode:cur];
	return [NSNumber numberWithDouble:[stringValue doubleValue]];
}

@end

@implementation NSDate (USAdditions)

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName
{
	return xmlNewDocNode(doc, NULL, (const xmlChar*)[elName UTF8String], (const xmlChar*)[[self ISO8601DateString] UTF8String]);
}

+ (NSDate *)deserializeNode:(xmlNodePtr)cur
{
	return [NSDate dateWithString:[NSString deserializeNode:cur]];
}

@end

@implementation NSData (USAdditions)

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName
{
	return xmlNewDocNode(doc, NULL, (const xmlChar*)[elName UTF8String], (const xmlChar*)[[self base64Encoding] UTF8String]);
}

+ (NSData *)deserializeNode:(xmlNodePtr)cur
{
	return [NSData dataWithBase64EncodedString:[NSString deserializeNode:cur]];
}

@end


static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;
{
	if (string == nil)
		[NSException raise:NSInvalidArgumentException format:@""];
	if ([string length] == 0)
		return [NSData data];
	
	static char *decodingTable = NULL;
	if (decodingTable == NULL)
	{
		decodingTable = malloc(256);
		if (decodingTable == NULL)
			return nil;
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++)
			decodingTable[(short)encodingTable[i]] = i;
	}
	
	const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
	if (characters == NULL)     //  Not an ASCII string!
		return nil;
	char *bytes = malloc((([string length] + 3) / 4) * 3);
	if (bytes == NULL)
		return nil;
	NSUInteger length = 0;

	NSUInteger i = 0;
	while (YES)
	{
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++)
		{
			if (characters[i] == '\0')
				break;
			if (isspace(characters[i]) || characters[i] == '=')
				continue;
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
			{
				free(bytes);
				return nil;
			}
		}
		
		if (bufferLength == 0)
			break;
		if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
		{
			free(bytes);
			return nil;
		}
		
		//  Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2)
			bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
		if (bufferLength > 3)
			bytes[length++] = (buffer[2] << 6) | buffer[3];
	}
	
	realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64Encoding;
{
	if ([self length] == 0)
		return @"";

    char *characters = malloc((([self length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [self length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [self length])
			buffer[bufferLength++] = ((char *)[self bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
	
	return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

@end

@implementation USBoolean

@synthesize boolValue=value;

- (id)initWithBool:(BOOL)aValue
{
	self = [super init];
	if(self != nil) {
		value = aValue;
	}
	
	return self;
}

- (NSString *)stringValue
{
	return value ? @"true" : @"false";
}

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName
{
	return xmlNewDocNode(doc, NULL, (const xmlChar*)[elName UTF8String], (const xmlChar*)[[self stringValue] UTF8String]);
}

+ (USBoolean *)deserializeNode:(xmlNodePtr)cur
{
	NSString *stringValue = [NSString deserializeNode:cur];
	
	if([stringValue isEqualToString:@"true"]) {
		return [[[USBoolean alloc] initWithBool:YES] autorelease];
	} else if([stringValue isEqualToString:@"false"]) {
		return [[[USBoolean alloc] initWithBool:NO] autorelease];
	}
	
	return nil;
}

@end

@implementation SOAPFault

@synthesize faultcode, faultstring, faultactor, detail;

+ (SOAPFault *)deserializeNode:(xmlNodePtr)cur
{
	SOAPFault *soapFault = [[SOAPFault new] autorelease];
	NSString *ns = [NSString stringWithCString:(char*)cur->ns->href encoding:NSUTF8StringEncoding];
	if (! ns) return soapFault;
	if ([ns isEqualToString:@"http://schemas.xmlsoap.org/soap/envelope/"]) {
		// soap 1.1
		for( cur = cur->children ; cur != NULL ; cur = cur->next ) {
			if(cur->type == XML_ELEMENT_NODE) {
				if(xmlStrEqual(cur->name, (const xmlChar *) "faultcode")) {
					soapFault.faultcode = [NSString deserializeNode:cur];
				}
				if(xmlStrEqual(cur->name, (const xmlChar *) "faultstring")) {
					soapFault.faultstring = [NSString deserializeNode:cur];
				}
				if(xmlStrEqual(cur->name, (const xmlChar *) "faultactor")) {
					soapFault.faultactor = [NSString deserializeNode:cur];
				}
				if(xmlStrEqual(cur->name, (const xmlChar *) "detail")) {
					soapFault.detail = [NSString deserializeNode:cur];
				}
			}
		}
	} else if ([ns isEqualToString:@"http://www.w3.org/2003/05/soap-envelope"]) {
		// soap 1.2
				
		for( cur = cur->children ; cur != NULL ; cur = cur->next ) {
			if(cur->type == XML_ELEMENT_NODE) {
				if(xmlStrEqual(cur->name, (const xmlChar *) "Code")) {
					xmlNodePtr newcur = cur;
					for ( newcur = newcur->children; newcur != NULL ; newcur = newcur->next ) {
						if(xmlStrEqual(newcur->name, (const xmlChar *) "Value")) {
							soapFault.faultcode = [NSString deserializeNode:newcur];
							break;
						}
					}
					// TODO: Add Subcode handling
				}
				if(xmlStrEqual(cur->name, (const xmlChar *) "Reason")) {
					xmlChar *theReason = xmlNodeGetContent(cur);
					if (theReason != NULL) {
						soapFault.faultstring = [NSString stringWithCString:(char*)theReason encoding:NSUTF8StringEncoding];
						xmlFree(theReason);
					}
				}
				if(xmlStrEqual(cur->name, (const xmlChar *) "Node")) {
					soapFault.faultactor = [NSString deserializeNode:cur];
				}
				if(xmlStrEqual(cur->name, (const xmlChar *) "Detail")) {
					soapFault.detail = [NSString deserializeNode:cur];
				}
				// TODO: Add "Role" ivar
			}
		}
	}
  
	return soapFault;
}

- (NSString *)simpleFaultString
{
        NSString *simpleString = [faultstring stringByReplacingOccurrencesOfString: @"System.Web.Services.Protocols.SoapException: " withString: @""];
        NSRange suffixRange = [simpleString rangeOfString: @"\n   at "];
        
        if (suffixRange.length > 0)
                simpleString = [simpleString substringToIndex: suffixRange.location];
                
        return simpleString;
}

- (void)dealloc
{
        [faultcode release];
        [faultstring release];
        [faultactor release];
        [detail release];
        [super dealloc];
}

@end
