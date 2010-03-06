//
//  TBXMLDeserializer.m
//  Client
//
//  Created by Adrian on 3/6/10.
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

#import "TBXMLDeserializer.h"
#import "TBXML.h"

@implementation TBXMLDeserializer

- (NSArray *)performDeserialization:(id)data
{
    TBXML *tbxml = [TBXML tbxmlWithXMLData:data];
    TBXMLElement *root = tbxml.rootXMLElement;
    NSMutableArray *array = [NSMutableArray array];
    if (root) 
    {
        TBXMLElement *person = [TBXML childElementNamed:@"person" parentElement:root];
        
        while (person != nil)
        {
            TBXMLElement *attribute = person->firstChild;
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            while (attribute != nil)
            {
                NSString *key = [NSString stringWithCString:attribute->name encoding:NSUTF8StringEncoding];
                NSString *value = [NSString stringWithCString:attribute->text encoding:NSUTF8StringEncoding];
                [dict setObject:value forKey:key];
                attribute = attribute->nextSibling;
            }
            [array addObject:dict];
            [dict release];

            person = [TBXML nextSiblingNamed:@"person" searchFromElement:person];
        }
    }
    return array;
}

@end
