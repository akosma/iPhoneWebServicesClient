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
@end

@implementation NSXMLParserDeserializer

@synthesize parser = _parser;
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
    self.parser = nil;
    
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

- (void)parserDidStartDocument:(NSXMLParser *)parser 
{
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict
{
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

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
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

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
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

- (void)parserDidEndDocument:(NSXMLParser *)parser 
{
    if ([self.delegate respondsToSelector:@selector(deserializer:didFinishDeserializing:)])
    {
        [self.delegate deserializer:self didFinishDeserializing:self.array];
    }
}

@end
