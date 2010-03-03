//
//  LibXMLDeserializer.m
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

#import "LibXMLDeserializer.h"
#import <libxml/parser.h>

@implementation LibXMLDeserializer

- (NSArray *)performDeserialization:(id)data
{
    NSMutableArray *array = [NSMutableArray array];
    xmlDocPtr document = xmlParseMemory([data bytes], [data length]);
    xmlNodePtr currentNode = xmlDocGetRootElement(document);
    currentNode = currentNode->children;

    for(; currentNode != NULL; currentNode = currentNode->next) 
    {
        if(currentNode->type == XML_ELEMENT_NODE && 
           xmlStrEqual(currentNode->name, (const xmlChar *) "person"))
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for (xmlNodePtr node = currentNode->children; node != NULL; node = node->next) 
            {
                xmlChar *elementText = xmlNodeListGetString(node->doc, node->children, 1);
                NSString *value = nil;
                
                if(elementText != NULL) 
                {
                    value = [NSString stringWithCString:(char *)elementText 
                                               encoding:NSUTF8StringEncoding];
                    xmlFree(elementText);
                }
                
                [dict setObject:value 
                         forKey:[NSString stringWithCString:(const char *)node->name 
                                                   encoding:NSUTF8StringEncoding]];
            }
            [array addObject:dict];
            [dict release];
        }
    }

    xmlFreeDoc(document);
    xmlCleanupParser();

    return array;
}

- (NSString *)formatIdentifier
{
    return @"xml";
}

@end
