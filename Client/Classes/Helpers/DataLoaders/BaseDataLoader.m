//
//  BaseDataLoader.m
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

#import "BaseDataLoader.h"
#import "ASIHTTPRequestDataLoader.h"
#import "NSURLConnectionDataLoader.h"
#import "SOAPDataLoader.h"
#import "Definitions.h"

@implementation BaseDataLoader

@synthesize deserializer = _deserializer;
@synthesize data = _data;
@synthesize delegate = _delegate;
@synthesize url = _url;
@synthesize error = _error;
@synthesize interval = _interval;
@synthesize baseURLString = _baseURLString;
@synthesize limit = _limit;

+ (id<DataLoader>)loaderWithMechanism:(LoaderMechanism)mechanism
{
    BaseDataLoader *loader = nil;
    switch (mechanism) 
    {
        case LoaderMechanismNSURLConnection:
        {
            loader = [NSURLConnectionDataLoader loader];
            break;
        }
            
        case LoaderMechanismASIHTTPRequest:
        {
            loader = [ASIHTTPRequestDataLoader loader];
            break;
        }
            
        case LoaderMechanismSOAP:
        {
            loader = [SOAPDataLoader loader];
            break;
        }

        default:
            break;
    }
    return loader;
}

+ (id<DataLoader>)loader
{
    return [[[[self class] alloc] init] autorelease];
}

- (id)init
{
    if (self = [super init])
    {
        self.limit = 300;
        NSString *baseURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"server_url"];
        self.baseURLString = [NSString stringWithFormat:@"%@/index.php", baseURL];
    }
    return self;
}

- (void)dealloc
{
    self.baseURLString = nil;
    self.error = nil;
    self.delegate = nil;
    self.deserializer = nil;
    self.data = nil;
    self.url = nil;
    [super dealloc];
}

- (void)loadData
{
    NSString *format = [self.deserializer formatIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@?format=%@&limit=%d", self.baseURLString, format, self.limit];
    self.url = [NSURL URLWithString:urlString];
    self.interval = [NSDate timeIntervalSinceReferenceDate];
    
    // Template method, to be overridden by subclasses
    [self performAsynchronousLoading];
}

- (void)performAsynchronousLoading
{
}

- (void)ready
{
    // This method must be called by subclasses at the end of the
    // asynchronous network call
    self.interval = [NSDate timeIntervalSinceReferenceDate] - self.interval;
    if (self.deserializer.isAsynchronous)
    {
        self.deserializer.delegate = self;
        [self.deserializer startDeserializing:self.data];
    }
    else
    {
        NSArray *array = [self.deserializer deserializeData:self.data];
        [self.delegate dataLoader:self didLoadData:array];
    }
}

#pragma mark -
#pragma mark DeserializerDelegate methods

- (void)deserializer:(id<Deserializer>)deserializer didFinishDeserializing:(NSArray *)array
{
    [self.delegate dataLoader:self didLoadData:array];
}

@end
