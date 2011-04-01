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
@property (nonatomic, retain) NSMutableDictionary *currentItem;

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
@synthesize currentItem = _currentItem;

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
    self.currentElement = nil;
    self.currentItem = nil;
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
        self.currentItem = [NSMutableDictionary dictionary];
    }
}

- (void)charactersFound:(const xmlChar *)characters length:(int)length
{
    NSString *string = [[NSString alloc] initWithBytes:(const void *)characters
                                                length:length
                                              encoding:NSUTF8StringEncoding];
    NSMutableString *field = [self.currentItem objectForKey:self.currentElement];
    if (field == nil)
    {
        field = [NSMutableString string];
        [self.currentItem setObject:field forKey:self.currentElement];
    }
    [field appendString:string];
    [string release];
}

- (void)endElement:(const xmlChar *)localname prefix:(const xmlChar *)prefix uri:(const xmlChar *)URI
{
    NSString *elementName = [NSString stringWithCString:(const char *)localname 
                                               encoding:NSUTF8StringEncoding];
    if ([elementName isEqualToString:@"person"]) 
    {
        [self.array addObject:self.currentItem];
        self.currentItem = nil;
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
