//
//  NSUserDefaults+Extensions.m
//  Client
//
//  Created by Adrian on 3/11/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "NSUserDefaults+Extensions.h"

#define SERVER_URL_KEY @"server_url"
#define BENCHMARK_MAXIMUM_KEY @"benchmark_maximum"
#define BENCHMARK_INCREMENT_KEY @"benchmark_increment"

@implementation NSUserDefaults (Extensions)

@dynamic serverURL;
@dynamic benchmarkMaximum;
@dynamic benchmarkIncrement;

- (void)setDefaultValuesIfRequired
{
    if ([self objectForKey:SERVER_URL_KEY] == nil)
    {
        self.serverURL = @"http://localhost:8888";
    }
    if ([self objectForKey:BENCHMARK_MAXIMUM_KEY] == nil)
    {
        self.benchmarkMaximum = 200;
    }
    if ([self objectForKey:BENCHMARK_INCREMENT_KEY] == nil)
    {
        self.benchmarkIncrement = 50;
    }
}

- (NSString *)serverURL
{
    return [self stringForKey:SERVER_URL_KEY];
}

- (void)setServerURL:(NSString *)urlString
{
    [self setObject:urlString forKey:SERVER_URL_KEY];
}

- (NSInteger)benchmarkMaximum
{
    return [self integerForKey:BENCHMARK_MAXIMUM_KEY];
}

- (void)setBenchmarkMaximum:(NSInteger)value
{
    [self setInteger:value forKey:BENCHMARK_MAXIMUM_KEY];
}

- (NSInteger)benchmarkIncrement
{
    return [self integerForKey:BENCHMARK_INCREMENT_KEY];
}

- (void)setBenchmarkIncrement:(NSInteger)value
{
    [self setInteger:value forKey:BENCHMARK_INCREMENT_KEY];
}

@end
