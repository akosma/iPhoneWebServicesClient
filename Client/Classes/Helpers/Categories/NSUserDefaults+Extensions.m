//
//  NSUserDefaults+Extensions.m
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

#import "NSUserDefaults+Extensions.h"

#define SERVER_URL_KEY @"server_url"
#define BENCHMARK_MAXIMUM_KEY @"benchmark_maximum"
#define BENCHMARK_INCREMENT_KEY @"benchmark_increment"
#define SLIDER_VALUE_KEY @"slider_value"

@implementation NSUserDefaults (Extensions)

@dynamic serverURL;
@dynamic benchmarkMaximum;
@dynamic benchmarkIncrement;
@dynamic sliderValue;

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
    if ([self objectForKey:SLIDER_VALUE_KEY] == nil)
    {
        self.sliderValue = 300;
    }
}

- (NSString *)serverURL
{
    return [self stringForKey:SERVER_URL_KEY];
}

- (void)setServerURL:(NSString *)urlString
{
    [self setObject:urlString forKey:SERVER_URL_KEY];
    [self synchronize];
}

- (NSInteger)benchmarkMaximum
{
    return [self integerForKey:BENCHMARK_MAXIMUM_KEY];
}

- (void)setBenchmarkMaximum:(NSInteger)value
{
    [self setInteger:value forKey:BENCHMARK_MAXIMUM_KEY];
    [self synchronize];
}

- (NSInteger)benchmarkIncrement
{
    return [self integerForKey:BENCHMARK_INCREMENT_KEY];
}

- (void)setBenchmarkIncrement:(NSInteger)value
{
    [self setInteger:value forKey:BENCHMARK_INCREMENT_KEY];
    [self synchronize];
}

- (NSInteger)sliderValue
{
    return [self integerForKey:SLIDER_VALUE_KEY];
}

- (void)setSliderValue:(NSInteger)value
{
    [self setInteger:value forKey:SLIDER_VALUE_KEY];
    [self synchronize];
}

@end
