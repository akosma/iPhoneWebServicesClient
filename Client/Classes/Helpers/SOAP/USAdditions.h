//
//  USAdditions.h
//  WSDLParser
//
//  Created by John Ogle on 9/5/08.
//  Copyright 2008 LightSPEED Technologies. All rights reserved.
//  Modified by Matthew Faupel on 2009-05-06 to use NSDate instead of NSCalendarDate (for iPhone compatibility).
//  Modifications copyright (c) 2009 Micropraxis Ltd.
//  NSData (MBBase64) category taken from "MiloBird" at http://www.cocoadev.com/index.pl?BaseSixtyFour
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@interface NSArray (USAdditions)

+ (NSArray *)deserializeNode:(xmlNodePtr)cur;

@end

@interface NSString (USAdditions)

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName;
+ (NSString *)deserializeNode:(xmlNodePtr)cur;

@end

@interface NSNumber (USAdditions)

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName;
+ (NSNumber *)deserializeNode:(xmlNodePtr)cur;

@end

@interface NSDate (USAdditions)

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName;
+ (NSDate *)deserializeNode:(xmlNodePtr)cur;

@end

@interface NSData (USAdditions)

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName;
+ (NSData *)deserializeNode:(xmlNodePtr)cur;

@end

@interface NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;
@end

@interface USBoolean : NSObject {
	BOOL value;
}

@property (assign) BOOL boolValue;

- (id)initWithBool:(BOOL)aValue;
- (NSString *)stringValue;

- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName;
+ (USBoolean *)deserializeNode:(xmlNodePtr)cur;

@end

@interface SOAPFault : NSObject {
  NSString *faultcode;
  NSString *faultstring;
  NSString *faultactor;
  NSString *detail;
}

@property (nonatomic, retain) NSString *faultcode;
@property (nonatomic, retain) NSString *faultstring;
@property (nonatomic, retain) NSString *faultactor;
@property (nonatomic, retain) NSString *detail;
@property (readonly) NSString *simpleFaultString;

+ (SOAPFault *)deserializeNode:(xmlNodePtr)cur;

@end

