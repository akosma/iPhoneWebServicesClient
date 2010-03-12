//
//  BaseDeserializer.m
//  Client
//
//  Created by Adrian on 3/1/10.
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

#import "BaseDeserializer.h"
#import "TouchJSONDeserializer.h"
#import "SBJSONDeserializer.h"
#import "YAMLDeserializer.h"
#import "BinaryPlistDeserializer.h"
#import "XMLPlistDeserializer.h"
#import "XMLFormattedPlistDeserializer.h"
#import "SOAPDeserializer.h"
#import "NSXMLParserDeserializer.h"
#import "TouchXMLDeserializer.h"
#import "LibXMLDomDeserializer.h"
#import "LibXMLSAXDeserializer.h"
#import "CSVDeserializer.h"
#import "TBXMLDeserializer.h"
#import "KissXMLDeserializer.h"
#import "TinyXMLDeserializer.h"
#import "GoogleXMLDeserializer.h"
#import "APXMLDeserializer.h"
#import "ProtocolBufferDeserializer.h"
#import "AQXMLParserDeserializer.h"

@implementation BaseDeserializer

@synthesize interval = _interval;
@synthesize isAsynchronous = _isAsynchronous;
@synthesize delegate = _delegate;

+ (id<Deserializer>)deserializerForFormat:(DeserializerType)format
{
    id<Deserializer> deserializer = nil;
    switch (format) 
    {
        case DeserializerTypeTouchJSON:
        {
            deserializer = [TouchJSONDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeSBJSON:
        {
            deserializer = [SBJSONDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeYAML:
        {
            deserializer = [YAMLDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeBinaryPlist:
        {
            deserializer = [BinaryPlistDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeXMLPlist:
        {
            deserializer = [XMLPlistDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeXMLFormattedPlist:
        {
            deserializer = [XMLFormattedPlistDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeSOAP:
        {
            deserializer = [SOAPDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeNSXMLParser:
        {
            deserializer = [NSXMLParserDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeTouchXML:
        {
            deserializer = [TouchXMLDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeLibXMLDOM:
        {
            deserializer = [LibXMLDomDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeLibXMLSAX:
        {
            deserializer = [LibXMLSAXDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeCSV:
        {
            deserializer = [CSVDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeTBXML:
        {
            deserializer = [TBXMLDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeKissXML:
        {
            deserializer = [KissXMLDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeTinyXML:
        {
            deserializer = [TinyXMLDeserializer deserializer];
            break;
        }
        
        case DeserializerTypeGoogleXML:
        {
            deserializer = [GoogleXMLDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeAPXML:
        {
            deserializer = [APXMLDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeProtocolBuffer:
        {
            deserializer = [ProtocolBufferDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeAQXMLParser:
        {
            deserializer = [AQXMLParserDeserializer deserializer];
            break;
        }

        default:
            break;
    }
    return deserializer;
}

+ (id<Deserializer>)deserializer
{
    id<Deserializer> obj = [[[[self class] alloc] init] autorelease];
    return obj;
}

- (id)init
{
    if (self = [super init])
    {
        self.isAsynchronous = NO;
    }
    return self;
}

- (NSArray *)deserializeData:(NSData *)data
{
    [self startTimer];
    NSArray *result = [self performDeserialization:data];
    [self stopTimer];
    return result;
}

- (NSArray *)performDeserialization:(NSData *)data
{
    return nil;
}

- (NSString *)formatIdentifier
{
    return nil;
}

- (void)startDeserializing:(NSData *)data
{
}

- (void)startTimer
{
    self.interval = [NSDate timeIntervalSinceReferenceDate];
}

- (void)stopTimer
{
    self.interval = [NSDate timeIntervalSinceReferenceDate] - self.interval;
}

@end
