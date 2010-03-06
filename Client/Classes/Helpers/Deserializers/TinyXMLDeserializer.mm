//
//  TinyXMLDeserializer.mm
//  Client
//
//  Created by Adrian on 3/6/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "TinyXMLDeserializer.h"
#import "tinyxml.h"

@implementation TinyXMLDeserializer

- (NSArray *)performDeserialization:(id)data
{
    // Code adapted from 
    // http://www.raywenderlich.com/553/how-to-chose-the-best-xml-parser-for-your-iphone-project
    NSUInteger length = [data length];
    char *buffer = new char[length + 1];
    [data getBytes:buffer];
    buffer[length] = '\0';
    
    TiXmlDocument *doc = new TiXmlDocument();
    doc->Parse(buffer, 0, TIXML_ENCODING_UTF8);
    TiXmlHandle *handle = new TiXmlHandle(doc);

    TiXmlElement *person = handle->FirstChild("data").FirstChild("person").ToElement();
    NSMutableArray *array = [NSMutableArray array];

    while (person != NULL) 
    {
        TiXmlElement *attribute = person->FirstChild()->ToElement();
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        while (attribute != NULL)
        {
            NSString *value = [NSString stringWithUTF8String:attribute->GetText()];
            NSString *key = [NSString stringWithUTF8String:attribute->Value()];
            [dict setObject:value forKey:key];
            attribute = attribute->NextSiblingElement();
        }
        
        [array addObject:dict];
        [dict release];

        person = person->NextSiblingElement();
    }
    
    delete doc;
    delete handle;
    return array;
}

- (NSString *)formatIdentifier
{
    return @"xml";
}

@end
