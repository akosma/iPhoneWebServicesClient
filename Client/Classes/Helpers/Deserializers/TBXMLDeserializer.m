//
//  TBXMLDeserializer.m
//  Client
//
//  Created by Adrian on 3/6/10.
//  Copyright 2010 akosma software. All rights reserved.
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

- (NSString *)formatIdentifier
{
    return @"xml";
}

@end
