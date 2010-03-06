//
//  GoogleXMLDeserializer.m
//  Client
//
//  Created by Adrian on 3/6/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "GoogleXMLDeserializer.h"
#import "GDataXMLNode.h"

@implementation GoogleXMLDeserializer

- (NSArray *)performDeserialization:(id)data
{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLNode *root = [doc rootElement];
    NSMutableArray *array = [NSMutableArray array];
    
    for (GDataXMLNode *child in [root children])
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        for (GDataXMLNode *attribute in [child children])
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
