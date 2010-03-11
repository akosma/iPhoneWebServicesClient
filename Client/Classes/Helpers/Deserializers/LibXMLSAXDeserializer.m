//
//  LibXMLSAXDeserializer.m
//  Client
//
//  Created by Adrian on 3/11/10.
//  Copyright (c) 2010, akosma software / Adrian Kosmaczewski
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//  must display the following acknowledgement:
//  This product includes software developed by akosma software.
//  4. Neither the name of the akosma software nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ADRIAN KOSMACZEWSKI ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL ADRIAN KOSMACZEWSKI BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "LibXMLSAXDeserializer.h"

struct _xmlSAX2Attributes {
    const xmlChar* localname;
    const xmlChar* prefix;
    const xmlChar* uri;
    const xmlChar* value;
    const xmlChar* end;
};
typedef struct _xmlSAX2Attributes xmlSAX2Attributes;

@interface LibXMLSAXDeserializer ()
@property (nonatomic, retain) NSMutableArray *array;
@property (nonatomic, copy) NSString *currentElement;
@property (nonatomic, retain) NSMutableString *currentEntryId;
@property (nonatomic, retain) NSMutableString *currentFirstName;
@property (nonatomic, retain) NSMutableString *currentLastName;
@property (nonatomic, retain) NSMutableString *currentPhone;
@property (nonatomic, retain) NSMutableString *currentEmail;
@property (nonatomic, retain) NSMutableString *currentAddress;
@property (nonatomic, retain) NSMutableString *currentCity;
@property (nonatomic, retain) NSMutableString *currentZip;
@property (nonatomic, retain) NSMutableString *currentState;
@property (nonatomic, retain) NSMutableString *currentCountry;
@property (nonatomic, retain) NSMutableString *currentDescription;
@property (nonatomic, retain) NSMutableString *currentPassword;
@property (nonatomic, retain) NSMutableString *currentCreatedOn;
@property (nonatomic, retain) NSMutableString *currentModifiedOn;

- (void)elementFound:(const xmlChar *)localname prefix:(const xmlChar *)prefix 
                 uri:(const xmlChar *)URI namespaceCount:(int)namespaceCount
          namespaces:(const xmlChar **)namespaces attributeCount:(int)attributeCount 
defaultAttributeCount:(int)defaultAttributeCount attributes:(xmlSAX2Attributes *)attributes;
- (void)endElement:(const xmlChar *)localname prefix:(const xmlChar *)prefix uri:(const xmlChar *)URI;
- (void)charactersFound:(const xmlChar *)characters length:(int)length;
- (void)endDocument;
@end

#pragma mark -
#pragma mark SAX Parsing Callbacks

// The libxml SAX code in this class was adapted from Bill Dudney's project here:
// http://bill.dudney.net/roller/objc/entry/libxml2_push_parsing

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix,
                            const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces,
                            int nb_attributes, int nb_defaulted, const xmlChar **attributes) 
{
    [((LibXMLSAXDeserializer *)ctx) elementFound:localname prefix:prefix uri:URI 
                             namespaceCount:nb_namespaces namespaces:namespaces
                             attributeCount:nb_attributes defaultAttributeCount:nb_defaulted
                                 attributes:(xmlSAX2Attributes*)attributes];
}

static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI) 
{    
    [((LibXMLSAXDeserializer *)ctx) endElement:localname prefix:prefix uri:URI];
}

static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len) 
{
    [((LibXMLSAXDeserializer *)ctx) charactersFound:ch length:len];
}

static void endDocumentSAX(void *ctx) 
{
    [((LibXMLSAXDeserializer *)ctx) endDocument];
}

static xmlSAXHandler simpleSAXHandlerStruct = {
    NULL,                       // internalSubset
    NULL,                       // isStandalone
    NULL,                       // hasInternalSubset
    NULL,                       // hasExternalSubset
    NULL,                       // resolveEntity
    NULL,                       // getEntity
    NULL,                       // entityDecl
    NULL,                       // notationDecl
    NULL,                       // attributeDecl
    NULL,                       // elementDecl
    NULL,                       // unparsedEntityDecl
    NULL,                       // setDocumentLocator
    NULL,                       // startDocument
    endDocumentSAX,             // endDocument
    NULL,                       // startElement
    NULL,                       // endElement
    NULL,                       // reference
    charactersFoundSAX,         // characters
    NULL,                       // ignorableWhitespace
    NULL,                       // processingInstruction
    NULL,                       // comment
    NULL,                       // warning
    NULL,                       // error
    NULL,                       // fatalError //: unused error() get all the errors
    NULL,                       // getParameterEntity
    NULL,                       // cdataBlock
    NULL,                       // externalSubset
    XML_SAX2_MAGIC,             // initialized? not sure what it means just do it
    NULL,                       // private
    startElementSAX,            // startElementNs
    endElementSAX,              // endElementNs
    NULL,                       // serror
};

@implementation LibXMLSAXDeserializer

@synthesize array = _array;

@synthesize currentElement = _currentElement;
@synthesize currentEntryId = _currentEntryId;
@synthesize currentFirstName = _currentFirstName;
@synthesize currentLastName = _currentLastName;
@synthesize currentPhone = _currentPhone;
@synthesize currentEmail = _currentEmail;
@synthesize currentAddress = _currentAddress;
@synthesize currentCity = _currentCity;
@synthesize currentZip = _currentZip;
@synthesize currentState = _currentState;
@synthesize currentCountry = _currentCountry;
@synthesize currentDescription = _currentDescription;
@synthesize currentPassword = _currentPassword;
@synthesize currentCreatedOn = _currentCreatedOn;
@synthesize currentModifiedOn = _currentModifiedOn;

- (id)init
{
    if (self = [super init])
    {
        self.isAsynchronous = YES;
    }
    return self;
}

- (void)dealloc
{
    self.array = nil;
    
    self.currentEntryId = nil;
    self.currentElement = nil;
    self.currentFirstName = nil;
    self.currentLastName = nil;
    self.currentPhone = nil;
    self.currentEmail = nil;
    self.currentAddress = nil;
    self.currentCity = nil;
    self.currentZip = nil;
    self.currentState = nil;
    self.currentCountry = nil;
    self.currentDescription = nil;
    self.currentPassword = nil;
    self.currentCreatedOn = nil;
    self.currentModifiedOn = nil;
    [super dealloc];
}

- (void)startDeserializing:(id)data
{
    [self startTimer];
    self.array = [NSMutableArray array];
    _xmlParserContext = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);

    // Signal the context that parsing is complete by passing "1" as the last parameter.
    xmlParseChunk(_xmlParserContext, (const char *)[data bytes], [data length], 1);
}

#pragma mark -
#pragma mark Private methods

- (void)elementFound:(const xmlChar *)localname prefix:(const xmlChar *)prefix 
                 uri:(const xmlChar *)URI namespaceCount:(int)namespaceCount
          namespaces:(const xmlChar **)namespaces attributeCount:(int)attributeCount 
defaultAttributeCount:(int)defaultAttributeCount attributes:(xmlSAX2Attributes *)attributes
{
    NSString *elementName = [NSString stringWithCString:(const char *)localname 
                                               encoding:NSUTF8StringEncoding];
	self.currentElement = [[elementName copy] autorelease];
    
    if ([self.currentElement isEqualToString:@"person"])
    {
        self.currentEntryId = [NSMutableString string];
        self.currentFirstName = [NSMutableString string];
        self.currentLastName = [NSMutableString string];
        self.currentPhone = [NSMutableString string];
        self.currentEmail = [NSMutableString string];
        self.currentAddress = [NSMutableString string];
        self.currentCity = [NSMutableString string];
        self.currentZip = [NSMutableString string];
        self.currentState = [NSMutableString string];
        self.currentCountry = [NSMutableString string];
        self.currentDescription = [NSMutableString string];
        self.currentPassword = [NSMutableString string];
        self.currentCreatedOn = [NSMutableString string];
        self.currentModifiedOn = [NSMutableString string];
    }
}

- (void)charactersFound:(const xmlChar *)characters length:(int)length
{
    NSString *string = [[NSString alloc] initWithBytes:(const void *)characters
                                                length:length
                                              encoding:NSUTF8StringEncoding];
    if ([self.currentElement isEqualToString:@"entryId"]) 
    {
        [self.currentEntryId appendString:string];
    } 
    else if ([self.currentElement isEqualToString:@"firstName"]) 
    {
        [self.currentFirstName appendString:string];
    } 
    else if ([self.currentElement isEqualToString:@"lastName"]) 
    {
        [self.currentLastName appendString:string];
    } 
    else if ([self.currentElement isEqualToString:@"phone"])
    {
        [self.currentPhone appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"email"]) 
    {
        [self.currentEmail appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"address"])
    {
        [self.currentAddress appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"city"])
    {
        [self.currentCity appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"zip"])
    {
        [self.currentZip appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"state"])
    {
        [self.currentState appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"country"])
    {
        [self.currentCountry appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"description"])
    {
        [self.currentDescription appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"password"])
    {
        [self.currentPassword appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"createdOn"])
    {
        [self.currentCreatedOn appendString:string];
    }
    else if ([self.currentElement isEqualToString:@"modifiedOn"])
    {
        [self.currentModifiedOn appendString:string];
    }
}

- (void)endElement:(const xmlChar *)localname prefix:(const xmlChar *)prefix uri:(const xmlChar *)URI
{
    NSString *elementName = [NSString stringWithCString:(const char *)localname 
                                               encoding:NSUTF8StringEncoding];
    if ([elementName isEqualToString:@"person"]) 
    {
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        [item setObject:self.currentEntryId forKey:@"entryId"];
        [item setObject:self.currentFirstName forKey:@"firstName"];
        [item setObject:self.currentLastName forKey:@"lastName"];
        [item setObject:self.currentPhone forKey:@"phone"];
        [item setObject:self.currentEmail forKey:@"email"];
        [item setObject:self.currentAddress forKey:@"address"];
        [item setObject:self.currentCity forKey:@"city"];
        [item setObject:self.currentZip forKey:@"zip"];
        [item setObject:self.currentState forKey:@"state"];
        [item setObject:self.currentCountry forKey:@"country"];
        [item setObject:self.currentDescription forKey:@"description"];
        [item setObject:self.currentPassword forKey:@"password"];
        [item setObject:self.currentCreatedOn forKey:@"createdOn"];
        [item setObject:self.currentModifiedOn forKey:@"modifiedOn"];
        
        [self.array addObject:item];
    }
}

-(void)endDocument
{
    [self stopTimer];
    if ([self.delegate respondsToSelector:@selector(deserializer:didFinishDeserializing:)])
    {
        [self.delegate deserializer:self didFinishDeserializing:self.array];
    }
}

@end
