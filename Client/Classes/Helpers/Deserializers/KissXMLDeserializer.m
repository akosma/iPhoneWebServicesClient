//
//  KissXMLDeserializer.m
//  Client
//
//  Created by Adrian on 3/6/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "KissXMLDeserializer.h"
#import "DDXML.h"

@implementation KissXMLDeserializer

- (NSArray *)performDeserialization:(id)data
{
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    DDXMLNode *root = [doc rootElement];
    NSMutableArray *array = [NSMutableArray array];

    for (DDXMLNode *child in [root children])
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        for (DDXMLNode *attribute in [child children])
        {
            [dict setObject:[attribute stringValue] forKey:[attribute name]];
        }
        
        [array addObject:dict];
        [dict release];
    }
    
    return array;
}

- (NSString *)formatIdentifier
{
    return @"xml";
}

@end
