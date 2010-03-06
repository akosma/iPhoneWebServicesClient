//
//  APXMLDeserializer.m
//  Client
//
//  Created by Adrian on 3/6/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "APXMLDeserializer.h"
#import "APXML.h"

@implementation APXMLDeserializer

- (NSArray *)performDeserialization:(id)data
{
    NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    APDocument *doc = [[APDocument alloc] initWithString:xmlString];
    APElement *root = [doc rootElement];
    NSMutableArray *array = [NSMutableArray array];
    
    for (APElement *child in [root childElements])
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        for (APElement *attribute in [child childElements])
        {
            [dict setObject:[attribute value] forKey:[attribute name]];
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
