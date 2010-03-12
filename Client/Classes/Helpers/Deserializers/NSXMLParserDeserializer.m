//
//  NSXMLParserDeserializer.m
//  Client
//
//  Created by Adrian on 3/2/10.
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

#import "NSXMLParserDeserializer.h"

@interface NSXMLParserDeserializer ()
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *array;
@property (nonatomic, copy) NSString *currentElement;
@property (nonatomic, retain) NSMutableDictionary *currentItem;
@end

@implementation NSXMLParserDeserializer

@synthesize parser = _parser;
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
    self.parser = nil;
    
    self.currentElement = nil;
    self.currentItem = nil;
    [super dealloc];
}

- (void)startDeserializing:(id)data
{
    [self startTimer];
    self.parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
    self.array = [NSMutableArray array];

    [self.parser setDelegate:self];
    [self.parser setShouldProcessNamespaces:NO];
    [self.parser setShouldReportNamespacePrefixes:NO];
    [self.parser setShouldResolveExternalEntities:NO];
    [self.parser parse];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict
{
	self.currentElement = [[elementName copy] autorelease];
    
    if ([self.currentElement isEqualToString:@"person"])
    {
        self.currentItem = [NSMutableDictionary dictionary];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"person"]) 
    {
        [self.array addObject:self.currentItem];
        self.currentItem = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSMutableString *field = [self.currentItem objectForKey:self.currentElement];
    if (field == nil)
    {
        field = [NSMutableString string];
        [self.currentItem setObject:field forKey:self.currentElement];
    }
    [field appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser 
{
    [self stopTimer];
    if ([self.delegate respondsToSelector:@selector(deserializer:didFinishDeserializing:)])
    {
        [self.delegate deserializer:self didFinishDeserializing:self.array];
    }
}

@end
