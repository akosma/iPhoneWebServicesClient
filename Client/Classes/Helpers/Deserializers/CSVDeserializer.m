//
//  CSVDeserializer.m
//  Client
//
//  Created by Adrian on 3/4/10.
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

#import "CSVDeserializer.h"
#import "parseCSV.h"

#define FILE_NAME @"csvdata.csv"

@implementation CSVDeserializer

- (NSArray *)performDeserialization:(id)data
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *fileName = [basePath stringByAppendingPathComponent:FILE_NAME];
    [data writeToFile:fileName atomically:YES];
    
    CSVParser *parser = [[CSVParser alloc] init];
    [parser openFile:fileName];
    NSArray *csvContents = [parser parseFile];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[csvContents count]];
    for (NSArray *item in csvContents) 
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[item count]];
        [dict setObject:[item objectAtIndex:0] forKey:@"entryId"];
        [dict setObject:[item objectAtIndex:1] forKey:@"firstName"];
        [dict setObject:[item objectAtIndex:2] forKey:@"lastName"];
        [dict setObject:[item objectAtIndex:3] forKey:@"phone"];
        [dict setObject:[item objectAtIndex:4] forKey:@"email"];
        [dict setObject:[item objectAtIndex:5] forKey:@"address"];
        [dict setObject:[item objectAtIndex:6] forKey:@"city"];
        [dict setObject:[item objectAtIndex:7] forKey:@"zip"];
        [dict setObject:[item objectAtIndex:8] forKey:@"state"];
        [dict setObject:[item objectAtIndex:9] forKey:@"country"];
        [dict setObject:[item objectAtIndex:10] forKey:@"description"];
        [dict setObject:[item objectAtIndex:11] forKey:@"password"];
        [dict setObject:[item objectAtIndex:12] forKey:@"createdOn"];
        [dict setObject:[item objectAtIndex:13] forKey:@"modifiedOn"];
        [result addObject:dict];
    }
    [parser closeFile];
    [parser release];
    return result;
}

- (NSString *)formatIdentifier
{
    return @"csv";
}

@end
